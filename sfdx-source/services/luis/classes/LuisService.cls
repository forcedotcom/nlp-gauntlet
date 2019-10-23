public with sharing class LuisService extends ExternalNlpService {

    private static final String API_VERSION = 'v2.0';
    
    // Set this to True to test against a staging end point
    private final Boolean USE_STAGING_ENDPOINT = false;

    // API Docs: https://westus.dev.cognitive.microsoft.com/docs/services/5819c76f40a6350ce09de1ac/operations/5819c77140a63516d81aee79
    public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
            String endpoint = 'callout:'+modelParams.getNamedCredentialKey();

            // NOTE: Intent detection logic relies on verbose parameter set to true
            endpoint += '/luis/'+API_VERSION+'/apps/'+modelParams.getModelId()+'?verbose=true';

            if (params.getTimeZone() != null) {
                Integer milliSeconds = params.getTimeZone().getOffset(Datetime.now());
                Integer minutes = (milliSeconds/1000)/60;
                endpoint += '&timezoneOffset='+minutes;
            }

            if (params.getInput() != null) {
                endpoint += '&q='+EncodingUtil.urlEncode(params.getInput(), 'UTF-8');
            }

            if (USE_STAGING_ENDPOINT) {
                endpoint += '&staging=true';
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Ocp-Apim-Subscription-Key', '{!$Credential.Password}');
            req.setHeader('Content-Type', 'application/json');
            reqs.add(req);
        }

        return reqs;
    }
    
    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionResultParameters params) {
        List<HttpResponse> responses = params.getHttpResponses();

        Map<String, ExternalNlpIntent> intentsMap = new Map<String, ExternalNlpIntent>();
        ExternalNlpIntent highestScoringExtIntent = null;
        Map<String, List<ExternalNlpEntity>> entitiesMap = new Map<String, List<ExternalNlpEntity>>();

        for (HttpResponse response : responses) {

            if (response.getStatusCode() != 200) { 
                throw new ExternalNlpServiceException(
                    'Received unexpected response code : '+response.getStatusCode(),
                    ExternalNlpServiceExceptionCode.INVALID_HTTP_RESPONSE_CODE); 
            }

            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            // Intent Detection
            highestScoringExtIntent = detectIntents(serviceParams, bodyMap, intentsMap, highestScoringExtIntent);

            // Named Entity Recognition
            detectEntities(serviceParams, bodyMap, entitiesMap);

        }

        String highestConfidenceIntentName = null;
        if (highestScoringExtIntent != null && highestScoringExtIntent.getConfidenceScore() >= serviceParams.getIntentThreshold()) {
            highestConfidenceIntentName = highestScoringExtIntent.getName();
        }

        ExternalNlpPredictionIntentResult intentPredResult = new ExternalNlpPredictionIntentResult.Builder()
            .setHighestConfidenceIntentName(highestConfidenceIntentName)
            .setPredictedIntents(intentsMap)
            .build();

        ExternalNlpPredictionEntityResult entityPredResult = new ExternalNlpPredictionEntityResult.Builder()
            .setPredictedEntities(entitiesMap)
            .build();

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentPredResult)
            .setEntityResults(entityPredResult)
            .build();
    }

    private ExternalNlpIntent detectIntents(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpIntent> intentsMap, ExternalNlpIntent highestScoringExtIntent) {
        if (serviceParams.getDisableIntentDetection()) { return highestScoringExtIntent; }

        List<Object> intents = (List<Object>)bodyMap.get('intents');

        if(intents == null || intents.isEmpty()) { return highestScoringExtIntent; }

        // NOTE: we are calculating highestScoringExtIntent as per set thresholds and not 
        // picking up topScoringIntent returned in the response.
        for(Object o : intents) {
            Map<String, Object> intent = (Map<String, Object>)o;

            // Intent detection response
            String intentName = (String)intent.get('intent');
            Double intentDetectionConfidence = (Double)intent.get('score');
            ExternalNlpIntent extIntent = new ExternalNlpIntent.Builder()
                                                    .setName(intentName)
                                                    .setConfidenceScore(intentDetectionConfidence)
                                                    .build();
            
            intentsMap.put(extIntent.getName(), extIntent);

            if (highestScoringExtIntent == null || intentDetectionConfidence > highestScoringExtIntent.getConfidenceScore()) {
                highestScoringExtIntent = extIntent;
            }
        }

        return highestScoringExtIntent;
    }

    private void detectEntities(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, List<ExternalNlpEntity>> entitiesMap) {
        if (serviceParams.getDisableEntityExtraction()) { return; }

        List<Object> entities = (List<Object>)bodyMap.get('entities');

        if (entities == null || entities.isEmpty()) { return; }

        for(Object o : entities) {
            Map<String, Object> entity = (Map<String, Object>)o;
            String matchedText = (String)entity.get('entity');
            String entityType = (String)entity.get('type');
            Integer startIndex = (Integer)entity.get('startIndex');
            Integer endIndex = (Integer)entity.get('endIndex');

            //LUIS does not returns confidence only for simple entities. 
            //For most entities the score will be set to 1.0
            Double entityDetectionConfidence = entity.get('score') == null?1.0:(Double)entity.get('score');

            Map<String, Object> resolution = (Map<String, Object>)entity.get('resolution');
            String role = (String)entity.get('role');

            String entityName = getEntityName(entityType, role);
            List<String> entityValues = getEntityValue(entityType, resolution, matchedText);

            if (!entitiesMap.containsKey(entityName)) {
                entitiesMap.put(entityName, new List<ExternalNlpEntity>());
            }

            for (String entityValue : entityValues) {
                entitiesMap.get(entityName).add(new ExternalNlpEntity.Builder()
                                                .setName(entityName)
                                                .setValue(entityValue)
                                                .setMatchedText(matchedText)
                                                .setStartIndex(startIndex)
                                                .setEndIndex(endIndex)
                                                .setConfidenceScore(entityDetectionConfidence)
                                                .build());
            }
        }

    }

    // NOTE: for built in entities we will always send the type which starts with builtin.
    // When role is provided we will send the role which takes higher precedence than type.
    private String getEntityName(String type, String role) {
        if (String.isNotEmpty(role) && String.isNotBlank(role)) {
            return role;
        }
        return type;
    }

    private String entityCompare(String timex, String value) {
        if (String.isNotEmpty(timex) && String.isNotBlank(timex)) {
            if (!timex.contains('XXXX')) {
                return timex;
            }
        }
        return value;
    }

    // For composite entities we only read the properties under the entities attribute and not the one under compositeEntities.
    private List<String> getEntityValue(String type, Map<String, Object> resolution, String matchedText) {
        List<String> detectedValues = new List<String>();

        if (type.startsWith('builtin.')) {
            if (resolution != null && !resolution.isEmpty()) {
                String entValue = String.valueOf(resolution.get('value'));
                if (String.isNotEmpty(entValue) && String.isNotBlank(entValue)) {
                    detectedValues.add(entValue);
                    return detectedValues;
                }
                    
                // For Entities like Date and DateTime which can have multiple values associated with it
                // https://docs.microsoft.com/en-us/azure/cognitive-services/luis/luis-reference-prebuilt-datetimev2
                List<Object> values = (List<Object>)resolution.get('values');
                if (values != null && !values.isEmpty()) {
                    for(Object o : values) {
                        Map<String, Object> valueMap = (Map<String, Object>)o;
                        String timex = null;
                        String value = null;

                        //For Date and Date time entity type
                        if (valueMap.get('timex') != null) {
                            timex = String.valueOf(valueMap.get('timex'));
                        }

                        if (valueMap.get('value') != null) {
                            value = String.valueOf(valueMap.get('value'));
                        }
                        detectedValues.add(entityCompare(timex, value));
                    }
                    return detectedValues;
                } 
            }
        } else {
            // For Non-BuiltIn entities resolution will be present most of the times
            if (resolution != null && !resolution.isEmpty()) {
                List<Object> values = (List<Object>)resolution.get('values');
                if (values != null && !values.isEmpty()) {
                    for(Object o : values) {
                        detectedValues.add(String.valueOf(o));
                    }
                    return detectedValues;
                }
            }
        }
        // When we are unable to use above defined fields we always return back matched text
        // as entity value
        detectedValues.add(matchedText);
        return detectedValues;
    }
}