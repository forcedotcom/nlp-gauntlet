@isTest
public with sharing class ExternalNlpMockService extends ExternalNlpService {

   public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
            String endpoint = 'https://test.service.com/model/'+modelParams.getModelId()+'/predict';

            if (params.getTimeZone() != null) {
                Integer milliSeconds = params.getTimeZone().getOffset(Datetime.now());
                Integer minutes = (milliSeconds/1000)/60;
                endpoint += '&timezoneOffset='+minutes;
            }

            if (params.getInput() != null) {
                endpoint += '&q='+EncodingUtil.urlEncode(params.getInput(), 'UTF-8');
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
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
        Map<String, ExternalNlpSentiment> sentimentsMap = new Map<String, ExternalNlpSentiment>();
        ExternalNlpSentiment highestScoringExtSentiment = null;
        Map<String, ExternalNlpTone> tonesMap = new Map<String, ExternalNlpTone>();
        ExternalNlpTone highestScoringExtTone = null;
        Map<String, ExternalNlpEmotion> emotionsMap = new Map<String, ExternalNlpEmotion>();
        ExternalNlpEmotion highestScoringExtEmotion = null;

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

            // Tone Recognition
            highestScoringExtTone = detectTones(serviceParams, bodyMap, tonesMap, highestScoringExtTone);

            // Emotion Recognition
            highestScoringExtEmotion = detectEmotions(serviceParams, bodyMap, emotionsMap, highestScoringExtEmotion);

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

        ExternalNlpPredictionToneResult tonePredResult = new ExternalNlpPredictionToneResult.Builder()
            .setDocumentTone(new ExternalNlpDocumentTone.Builder()
                .setHighestConfidenceToneName(highestScoringExtTone != null ? highestScoringExtTone.getName() : null)
                .setPredictedTones(tonesMap)
                .build())
            .build();

        ExternalNlpPredictionEmotionResult emotionPredResult = new ExternalNlpPredictionEmotionResult.Builder()
            .setDocumentEmotion(new ExternalNlpDocumentEmotion.Builder()
                .setHighestConfidenceEmotionName(highestScoringExtEmotion != null ? highestScoringExtEmotion.getName() : null)
                .setPredictedEmotions(emotionsMap)
                .build())
            .build();

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentPredResult)
            .setEntityResults(entityPredResult)
            .setSentimentResults(sentimentPredResult)
            .setToneResults(tonePredResult)
            .setEmotionResults(emotionPredResult)
            .build();
    }

    private ExternalNlpIntent detectIntents(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpIntent> intentsMap, ExternalNlpIntent highestScoringExtIntent) {
        if (serviceParams.getDisableIntentDetection()) { return highestScoringExtIntent; }

        List<Object> intents = (List<Object>)bodyMap.get('intents');

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

        for(Object o : entities) {
            List<ExternalNlpEntity> extEntities = new List<ExternalNlpEntity>();
            Map<String, Object> entity = (Map<String, Object>)o;
            String entityName = (String)entity.get('name');
            String entityValue = (String)entity.get('value');
            Double entityDetectionConfidence = (Double)entity.get('probability');
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

        Double sentimentConfidenceThreshold = serviceParams.getSentimentThreshold();

        List<Object> sentiments = (List<Object>)bodyMap.get('sentiments');

        for(Object o : sentiments) {
            Map<String, Object> sentiment = (Map<String, Object>)o;
            String sentimentName = (String)sentiment.get('name');
            Double sentimentDetectionConfidence = (Double)sentiment.get('probability');

            ExternalNlpSentiment extSentiment = new ExternalNlpSentiment.Builder()
                                .setName(sentimentName)
                                .setConfidenceScore(sentimentDetectionConfidence)
                                .build();
            sentimentsMap.put(extSentiment.getName(), extSentiment);

            if (highestScoringExtSentiment == null || sentimentConfidenceThreshold > highestScoringExtSentiment.getConfidenceScore()) {
                highestScoringExtSentiment = extSentiment;
            }
        }

        return highestScoringExtSentiment;
    }

    private ExternalNlpTone detectTones(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpTone> tonesMap, ExternalNlpTone highestScoringExtTone) {

        List<Object> tones = (List<Object>)bodyMap.get('tones');

        for(Object o : tones) {
            Map<String, Object> tone = (Map<String, Object>)o;
            String toneName = (String)tone.get('name');
            Double toneDetectionConfidence = (Double)tone.get('probability');

            ExternalNlpTone extTone = new ExternalNlpTone.Builder()
                                .setName(toneName)
                                .setConfidenceScore(toneDetectionConfidence)
                                .build();
            tonesMap.put(extTone.getName(), extTone);

            if (highestScoringExtTone == null || extTone.getConfidenceScore() > highestScoringExtTone.getConfidenceScore()) {
                highestScoringExtTone = extTone;
            }
        }

        return highestScoringExtTone;
    }

    private ExternalNlpEmotion detectEmotions(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpEmotion> emotionsMap, ExternalNlpEmotion highestScoringExtEmotion) {

        List<Object> emotions = (List<Object>)bodyMap.get('emotions');

        for(Object o : emotions) {
            Map<String, Object> emotion = (Map<String, Object>)o;
            String emotionName = (String)emotion.get('name');
            Double emotionDetectionConfidence = (Double)emotion.get('probability');

            ExternalNlpEmotion extEmotion = new ExternalNlpEmotion.Builder()
                                .setName(emotionName)
                                .setConfidenceScore(emotionDetectionConfidence)
                                .build();
            emotionsMap.put(extEmotion.getName(), extEmotion);

            if (highestScoringExtEmotion == null || extEmotion.getConfidenceScore() > highestScoringExtEmotion.getConfidenceScore()) {
                highestScoringExtEmotion = extEmotion;
            }
        }

        return highestScoringExtEmotion;
    }

}
