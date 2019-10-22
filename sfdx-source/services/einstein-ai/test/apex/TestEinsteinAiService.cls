@isTest
private class TestEinsteinAiService {

   @isTest
    private static void testGetPredictionRequest() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(EinsteinAiService.class);
        String input = 'i want to schedule an appointment for my Tesla tomorrow at 9 am';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .setTimeZone(Timezone.getTimeZone('America/New_York'))
            .build();

        Test.startTest();
            List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters(), requestParams);
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
        Test.setMock(HttpCalloutMock.class, new EinstienAiAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(EinsteinAiService.class);
        String input = 'i want to schedule an appointment for my Tesla tomorrow at 9 am';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters(), requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add( h.send(req));
            }
            ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
                .setHttpResponses(responses)
                .build();
            ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestServiceParameters(), resultParams);
        Test.stopTest();
        
        System.assertEquals(3, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals('Make_Appointment', result.getIntentResults().getHighestConfidenceIntentName());
        ExternalNlpIntent extIntent = result.getIntentResults().getPredictedIntents().get('Make_Appointment');
        System.assertNotEquals(null, extIntent);
        System.assertEquals('Make_Appointment', extIntent.getName());
        System.assertEquals(Double.valueOf('0.9984889'), extIntent.getConfidenceScore());
        System.assertEquals(null, result.getEntityResults());
    }

    @isTest
    private static void testGetSentimentPredictionResult() {
        Test.setMock(HttpCalloutMock.class, new EinstienAiAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(EinsteinAiService.class);
        String input = 'i want to schedule an appointment for my Tesla tomorrow at 9 am';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestSentimentServiceParameters(), requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add( h.send(req));
            }
            ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
                .setHttpResponses(responses)
                .build();
            ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestSentimentServiceParameters(), resultParams);
        Test.stopTest();
        
        System.assertEquals(3, result.getSentimentResults().getDocumentSentiment().getPredictedSentiments().size());
        System.assertEquals('positive', result.getSentimentResults().getDocumentSentiment().getHighestConfidenceSentimentName());
        ExternalNlpSentiment extSentiment = result.getSentimentResults().getDocumentSentiment().getPredictedSentiments().get('neutral');
        System.assertNotEquals(null, extSentiment);
        System.assertEquals('neutral', extSentiment.getName());
        System.assertEquals(Double.valueOf('0.00033304645'), extSentiment.getConfidenceScore());
    }

    @isTest
    private static void testGetValidNormalizedValues() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(EinsteinAiService.class);
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
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(EinsteinAiService.class);
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

    private static ExternalNlpServiceParameters getTestServiceParameters() {
        List<ExternalNlpModelParameters> modelParams = new List<ExternalNlpModelParameters>();

        modelParams.add(new ExternalNlpModelParameters.Builder()
            .setModelId('testModelId')
            .setNamedCredentialKey('testKey')
            .build());

        ExternalNlpServiceParameters serviceParams = new ExternalNlpServiceParameters.Builder()
            .setModelParams(modelParams)
            .setIntentThreshold((Double)0.7)
            .setNerThreshold((Double)0.7)
            .setAdditionalParams(null)
            .build();

        return serviceParams;
    }

    private static ExternalNlpServiceParameters getTestSentimentServiceParameters() {
        List<ExternalNlpModelParameters> modelParams = new List<ExternalNlpModelParameters>();

        modelParams.add(new ExternalNlpModelParameters.Builder()
            .setModelId('CommunitySentiment')
            .setNamedCredentialKey('testKey')
            .build());

        ExternalNlpServiceParameters serviceParams = new ExternalNlpServiceParameters.Builder()
            .setModelParams(modelParams)
            .setSentimentThreshold((Double)0.7)
            .setAdditionalParams(null)
            .build();

        return serviceParams;
    }


}
