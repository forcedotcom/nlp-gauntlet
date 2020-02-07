public with sharing class UltimateAiService extends ExternalNlpService {
    
    public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
            String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
            endpoint += '/api/intents';
            String message = params.getInput();
            String botId = modelParams.getModelId();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('authorization', '{!$Credential.Password}');
            req.setHeader('Content-Type', 'application/json');

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('message', message);
            gen.writeStringField('botId', botId);
            gen.writeEndObject();
            String jsonS = gen.getAsString();
            req.setBody(jsonS);
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

        List<Object> intents = (List<Object>)bodyMap.get('intents');

        Object mostConfidentIntentObject = intents[0];
        Map<String, Object> mostConfidentIntent = (Map<String, Object>)mostConfidentIntentObject;
        highestScoringExtIntent = new ExternalNlpIntent.Builder()
                .setName((String)mostConfidentIntent.get('name'))
                .setConfidenceScore((Double)mostConfidentIntent.get('confidence'))
                .build();

        for(Object o : intents){
            Map<String, Object> intent = (Map<String, Object>)o;
            ExternalNlpIntent extIntent = new ExternalNlpIntent.Builder()
                    .setName((String) intent.get('name'))
                    .setConfidenceScore((Double) intent.get('confidence'))
                    .build();

            intentsMap.put(extIntent.getName(), extIntent);
        }

        return highestScoringExtIntent;
    }

    private void detectEntities(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, List<ExternalNlpEntity>> entitiesMap) {
        if (serviceParams.getDisableEntityExtraction()) { return; }

        Double nerConfidenceThreshold = serviceParams.getNerThreshold();

        List<Object> entities = (List<Object>)bodyMap.get('entities');
        List<ExternalNlpEntity> extEntities = new List<ExternalNlpEntity>();

        for(Object o : entities) {
            Map<String, Object> entity = (Map<String, Object>)o;
            String entityName = String.valueOf(entity.get('name'));
            String entityValue = String.valueOf(entity.get('form'));
            Double entityDetectionConfidence = (Double)entity.get('confidence');
            if (entityDetectionConfidence >= nerConfidenceThreshold) {
                extEntities.add(new ExternalNlpEntity.Builder()
                                                .setName(entityName)
                                                .setValue(entityValue)
                                                .setConfidenceScore(entityDetectionConfidence)
                                                .build());
            }
            entitiesMap.put(entityName, extEntities);

        }

    }

    private ExternalNlpSentiment detectSentiments(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpSentiment> sentimentsMap, ExternalNlpSentiment highestScoringExtSentiment) {
        return highestScoringExtSentiment;
    }

}