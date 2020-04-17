public with sharing class ExternalNlpMockModelService extends ExternalNlpService {
    
    public static String getNamespacePrefix() {
        String namespacePrefix = null;
        String[] classNameParts = String.valueOf(ExternalNlpMockModelService.class).split('\\.', 2);
        if(classNameParts.size() > 1) {
            Type classType = Type.forName(classNameParts[0], classNameParts[1]);
            if(classType == ExternalNlpMockModelService.class) {
                namespacePrefix = classNameParts[0];
            }
        }
        return namespacePrefix; 
    }

    public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();
        String currentNamespace = getNamespacePrefix();
        String namespacePath = currentNamespace != null ? currentNamespace+'/' : '';
        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
            String endpoint = 'callout:'+modelParams.getNamedCredentialKey()+'/services/apexrest/'+namespacePath;
            endpoint += modelParams.getModelId();

            Map<String, Object> queryInputMap = new Map<String, Object>();
            queryInputMap.put('message', params.getInput());
            queryInputMap.put('language', params.getLanguage());
            queryInputMap.put('timeZone', params.getTimeZone() == null ? null : params.getTimeZone().toString());

            String body = JSON.serialize(queryInputMap);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            if (body != null) {
                req.setBody(body);
            }
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

            if(response.getStatusCode() != 200){ throw new ExternalNlpServiceException(
                'Received unexpected response code : '+response.getStatusCode(),
                ExternalNlpServiceExceptionCode.INVALID_HTTP_RESPONSE_CODE); }

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

        if (intents == null || intents.isEmpty()) { return highestScoringExtIntent; }

        for(Object o : intents) {
            Map<String, Object> intent = (Map<String, Object>)o;
            String intentName = (String)intent.get('name');
            Double intentDetectionConfidence = (Double)intent.get('probability');

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

        Double nerConfidenceThreshold = serviceParams.getNerThreshold();

        List<Object> entities = (List<Object>)bodyMap.get('entities');

        if (entities == null || entities.isEmpty()) { return; }

        for(Object o : entities) {
            Map<String, Object> entity = (Map<String, Object>)o;
            String entityName = String.valueOf(entity.get('name'));
            String entityValue = String.valueOf(entity.get('value'));
            Double entityDetectionConfidence = (Double)entity.get('probability');
            if (entityDetectionConfidence >= nerConfidenceThreshold) {
                if (!entitiesMap.containsKey(entityName)) {
                    entitiesMap.put(entityName, new List<ExternalNlpEntity>());
                }
                entitiesMap.get(entityName).add(new ExternalNlpEntity.Builder()
                                                .setName(entityName)
                                                .setValue(entityValue)
                                                .setConfidenceScore(entityDetectionConfidence)
                                                .build());
            }
        }
    }

}