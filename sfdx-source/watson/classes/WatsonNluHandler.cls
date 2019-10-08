public with sharing class WatsonNluHandler {

    private static final String API_VERSION = '2019-07-12';

    // API Docs: https://cloud.ibm.com/apidocs/natural-language-understanding
    public static HttpRequest buildRequest(ExternalNlpModelParameters modelParams, ExternalNlpPredictionRequestParameters reqParams) {
        String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
        endpoint += '/natural-language-understanding/api/v1/analyze?version='+API_VERSION;

        Map<String, Object> queryInputMap = new Map<String,Object>{
            'text' => reqParams.getInput(),
            'features' => new Map<String,Object>{
                'emotion' => new Map<String, Object>{
                    'document' => true
                }
            }
        };

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

    public static ExternalNlpPredictionResult buildResult(List<Map<String, Object>> responseMap) {
        Map<String, ExternalNlpEmotion> emotionsMap = new Map<String, ExternalNlpEmotion>();
        ExternalNlpEmotion highestConfienceEmotion = null;

        for (Map<String, Object> bodyMap : responseMap) {

            Map<String, Object> respTopEmotionMap = (Map<String, Object>)bodyMap.get('emotion');
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
                if (emotionScore > 0 && (highestConfienceEmotion == null || extNlpEmotion.getConfidenceScore() > highestConfienceEmotion.getConfidenceScore())) {
                    highestConfienceEmotion = extNlpEmotion;
                }

            }

        }

        if (emotionsMap.isEmpty()) {
            return new ExternalNlpPredictionResult.Builder()
                .setEmotionResults(null)
                .build();
        }

        String highestConfienceEmotionName = highestConfienceEmotion != null ? highestConfienceEmotion.getName() : null;
        ExternalNlpDocumentEmotion extDocEmotion = new ExternalNlpDocumentEmotion.Builder()
                                                    .setPredictedEmotions(emotionsMap)
                                                    .setHighestConfidenceEmotionName(highestConfienceEmotionName)
                                                    .build();
        ExternalNlpPredictionEmotionResult extPredEmotionResult = new ExternalNlpPredictionEmotionResult.Builder()
                                                                    .setDocumentEmotion(extDocEmotion)
                                                                    .build();

        return new ExternalNlpPredictionResult.Builder()
            .setEmotionResults(extPredEmotionResult)
            .build();
    }

}
