public with sharing class WitAiService extends ExternalNlpService {

    private final static String API_VERSION = '20190502';
    
    // NOTE: wit identifies an app based on a token which is app specific

    public WitAiService(ExternalNlpServiceParameters serviceParams){
        this.serviceParams = serviceParams;
    }

    // API Docs: https://wit.ai/docs/http/20160526#get__message_link
    public override List<HttpRequest> getPredictionRequests(ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : this.serviceParams.getModelParams()) {
            String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
            endpoint += '/message?v='+API_VERSION+'&q='+EncodingUtil.urlEncode(params.getInput(), 'UTF-8');

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
            reqs.add(req);
        }

        return reqs;
    }

    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpPredictionResultParameters params) {
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
            highestScoringExtIntent = detectIntents(bodyMap, intentsMap, highestScoringExtIntent);

            // Named Entity Recognition
            detectEntities(bodyMap, entitiesMap);
        }

        String highestConfidenceIntentName = null;
        if (highestScoringExtIntent != null && highestScoringExtIntent.getConfidenceScore() >= this.serviceParams.getIntentThreshold()) {
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

    private ExternalNlpIntent detectIntents(Map<String, Object> bodyMap, Map<String, ExternalNlpIntent> intentsMap, ExternalNlpIntent highestScoringExtIntent) {
        if (this.serviceParams.getDisableIntentDetection()) { return highestScoringExtIntent; }

        Map<String, Object> entities = (Map<String, Object>)bodyMap.get('entities');

        for(String entityName : entities.keySet()) {
            // NOTE: This implementaiton expects an entity called 'intent' for intent detection
            // other entities will be considered to be NER entities
            if (entityName != 'intent') { continue; }

            List<Object> intents = (List<Object>)entities.get(entityName);
            if (intents == null || intents.isEmpty()) { continue; }

            for(Object o : intents) {
                Map<String, Object> intent = (Map<String, Object>)o;
                String intentName = (String)intent.get('value');
                Double intentDetectionConfidence = (Double)intent.get('confidence');

                ExternalNlpIntent extIntent = new ExternalNlpIntent.Builder()
                                    .setName(intentName)
                                    .setConfidenceScore(intentDetectionConfidence)
                                    .build();
                intentsMap.put(extIntent.getName(), extIntent);

                if (highestScoringExtIntent == null || intentDetectionConfidence > highestScoringExtIntent.getConfidenceScore()) {
                    highestScoringExtIntent = extIntent;
                }
            }
        }

        return highestScoringExtIntent;
    }

    private void detectEntities(Map<String, Object> bodyMap, Map<String, List<ExternalNlpEntity>> entitiesMap) {
        if (this.serviceParams.getDisableEntityExtraction()) { return; }

        Double nerConfidenceThreshold = this.serviceParams.getNerThreshold();

        Map<String, Object> entities = (Map<String, Object>)bodyMap.get('entities');

        for(String entityName : entities.keySet()) {

            if (entityName == 'intent') { continue; }

            // NOTE: Make sure you assign role names for entities in wit to prevent overriding entires in the response map
            List<Object> entityObjects = (List<Object>)entities.get(entityName);
            if (entityObjects == null || entityObjects.isEmpty()) { continue; }

            List<ExternalNlpEntity> extEntities = new List<ExternalNlpEntity>();
            for(Object o : entityObjects) {
                Map<String, Object> entity = (Map<String, Object>)o;
                String entityValue = (String)entity.get('value');
                Double entityDetectionConfidence = (Double)entity.get('confidence');
                if (entityDetectionConfidence >= nerConfidenceThreshold) {
                    extEntities.add(new ExternalNlpEntity.Builder()
                                                    .setName(entityName)
                                                    .setValue(entityValue)
                                                    .setConfidenceScore(entityDetectionConfidence)
                                                    .build());
                }
            }
            entitiesMap.put(entityName, extEntities);

        }

    }

}