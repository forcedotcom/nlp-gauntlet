public with sharing class EinsteinAiService extends ExternalNlpService {

    public EinsteinAiService(ExternalNlpServiceParameters serviceParams){
        this.serviceParams = serviceParams;
    }

    public override List<HttpRequest> getPredictionRequests(ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : this.serviceParams.getModelParams()) {
            if (!this.serviceParams.getDisableIntentDetection()) {
                reqs.add(EinsteinAiIntentHandler.buildRequest(modelParams, params));
            }
        }

        return reqs;
    }

    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpPredictionResultParameters params) {
        List<HttpResponse> responses = params.getHttpResponses();

        Map<String, List<Map<String, Object>>> requestBodyMap = new Map<String, List<Map<String, Object>>>{
            'intent' => new List<Map<String, Object>>()
        };

        for (HttpResponse response : responses) {
            if(response.getStatusCode() != 200){ throw new ExternalNlpServiceException(
                'Received unexpected response code : '+response.getStatusCode(),
                ExternalNlpServiceExceptionCode.INVALID_HTTP_RESPONSE_CODE); }

            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            List<Object> probabilities = (List<Object>)bodyMap.get('probabilities');

            if(probabilities != null && !probabilities.isEmpty()) {
                for(Object o : probabilities) {
                    Map<String, Object> probability = (Map<String, Object>)o;
                    if (probability.containsKey('token') || probability.containsKey('normalizedValue')) {
                        // TODO: NER detection response
                    } else {
                        if (!this.serviceParams.getDisableIntentDetection()) {
                            requestBodyMap.get('intent').add(probability);
                        }
                    }
                }
            }
        }

        ExternalNlpPredictionResult intentResult = EinsteinAiIntentHandler.buildResult(
            requestBodyMap.get('intent'),
            this.serviceParams.getIntentThreshold());

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentResult.getIntentResults())
            .build();
    }

}
