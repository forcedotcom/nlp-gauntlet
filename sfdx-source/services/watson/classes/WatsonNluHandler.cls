public with sharing class WatsonNluHandler {

    private static final String API_VERSION = '2019-07-12';

    // API Docs: https://cloud.ibm.com/apidocs/natural-language-understanding
    public static HttpRequest buildRequest(ExternalNlpModelParameters modelParams, ExternalNlpPredictionRequestParameters reqParams) {
        String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
        endpoint += '/natural-language-understanding/api/v1/analyze?version='+API_VERSION;

        Map<String, Object> queryInputMap = new Map<String,Object>{
            'text' => reqParams.getInput(),
            'features' => new Map<String,Object>()
        };

        Map<String,Object> featuresMap = (Map<String,Object>)queryInputMap.get('features');

        List<String> modelIds = modelParams.getModelId().split(',');
        for(String modelId : modelIds) {
            if (modelId == 'Emotion') {
                featuresMap.put(
                    'emotion', new Map<String, Object>{ 'document' => true});
            } else if (modelId == 'Sentiment') {
                featuresMap.put(
                    'sentiment', new Map<String, Object>{ 'document' => true});
            }
        }

        String body = JSON.serialize(queryInputMap);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');

        if (body != null) {
            req.setBody(body);
        }
        req.setHeader('Content-Type', 'application/json');
        return req;
    }

    public static ExternalNlpPredictionResult buildResult(List<Map<String, Object>> responseMap, Double sentimentConfidenceThreshold, Boolean disableSentimentDetection) {
        return new ExternalNlpPredictionResult.Builder()
            .setEmotionResults(getEmotionResults(responseMap))
            .setSentimentResults(getSentimentResults(responseMap, sentimentConfidenceThreshold, disableSentimentDetection))
            .build();
    }

    private static ExternalNlpPredictionEmotionResult getEmotionResults(List<Map<String, Object>> responseMap) {
        Map<String, ExternalNlpEmotion> emotionsMap = new Map<String, ExternalNlpEmotion>();
        
        ExternalNlpEmotion highestConfidenceEmotion = null;

        for (Map<String, Object> bodyMap : responseMap) {

            Map<String, Object> respTopEmotionMap = (Map<String, Object>)bodyMap.get('emotion');

            if (respTopEmotionMap == null) { continue; }

            Map<String, Object> respDocumentMap = (Map<String, Object>)respTopEmotionMap.get('document');
            Map<String, Object> respEmotionsMap = (Map<String, Object>)respDocumentMap.get('emotion');

            Set<String> emotions = respEmotionsMap.keySet();

            List<ExternalNlpEmotion> extNlpEmotions = new List<ExternalNlpEmotion>();

            for(String emotionName : emotions) {

                Double emotionScore = (Double)respEmotionsMap.get(emotionName);

                ExternalNlpEmotion extNlpEmotion = new ExternalNlpEmotion.Builder()
                                                .setName(emotionName)
                                                .setConfidenceScore(emotionScore)
                                                .build();

                emotionsMap.put(emotionName, extNlpEmotion);
                if (emotionScore > 0 && (highestConfidenceEmotion == null || emotionScore > highestConfidenceEmotion.getConfidenceScore())) {
                    highestConfidenceEmotion = extNlpEmotion;
                }

            }
        }

        if (emotionsMap.isEmpty()) {
            return null;
        }

        String highestConfidenceEmotionName = highestConfidenceEmotion != null ? highestConfidenceEmotion.getName() : null;
        ExternalNlpDocumentEmotion extDocEmotion = new ExternalNlpDocumentEmotion.Builder()
                                                    .setPredictedEmotions(emotionsMap)
                                                    .setHighestConfidenceEmotionName(highestConfidenceEmotionName)
                                                    .build();
        ExternalNlpPredictionEmotionResult extPredEmotionResult = new ExternalNlpPredictionEmotionResult.Builder()
                                                                    .setDocumentEmotion(extDocEmotion)
                                                                    .build();
        return extPredEmotionResult;
    }

    private static ExternalNlpPredictionSentimentResult getSentimentResults(List<Map<String, Object>> responseMap, Double sentimentConfidenceThreshold, Boolean disableSentimentDetection) {
        
        if (disableSentimentDetection) { return null; }
        
        Map<String, ExternalNlpSentiment> sentimentsMap = new Map<String, ExternalNlpSentiment>();
        
        ExternalNlpSentiment highestScoringExtSentiment = null;

        for (Map<String, Object> bodyMap : responseMap) {

            Map<String, Object> respTopSentimentMap = (Map<String, Object>)bodyMap.get('sentiment');

            if (respTopSentimentMap == null) { continue; }

            Map<String, Object> respDocumentMap = (Map<String, Object>)respTopSentimentMap.get('document');

            String sentimentLabel = (String)respDocumentMap.get('label');
            Double sentimentScore = (Double)respDocumentMap.get('score');
            Double absSentimentScore = Math.abs(sentimentScore);

            ExternalNlpSentiment extNlpSentiment = new ExternalNlpSentiment.Builder()
                                            .setName(sentimentLabel)
                                            .setConfidenceScore(sentimentScore)
                                            .build();

            sentimentsMap.put(sentimentLabel, extNlpSentiment);
            if (absSentimentScore > 0 && (highestScoringExtSentiment == null || absSentimentScore > Math.abs(highestScoringExtSentiment.getConfidenceScore()))) {
                highestScoringExtSentiment = extNlpSentiment;
            }

        }

        if (sentimentsMap.isEmpty()) {
            return null;
        }

        String highestConfidenceSentimentName = null;
        if (highestScoringExtSentiment != null && Math.abs(highestScoringExtSentiment.getConfidenceScore()) >= sentimentConfidenceThreshold) {
            highestConfidenceSentimentName = highestScoringExtSentiment.getName();
        }

        ExternalNlpDocumentSentiment extDocSentiment = new ExternalNlpDocumentSentiment.Builder()
                                                    .setPredictedSentiments(sentimentsMap)
                                                    .setHighestConfidenceSentimentName(highestConfidenceSentimentName)
                                                    .build();
        ExternalNlpPredictionSentimentResult extPredSentimentResult = new ExternalNlpPredictionSentimentResult.Builder()
                                                                    .setDocumentSentiment(extDocSentiment)
                                                                    .build();
        return extPredSentimentResult;

    }

}
