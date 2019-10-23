public with sharing class WitAiService extends ExternalNlpService {

    private final static String API_VERSION = '20190502';
    
    // NOTE: wit identifies an app based on a token which is app specific
    // API Docs: https://wit.ai/docs/http/20160526#get__message_link
    public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
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

    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionResultParameters params) {
        List<HttpResponse> responses = params.getHttpResponses();

        Map<String, ExternalNlpIntent> intentsMap = new Map<String, ExternalNlpIntent>();
        ExternalNlpIntent highestScoringExtIntent = null;
        Map<String, List<ExternalNlpEntity>> entitiesMap = new Map<String, List<ExternalNlpEntity>>();
        Map<String, ExternalNlpSentiment> sentimentsMap = new Map<String, ExternalNlpSentiment>();
        ExternalNlpSentiment highestScoringExtSentiment = null;

        for (HttpResponse response : responses) {

            if(response.getStatusCode() != 200){ throw new ExternalNlpServiceException(
                'Received unexpected response code : '+response.getStatusCode(),
                ExternalNlpServiceExceptionCode.INVALID_HTTP_RESPONSE_CODE); }

            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
          
            // Intent Detection
            highestScoringExtIntent = detectIntents(serviceParams, bodyMap, intentsMap, highestScoringExtIntent);

            // Named Entity Recognition
            detectEntities(serviceParams, bodyMap, entitiesMap);

            // Sentiment Recognition
            highestScoringExtSentiment = detectSentiments(serviceParams, bodyMap, sentimentsMap, highestScoringExtSentiment);
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

        String highestConfidenceSentimentName = null;
        if (highestScoringExtSentiment != null && highestScoringExtSentiment.getConfidenceScore() >= serviceParams.getSentimentThreshold()) {
            highestConfidenceSentimentName = highestScoringExtSentiment.getName();
        }

        ExternalNlpPredictionSentimentResult sentimentPredResult = new ExternalNlpPredictionSentimentResult.Builder()
            .setDocumentSentiment(new ExternalNlpDocumentSentiment.Builder()
                .setHighestConfidenceSentimentName(highestConfidenceSentimentName)
                .setPredictedSentiments(sentimentsMap)
                .build())
            .build();

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentPredResult)
            .setEntityResults(entityPredResult)
            .setSentimentResults(sentimentPredResult)
            .build();

    }

    private ExternalNlpIntent detectIntents(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpIntent> intentsMap, ExternalNlpIntent highestScoringExtIntent) {
        if (serviceParams.getDisableIntentDetection()) { return highestScoringExtIntent; }

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

    private void detectEntities(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, List<ExternalNlpEntity>> entitiesMap) {
        if (serviceParams.getDisableEntityExtraction()) { return; }

        Double nerConfidenceThreshold = serviceParams.getNerThreshold();

        Map<String, Object> entities = (Map<String, Object>)bodyMap.get('entities');

        for(String entityName : entities.keySet()) {

            if (entityName == 'intent' || entityName == 'sentiment') { continue; }

            // NOTE: Make sure you assign role names for entities in wit to prevent overriding entires in the response map
            List<Object> entityObjects = (List<Object>)entities.get(entityName);
            if (entityObjects == null || entityObjects.isEmpty()) { continue; }

            List<ExternalNlpEntity> extEntities = new List<ExternalNlpEntity>();
            for(Object o : entityObjects) {
                Map<String, Object> entity = (Map<String, Object>)o;
                String entityValue = String.valueOf(entity.get('value'));
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

    private ExternalNlpSentiment detectSentiments(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpSentiment> sentimentsMap, ExternalNlpSentiment highestScoringExtSentiment) {

        if (serviceParams.getDisableSentimentDetection()) { return highestScoringExtSentiment; }

        Map<String, Object> entities = (Map<String, Object>)bodyMap.get('entities');

        for(String entityName : entities.keySet()) {

            if (entityName != 'sentiment') { continue; }

            List<Object> sentiments = (List<Object>)entities.get(entityName);
            if (sentiments == null || sentiments.isEmpty()) { continue; }

            for(Object o : sentiments) {
                Map<String, Object> sentiment = (Map<String, Object>)o;
                String sentimentName = String.valueOf(sentiment.get('value'));
                Double sentimentDetectionConfidence = (Double)sentiment.get('confidence');

                ExternalNlpSentiment extSentiment = new ExternalNlpSentiment.Builder()
                                    .setName(sentimentName)
                                    .setConfidenceScore(sentimentDetectionConfidence)
                                    .build();
                sentimentsMap.put(extSentiment.getName(), extSentiment);

                if (highestScoringExtSentiment == null || sentimentDetectionConfidence > highestScoringExtSentiment.getConfidenceScore()) {
                    highestScoringExtSentiment = extSentiment;
                }
            }

        }

        return highestScoringExtSentiment;

    }

}