public with sharing class WatsonService extends ExternalNlpService {

    private static final Set<String> WATSON_NLU_MODELS = new Set<String>{
        'Emotion',
        'Sentiment'
    };

    public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();
        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
            if (modelParams.getModelId() == 'Tone') {
                reqs.add(WatsonToneAnalyzerHandler.buildRequest(modelParams, params));
            } else if (WATSON_NLU_MODELS.clone().removeAll(modelParams.getModelId().split(','))) {
                reqs.add(WatsonNluHandler.buildRequest(modelParams, params));
            } else {
                reqs.add(WatsonAssistantHandler.buildRequest(modelParams, params));
            }
        }
        return reqs;
    }

    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionResultParameters params) {

        Map<String, List<Map<String, Object>>> requestBodyMap = new Map<String, List<Map<String, Object>>>{
            'intent_ner' => new List<Map<String, Object>>(),
            'tone' => new List<Map<String, Object>>(),
            'nlu' => new List<Map<String, Object>>()
        };

        for (HttpResponse response :  params.getHttpResponses()) {
            if(response.getStatusCode() != 200){ 
                if (response.getStatusCode() == 400) {
                    try{
                        Map<String, Object> errorMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                        String errorMessage = errorMap == null ? null : String.valueOf(errorMap.get('error'));
                        // Skip responses with specific error messages
                        if (errorMessage == 'unsupported text language: unknown') { continue;}
                    } catch (Exception e){
                        System.debug(e);
                    }
                }
                throw new ExternalNlpServiceException(
                'Received unexpected response code : '+response.getStatusCode(),
                ExternalNlpServiceExceptionCode.INVALID_HTTP_RESPONSE_CODE); 
                
            }

            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            if (bodyMap.containsKey('entities') || bodyMap.containsKey('intents')) {
                requestBodyMap.get('intent_ner').add(bodyMap);
            } else if (bodyMap.containsKey('document_tone')) {
                requestBodyMap.get('tone').add(bodyMap);
            } else if (bodyMap.containsKey('emotion') || bodyMap.containsKey('sentiment')) {
                    requestBodyMap.get('nlu').add(bodyMap);
            }
        }

        ExternalNlpPredictionResult intentNerResult = WatsonAssistantHandler.buildResult(requestBodyMap.get('intent_ner')
            ,serviceParams.getIntentThreshold()
            ,serviceParams.getNerThreshold()
            ,serviceParams.getDisableIntentDetection()
            ,serviceParams.getDisableEntityExtraction());
        ExternalNlpPredictionResult toneResult = WatsonToneAnalyzerHandler.buildResult(requestBodyMap.get('tone'));
        ExternalNlpPredictionResult nluResult = WatsonNluHandler.buildResult(requestBodyMap.get('nlu')
            ,serviceParams.getSentimentThreshold()
            ,serviceParams.getDisableSentimentDetection());

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentNerResult.getIntentResults())
            .setEntityResults(intentNerResult.getEntityResults())
            .setToneResults(toneResult.getToneResults())
            .setEmotionResults(nluResult.getEmotionResults())
            .setSentimentResults(nluResult.getSentimentResults())
            .build();
    }

}
