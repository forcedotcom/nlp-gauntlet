public with sharing class WatsonService extends ExternalNlpService {

    public WatsonService(ExternalNlpServiceParameters serviceParams){
        this.serviceParams = serviceParams;
    }

    public override List<HttpRequest> getPredictionRequests(ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();
        for(ExternalNlpModelParameters modelParams : this.serviceParams.getModelParams()) {
            if (modelParams.getModelId() == 'Tone') {
                reqs.add(WatsonToneAnalyzerHandler.buildRequest(modelParams, params));
            } else if (modelParams.getModelId() == 'Emotion') {
                reqs.add(WatsonNluHandler.buildRequest(modelParams, params));
            } else {
                reqs.add(WatsonAssistantHandler.buildRequest(modelParams, params));
            }
        }
        return reqs;
    }

    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpPredictionResultParameters params) {

        Map<String, List<Map<String, Object>>> requestBodyMap = new Map<String, List<Map<String, Object>>>{
            'intent_ner' => new List<Map<String, Object>>(),
            'tone' => new List<Map<String, Object>>(),
            'emotion' => new List<Map<String, Object>>()
        };

        for (HttpResponse response :  params.getHttpResponses()) {
            if(response.getStatusCode() != 200){ throw new ExternalNlpServiceException(
                'Received unexpected response code : '+response.getStatusCode(),
                ExternalNlpServiceExceptionCode.INVALID_HTTP_RESPONSE_CODE); }

            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            if (bodyMap.containsKey('entities') || bodyMap.containsKey('intents')) {
                requestBodyMap.get('intent_ner').add(bodyMap);
            } else if (bodyMap.containsKey('document_tone')) {
                requestBodyMap.get('tone').add(bodyMap);
            } else if (bodyMap.containsKey('emotion')) {
                requestBodyMap.get('emotion').add(bodyMap);
            }
        }

        ExternalNlpPredictionResult intentNerResult = WatsonAssistantHandler.buildResult(requestBodyMap.get('intent_ner')
            ,serviceParams.getIntentThreshold()
            ,serviceParams.getNerThreshold()
            ,serviceParams.getDisableIntentDetection()
            ,serviceParams.getDisableEntityExtraction());
        ExternalNlpPredictionResult toneResult = WatsonToneAnalyzerHandler.buildResult(requestBodyMap.get('tone'));
        ExternalNlpPredictionResult emotionResult = WatsonNluHandler.buildResult(requestBodyMap.get('emotion'));

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentNerResult.getIntentResults())
            .setEntityResults(intentNerResult.getEntityResults())
            .setToneResults(toneResult.getToneResults())
            .setEmotionResults(emotionResult.getEmotionResults())
            .build();
    }

}
