public with sharing class EinsteinAiSentimentHandler {
   private final static String API_VERSION = 'v2';

    // API Docs : https://metamind.readme.io/docs/use-pre-built-models-sentiment
    public static HttpRequest buildRequest(ExternalNlpModelParameters modelParams, ExternalNlpPredictionRequestParameters reqParams) {
        String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
        return getSentimentRequest(endpoint, modelParams.getModelId(), reqParams.getInput());
    }

    private static HttpRequest getSentimentRequest(String baseEndpoint, String modelId, String input){
        String endpoint = baseEndpoint+'/'+API_VERSION+'/language/sentiment';
        
        String contentType = ExternalNlpHttpFormBuilder.GetContentType();
        String form64 = '';

        form64 += ExternalNlpHttpFormBuilder.WriteBoundary();
        form64 += ExternalNlpHttpFormBuilder.WriteBodyParameter('modelId', modelId);
        form64 += ExternalNlpHttpFormBuilder.WriteBoundary();
        form64 += ExternalNlpHttpFormBuilder.WriteBodyParameter('document', input);
        form64 += ExternalNlpHttpFormBuilder.WriteBoundary(null);

        Blob formBlob = EncodingUtil.base64Decode(form64);
        String contentLength = string.valueOf(formBlob.size());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', contentType);
        req.setHeader('Content-Length', contentLength);
        req.setBodyAsBlob(formBlob);
        return req;
    }

    public static ExternalNlpPredictionResult buildResult(List<Map<String, Object>> responseMap,
        Double sentimentConfidenceThreshold) {

        if (responseMap == null || responseMap.isEmpty()) {
            return new ExternalNlpPredictionResult.Builder()
                .setSentimentResults(null)
                .build();
        }

        Map<String, ExternalNlpSentiment> sentimentsMap = new Map<String, ExternalNlpSentiment>();
        ExternalNlpSentiment highestScoringExtSentiment = null;

        for(Map<String, Object> probability : responseMap) {
            // Sentiment detection response
            String sentimentName = (String)probability.get('label');

            Double sentimentDetectionConfidence = (Double)probability.get('probability');
            ExternalNlpSentiment extSentiment = new ExternalNlpSentiment.Builder()
                                                    .setName(sentimentName)
                                                    .setConfidenceScore(sentimentDetectionConfidence)
                                                    .build();
            sentimentsMap.put(extSentiment.getName(), extSentiment);
            if (highestScoringExtSentiment == null || sentimentDetectionConfidence > highestScoringExtSentiment.getConfidenceScore()) {
                highestScoringExtSentiment = extSentiment;
            }
        }

        String highestConfidenceSentimentName = null;
        if (highestScoringExtSentiment != null && highestScoringExtSentiment.getConfidenceScore() >= sentimentConfidenceThreshold) {
            highestConfidenceSentimentName = highestScoringExtSentiment.getName();
        }

        ExternalNlpDocumentSentiment documentSentiment = new ExternalNlpDocumentSentiment.Builder()
            .setHighestConfidenceSentimentName(highestConfidenceSentimentName)
            .setPredictedSentiments(sentimentsMap)
            .build();

        ExternalNlpPredictionSentimentResult sentimentPredResult = new ExternalNlpPredictionSentimentResult.Builder()
            .setDocumentSentiment(documentSentiment)
            .build();

        return new ExternalNlpPredictionResult.Builder()
            .setSentimentResults(sentimentPredResult)
            .build();

    }
}
