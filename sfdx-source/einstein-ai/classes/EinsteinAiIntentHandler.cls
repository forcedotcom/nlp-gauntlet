public with sharing class EinsteinAiIntentHandler {

    // By default remove any part of the label before a hyphen
    // Einstein Bots prepends labels with domain name - intent name)
    private final static Boolean REMOVE_HYPHEN_PREFIX = true;

    private final static String API_VERSION = 'v2';

    // API Docs : https://metamind.readme.io/docs/prediction-intent
    public static HttpRequest buildRequest(ExternalNlpModelParameters modelParams, ExternalNlpPredictionRequestParameters reqParams) {
        String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
        return getIntentRequest(endpoint, modelParams.getModelId(), reqParams.getInput());
    }

    private static HttpRequest getIntentRequest(String baseEndpoint, String modelId, String input){
        String endpoint = baseEndpoint+'/'+API_VERSION+'/language/intent';
        
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
        Double intentConfidenceThreshold) {

        if (responseMap == null || responseMap.isEmpty()) {
            return new ExternalNlpPredictionResult.Builder()
                .setIntentResults(null)
                .build();
        }

        Map<String, ExternalNlpIntent> intentsMap = new Map<String, ExternalNlpIntent>();
        ExternalNlpIntent highestScoringExtIntent = null;

        for(Map<String, Object> probability : responseMap) {
            // Intent detection response
            String intentName = (String)probability.get('label');
            if (REMOVE_HYPHEN_PREFIX) {
                intentName = intentName.substringAfter('-');
            }
            Double intentDetectionConfidence = (Double)probability.get('probability');
            ExternalNlpIntent extIntent = new ExternalNlpIntent.Builder()
                                                    .setName(intentName)
                                                    .setConfidenceScore(intentDetectionConfidence)
                                                    .build();
            intentsMap.put(extIntent.getName(), extIntent);
            if (highestScoringExtIntent == null || intentDetectionConfidence > highestScoringExtIntent.getConfidenceScore()) {
                highestScoringExtIntent = extIntent;
            }
        }

        String highestConfidenceIntentName = null;
        if (highestScoringExtIntent != null && highestScoringExtIntent.getConfidenceScore() >= intentConfidenceThreshold) {
            highestConfidenceIntentName = highestScoringExtIntent.getName();
        }

        ExternalNlpPredictionIntentResult intentPredResult = new ExternalNlpPredictionIntentResult.Builder()
            .setHighestConfidenceIntentName(highestConfidenceIntentName)
            .setPredictedIntents(intentsMap)
            .build();

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentPredResult)
            .build();

    }

}
