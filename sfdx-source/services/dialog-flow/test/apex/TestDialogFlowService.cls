@isTest
private class TestDialogFlowService {

    @isTest
    private static void testGetPredictionRequest() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(DialogFlowService.class);

        String input = 'i want to schedule an appointment for my Tesla tomorrow at 9 am';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        Test.startTest();
            List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters(), requestParams);
        Test.stopTest();

        System.assertNotEquals(null, reqs);
        System.assertNotEquals(0, reqs.size());
        HttpRequest req = reqs.get(0);
        System.assertNotEquals(null, req.getBody());
        System.assert(req.getBody().contains(input), 'input not part of payload');
        System.assertEquals('POST', req.getMethod());
    }

    @isTest
    private static void testGetPredictionResult() {
        Test.setMock(HttpCalloutMock.class, new DialogFlowAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(DialogFlowService.class);

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
        
        System.assertEquals(1, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals('Make_Appointment', result.getIntentResults().getHighestConfidenceIntentName());
        ExternalNlpIntent extIntent = result.getIntentResults().getPredictedIntents().get('Make_Appointment');
        System.assertNotEquals(null, extIntent);
        System.assertEquals('Make_Appointment', extIntent.getName());
        System.assertEquals(Double.valueOf('0.8421737'), extIntent.getConfidenceScore());
        System.assertEquals(3, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Car_Make');
        System.assertNotEquals(null, extEntities);
        System.assertEquals('Car_Make', extEntities.get(0).getName());
        System.assertEquals('Tesla', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
        System.assertEquals(1, result.getSentimentResults().getDocumentSentiment().getPredictedSentiments().size());
        System.assertEquals('positive', result.getSentimentResults().getDocumentSentiment().getHighestConfidenceSentimentName());
        Map<String, ExternalNlpSentiment> extSentimentsMap = result.getSentimentResults().getDocumentSentiment().getPredictedSentiments();
        System.assertEquals('positive', extSentimentsMap.get('positive').getName());
        System.assertEquals(Double.valueOf('0.8'), extSentimentsMap.get('positive').getConfidenceScore());
        System.assertEquals(Double.valueOf('0.8'), extSentimentsMap.get('positive').getMagnitude());
    }

    @isTest
    private static void testGetValidNormalizedValues() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(DialogFlowService.class);

        Test.startTest();
            System.assertEquals('Test', nlpService.getNormalizedText('Test'));
            System.assertEquals('Jonathan Rico', nlpService.getNormalizedText('{ "name": "Jonathan Rico" }'));
            System.assertEquals(true, nlpService.getNormalizedBoolean('true'));
            System.assertEquals(false, nlpService.getNormalizedBoolean('false'));
            System.assertEquals(Double.valueOf('3.5'), nlpService.getNormalizedNumber('3.5'));
            System.assertEquals(Double.valueOf('3'), nlpService.getNormalizedNumber('3'));
            System.assertEquals(Date.newinstance(2019, 7, 3), nlpService.getNormalizedDate('2019-07-03T12:00:00-07:00'));
            System.assertEquals(DateTime.newinstance(2019, 7, 3, 9, 15, 5), nlpService.getNormalizedDateTime('{"date_time": "2019-07-03T09:15:05-07:00"}'));
            System.assertEquals(DateTime.newinstance(2019, 7, 3, 9, 15, 5), nlpService.getNormalizedDateTime('2019-07-03T09:15:05-07:00'));
        Test.stopTest();
    }

    @isTest
    private static void testGetInvalidNormalizedValues() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(DialogFlowService.class);

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
            .setIntentThreshold((Double)0.75)
            .setNerThreshold((Double)0.75)
            .setAdditionalParams(new Map<String, String>{'sessionId'=>'123456'})
            .build();

        return serviceParams;
    }

}
