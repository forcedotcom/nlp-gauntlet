@isTest
private class TestWatsonService {

    @isTest
    private static void testGetPredictionRequest() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help, Mark was helping me.';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        Test.startTest();
            List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('testModelId'), requestParams);
        Test.stopTest();

        System.assertNotEquals(null, reqs);
        System.assertNotEquals(0, reqs.size());
        HttpRequest req = reqs.get(0);
        System.assertNotEquals(null, req);
        System.assertNotEquals(null, req.getBody());
        System.assert(req.getBody().contains(input), 'input not part of payload');
        System.assertEquals('POST', req.getMethod());
    }

   @isTest
    private static void testGetTonePredictionRequest() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help, Mark was helping me.';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        Test.startTest();
            List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('Tone'), requestParams);
        Test.stopTest();

        System.assertNotEquals(null, reqs);
        System.assertNotEquals(0, reqs.size());
        HttpRequest req = reqs.get(0);
        System.assertNotEquals(null, req);
        System.assertNotEquals(null, req.getBody());
        System.assert(req.getBody().contains(input), 'input not part of payload');
        System.assertEquals('POST', req.getMethod());
    }

   @isTest
    private static void testGetEmotionPredictionRequest() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help, Mark was helping me.';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        Test.startTest();
            List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('Emotion'), requestParams);
        Test.stopTest();

        System.assertNotEquals(null, reqs);
        System.assertNotEquals(0, reqs.size());
        HttpRequest req = reqs.get(0);
        System.assertNotEquals(null, req);
        System.assertNotEquals(null, req.getBody());
        System.assert(req.getBody().contains(input), 'input not part of payload');
        System.assertEquals('POST', req.getMethod());
    }

   @isTest
    private static void testGetSentimentPredictionRequest() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help, Mark was helping me.';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        Test.startTest();
            List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('Sentiment'), requestParams);
        Test.stopTest();

        System.assertNotEquals(null, reqs);
        System.assertNotEquals(0, reqs.size());
        HttpRequest req = reqs.get(0);
        System.assertNotEquals(null, req);
        System.assertNotEquals(null, req.getBody());
        System.assert(req.getBody().contains(input), 'input not part of payload');
        System.assertEquals('POST', req.getMethod());
    }

    @isTest
    private static void testGetPredictionResult() {
        Test.setMock(HttpCalloutMock.class, new WatsonAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help, Mark was helping me.';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('testModelId'),requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add( h.send(req));
            }
            ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
                .setHttpResponses(responses)
                .build();
                
            ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestServiceParameters('testModelId'), resultParams);
        Test.stopTest();
        
        System.assertEquals(2, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals('General_Greetings', result.getIntentResults().getHighestConfidenceIntentName());
        ExternalNlpIntent extIntent = result.getIntentResults().getPredictedIntents().get(result.getIntentResults().getHighestConfidenceIntentName());
        System.assertNotEquals(null, extIntent);
        System.assertEquals(result.getIntentResults().getHighestConfidenceIntentName(), extIntent.getName());
        System.assertEquals(Double.valueOf('0.9728985071182251'), extIntent.getConfidenceScore());
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('sys-person');
        System.assertNotEquals(null, extEntities);
        System.assertEquals('sys-person', extEntities.get(0).getName());
        System.assertEquals('Mark', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('0.98885'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetTonePredictionResult() {
        Test.setMock(HttpCalloutMock.class, new WatsonAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help!';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('Tone'), requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add( h.send(req));
            }
            ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
                .setHttpResponses(responses)
                .build();
                
            ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestServiceParameters('Tone'), resultParams);
        Test.stopTest();
        
        System.assertEquals(0, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals(0, result.getEntityResults().getPredictedEntities().size());
        System.assertNotEquals(null, result.getToneResults());
        System.assertEquals(2, result.getToneResults().getDocumentTone().getPredictedTones().size());
        System.assertEquals('Analytical', result.getToneResults().getDocumentTone().getHighestConfidenceToneName());
        Map<String, ExternalNlpTone> extTonesMap = result.getToneResults().getDocumentTone().getPredictedTones();
        System.assertEquals('Sadness', extTonesMap.get('Sadness').getName());
        System.assertEquals(Double.valueOf('0.6165'), extTonesMap.get('Sadness').getConfidenceScore());
    }

    @isTest
    private static void testGetEmotionPredictionResult() {
        Test.setMock(HttpCalloutMock.class, new WatsonAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help!';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('Emotion'), requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add( h.send(req));
            }
            ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
                .setHttpResponses(responses)
                .build();
                
            ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestServiceParameters('Emotion'), resultParams);
        Test.stopTest();
        
        System.assertEquals(0, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals(0, result.getEntityResults().getPredictedEntities().size());
        System.assertEquals(null, result.getToneResults());
        System.assertEquals(null, result.getSentimentResults());
        System.assertNotEquals(null, result.getEmotionResults());
        System.assertEquals(5, result.getEmotionResults().getDocumentEmotion().getPredictedEmotions().size());
        System.assertEquals('sadness', result.getEmotionResults().getDocumentEmotion().getHighestConfidenceEmotionName());
        Map<String, ExternalNlpEmotion> extEmotionsMap = result.getEmotionResults().getDocumentEmotion().getPredictedEmotions();
        System.assertEquals('sadness', extEmotionsMap.get('sadness').getName());
        System.assertEquals(Double.valueOf('0.765311'), extEmotionsMap.get('sadness').getConfidenceScore());
    }

    @isTest
    private static void testGetSentimentPredictionResult() {
        Test.setMock(HttpCalloutMock.class, new WatsonAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help!';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('Sentiment'), requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add( h.send(req));
            }
            ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
                .setHttpResponses(responses)
                .build();
                
            ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestServiceParameters('Sentiment'), resultParams);
        Test.stopTest();
        
        System.assertEquals(0, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals(0, result.getEntityResults().getPredictedEntities().size());
        System.assertEquals(null, result.getToneResults());
        System.assertEquals(null, result.getEmotionResults());
        System.assertNotEquals(null, result.getSentimentResults());

        System.assertEquals(1, result.getSentimentResults().getDocumentSentiment().getPredictedSentiments().size());
        System.assertEquals('positive', result.getSentimentResults().getDocumentSentiment().getHighestConfidenceSentimentName());
        Map<String, ExternalNlpSentiment> extSentimentsMap = result.getSentimentResults().getDocumentSentiment().getPredictedSentiments();
        System.assertEquals('positive', extSentimentsMap.get('positive').getName());
        System.assertEquals(Double.valueOf('0.765311'), extSentimentsMap.get('positive').getConfidenceScore());
    }

    @isTest
    private static void testGetEmotionAndSentimentPredictionResult() {
        Test.setMock(HttpCalloutMock.class, new WatsonAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        String input = 'Hello I need help!';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters('Emotion,Sentiment'), requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add( h.send(req));
            }
            ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
                .setHttpResponses(responses)
                .build();
                
            ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestServiceParameters('Emotion,Sentiment'), resultParams);
        Test.stopTest();
        
        System.assertEquals(0, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals(0, result.getEntityResults().getPredictedEntities().size());
        System.assertEquals(null, result.getToneResults());
        System.assertNotEquals(null, result.getEmotionResults());
        System.assertNotEquals(null, result.getSentimentResults());
        System.assertEquals(1, result.getSentimentResults().getDocumentSentiment().getPredictedSentiments().size());
        System.assertEquals('positive', result.getSentimentResults().getDocumentSentiment().getHighestConfidenceSentimentName());
        Map<String, ExternalNlpSentiment> extSentimentsMap = result.getSentimentResults().getDocumentSentiment().getPredictedSentiments();
        System.assertEquals('positive', extSentimentsMap.get('positive').getName());
        System.assertEquals(Double.valueOf('0.765311'), extSentimentsMap.get('positive').getConfidenceScore());

        System.assertEquals(5, result.getEmotionResults().getDocumentEmotion().getPredictedEmotions().size());
        System.assertEquals('sadness', result.getEmotionResults().getDocumentEmotion().getHighestConfidenceEmotionName());
        Map<String, ExternalNlpEmotion> extEmotionsMap = result.getEmotionResults().getDocumentEmotion().getPredictedEmotions();
        System.assertEquals('sadness', extEmotionsMap.get('sadness').getName());
        System.assertEquals(Double.valueOf('0.765311'), extEmotionsMap.get('sadness').getConfidenceScore());
    }

    @isTest
    private static void testGetValidNormalizedValues() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        Test.startTest();
            System.assertEquals(true, nlpService.getNormalizedBoolean('true'));
            System.assertEquals(false, nlpService.getNormalizedBoolean('false'));
            System.assertEquals(Double.valueOf('3.5'), nlpService.getNormalizedNumber('3.5'));
            System.assertEquals(Double.valueOf('3'), nlpService.getNormalizedNumber('3'));
            System.assertEquals(Date.newinstance(2019, 7, 3), nlpService.getNormalizedDate('2019-07-03T12:00:00-07:00'));
            System.assertEquals(DateTime.newinstance(2019, 7, 3, 9, 15, 5), nlpService.getNormalizedDateTime('2019-07-03T09:15:05-07:00'));
        Test.stopTest();
    }

    @isTest
    private static void testGetInvalidNormalizedValues() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(WatsonService.class);
        Test.startTest();
            try{
                nlpService.getNormalizedBoolean(null);
                System.assert(false, 'Expected nlp service exception');
            }catch(ExternalNlpServiceException e){
                System.assertEquals(ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR, e.getExceptionCode());
            }
            try{
                nlpService.getNormalizedNumber('not a number');
                System.assert(false, 'Expected nlp service exception');
            }catch(ExternalNlpServiceException e){
                System.assertEquals(ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR, e.getExceptionCode());
            }
            try{
                nlpService.getNormalizedDate('not a date');
                System.assert(false, 'Expected nlp service exception');
            }catch(ExternalNlpServiceException e){
                System.assertEquals(ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR, e.getExceptionCode());
            }
            try{
                nlpService.getNormalizedDateTime('not a date time');
                System.assert(false, 'Expected nlp service exception');
            }catch(ExternalNlpServiceException e){
                System.assertEquals(ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR, e.getExceptionCode());
            }
        Test.stopTest();
    }

    private static ExternalNlpServiceParameters getTestServiceParameters(String modelId) {
        List<ExternalNlpModelParameters> modelParams = new List<ExternalNlpModelParameters>();

        modelParams.add(new ExternalNlpModelParameters.Builder()
            .setModelId(modelId)
            .setNamedCredentialKey('testKey')
            .build());

        ExternalNlpServiceParameters serviceParams = new ExternalNlpServiceParameters.Builder()
            .setModelParams(modelParams)
            .setIntentThreshold((Double)0.75)
            .setNerThreshold((Double)0.75)
            .setAdditionalParams(null)
            .build();

        return serviceParams;
    }

}
