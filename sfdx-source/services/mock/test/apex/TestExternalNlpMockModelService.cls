@isTest
private class TestExternalNlpMockModelService {

    @isTest
    private static void testGetPredictionRequest() {
        Test.setMock(HttpCalloutMock.class, new ExternalNlpMockModelAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(ExternalNlpMockModelService.class);
        String input = 'i want to make an appointment';

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
        System.assertNotEquals(null, req);
        System.assertNotEquals(null, req.getBody());
        System.assert(req.getBody().contains(input), 'input not part of payload');
        System.assertEquals('POST', req.getMethod());
    }

    @isTest
    private static void testSingleIntentMatch() {
        Test.setMock(HttpCalloutMock.class, new ExternalNlpMockModelAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(ExternalNlpMockModelService.class);
        String input = 'i want to make an appointment for my tesla please';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters(), requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add(h.send(req));
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
        System.assertEquals(Double.valueOf('1.0'), extIntent.getConfidenceScore());
        System.assertEquals(0, result.getEntityResults().getPredictedEntities().size());
    }

    @isTest
    private static void testSingleEntityMatch() {
        Test.setMock(HttpCalloutMock.class, new ExternalNlpMockModelAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(ExternalNlpMockModelService.class);
        String input = 'i want to make an appointment for my tesla';

        ExternalNlpPredictionRequestParameters requestParams = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage('en_US')
            .build();

        List<HttpRequest> reqs = nlpService.getPredictionRequests(getTestServiceParameters(), requestParams);

        Test.startTest();
            Http h = new Http();
            List<HttpResponse> responses = new List<HttpResponse>();
            for(HttpRequest req : reqs) {
                responses.add(h.send(req));
            }
            ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
                .setHttpResponses(responses)
                .build();
                
            ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestServiceParameters(), resultParams);
        Test.stopTest();
        
        System.assertEquals(1, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());

        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Car_Make');
        System.assertNotEquals(null, extEntities);
        System.assertEquals('Car_Make', extEntities.get(0).getName());
        System.assertEquals('Tesla', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());

    }

    @isTest
    private static void testMultipleEntityMatch() {
        Test.setMock(HttpCalloutMock.class, new ExternalNlpMockModelAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(ExternalNlpMockModelService.class);
        String input = 'i want to make an appointment to repair my tesla';

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
        System.assertEquals(2, result.getEntityResults().getPredictedEntities().size());

        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Car_Make');
        System.assertNotEquals(null, extEntities);
        System.assertEquals('Car_Make', extEntities.get(0).getName());
        System.assertEquals('Tesla', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());

        extEntities = result.getEntityResults().getPredictedEntities().get('Appointment_Type');
        System.assertNotEquals(null, extEntities);
        System.assertEquals('Appointment_Type', extEntities.get(0).getName());
        System.assertEquals('Repair', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());

    }

    private static ExternalNlpServiceParameters getTestServiceParameters() {
        List<ExternalNlpModelParameters> modelParams = new List<ExternalNlpModelParameters>();

        modelParams.add(new ExternalNlpModelParameters.Builder()
            .setModelId('ExternalNlpMockModelAPI')
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
