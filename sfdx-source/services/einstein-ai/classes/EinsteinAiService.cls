public with sharing class EinsteinAiService extends ExternalNlpService {

    private static final String SENTIMENT_MODEL_NAME = 'CommunitySentiment';

    private static final Set<String> SENTIMENT_LABELS = new Set<String>{
        'positive', 'negative', 'neutral'
    };

    public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
            if (modelParams.getModelId() == SENTIMENT_MODEL_NAME) {
                if (!serviceParams.getDisableSentimentDetection()) {
                    reqs.add(EinsteinAiSentimentHandler.buildRequest(modelParams, params));
                }
            } else if (!serviceParams.getDisableIntentDetection()) {
                reqs.add(EinsteinAiIntentHandler.buildRequest(modelParams, params));
            }
        }

        return reqs;
    }

    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionResultParameters params) {
        List<HttpResponse> responses = params.getHttpResponses();

        Map<String, List<Map<String, Object>>> requestBodyMap = new Map<String, List<Map<String, Object>>>{
            'intent' => new List<Map<String, Object>>(),
            'sentiment' => new List<Map<String, Object>>()
        };

        for (HttpResponse response : responses) {
            if(response.getStatusCode() != 200){ throw new ExternalNlpServiceException(
                'Received unexpected response code : '+response.getStatusCode(),
                ExternalNlpServiceExceptionCode.INVALID_HTTP_RESPONSE_CODE); }

            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            List<Object> probabilities = (List<Object>)bodyMap.get('probabilities');

            if(probabilities != null && !probabilities.isEmpty()) {
                Set<String> labels = new Set<String>();
                for(Object o : probabilities) {
                    Map<String, Object> probability = (Map<String, Object>)o;
                    labels.add((String)probability.get('label'));
                }
                boolean isSentiment = labels != null && labels.size() == 3 && labels.containsAll(SENTIMENT_LABELS);

                for(Object o : probabilities) {
                    Map<String, Object> probability = (Map<String, Object>)o;
                    if (isSentiment) {
                        requestBodyMap.get('sentiment').add(probability);
                    }else if (probability.containsKey('token') || probability.containsKey('normalizedValue')) {
                        // TODO: NER detection response
                    } else {
                        if (!serviceParams.getDisableIntentDetection()) {
                            requestBodyMap.get('intent').add(probability);
                        }
                    }
                }
                
            }
        }

        ExternalNlpPredictionResult intentResult = EinsteinAiIntentHandler.buildResult(
            requestBodyMap.get('intent'),
            serviceParams.getIntentThreshold());

        ExternalNlpPredictionResult sentimentResult = EinsteinAiSentimentHandler.buildResult(
            requestBodyMap.get('sentiment'),
            serviceParams.getSentimentThreshold());

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentResult.getIntentResults())
            .setSentimentResults(sentimentResult.getSentimentResults())
            .build();
    }

}
