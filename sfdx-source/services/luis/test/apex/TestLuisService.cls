@isTest
private class TestLuisService {

    @isTest
    private static void testGetPredictionRequest() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'i want to schedule an appointment for my tesla tomorrow at 9 am';

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
        System.assertNotEquals(null, req.getEndpoint());
        System.assert(req.getEndpoint().contains(EncodingUtil.urlEncode(input, 'UTF-8')), 'input not part of payload');
        System.assertEquals('GET', req.getMethod());
    }
    
    private static ExternalNlpPredictionResult runTestHelper(String input, ExternalNlpService nlpService) {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        
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
        Test.stopTest(); 

        ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
            .setHttpResponses(responses)
            .build();
            
        ExternalNlpPredictionResult result = nlpService.getPredictionResult(getTestServiceParameters(), resultParams);
        

        return result;
    }

    @isTest
    private static void testGetPredictionResultSimple() {
        String input = 'i want to make an appointment to repair my car tomorrow at 8 pm';
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(3, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals('Make_Appointment', result.getIntentResults().getHighestConfidenceIntentName());
        ExternalNlpIntent extIntent = result.getIntentResults().getPredictedIntents().get('Make_Appointment');
        System.assertNotEquals(null, extIntent);
        System.assertEquals('Make_Appointment', extIntent.getName());
        System.assertEquals(Double.valueOf('0.9703875'), extIntent.getConfidenceScore());
        
        System.assertEquals(3, result.getEntityResults().getPredictedEntities().size());
        
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Appointment_Type');
        System.assertNotEquals(null, extEntities);
        System.assertEquals('Appointment_Type', extEntities.get(0).getName());
        System.assertEquals('Repair', extEntities.get(0).getValue());
        System.assertEquals('repair', extEntities.get(0).getMatchedText());
        System.assertEquals(34, extEntities.get(0).getStartIndex());
        System.assertEquals(39, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());

        extEntities = result.getEntityResults().getPredictedEntities().get('Car_Make');
        System.assertEquals('Car_Make', extEntities.get(0).getName());
        System.assertEquals('tesla', extEntities.get(0).getValue());
        System.assertEquals('tesla', extEntities.get(0).getMatchedText());
        System.assertEquals(15, extEntities.get(0).getStartIndex());
        System.assertEquals(19, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());

        extEntities = result.getEntityResults().getPredictedEntities().get('builtin.datetimeV2.datetime');
        System.assertEquals('builtin.datetimeV2.datetime', extEntities.get(0).getName());
        //Fixtures do not provide any offset and hence we are checking with Date generated in GMT with no offset.
        System.assertEquals(DateTime.newInstanceGmt(2019, 08, 26, 20, 0, 0), nlpService.getNormalizedDateTime(extEntities.get(0).getValue()));
        System.assertEquals('tomorrow at 8 pm', extEntities.get(0).getMatchedText());
        System.assertEquals(48, extEntities.get(0).getStartIndex());
        System.assertEquals(63, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultNoIntent() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'noIntentMatch: I want to make a repair appointment for john smith';
        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(3, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals(null, result.getIntentResults().getHighestConfidenceIntentName());

        ExternalNlpIntent extIntent = result.getIntentResults().getPredictedIntents().get('Make_Appointment');
        System.assertNotEquals(null, extIntent);
        System.assertEquals('Make_Appointment', extIntent.getName());
        System.assertEquals(Double.valueOf('0.0970387'), extIntent.getConfidenceScore());

        System.assertEquals(2, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Appointment_Type');
        System.assertNotEquals(null, extEntities);
        System.assertEquals('Appointment_Type', extEntities.get(0).getName());
        System.assertEquals('Repair', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());

        extEntities = result.getEntityResults().getPredictedEntities().get('builtin.personName');
        System.assertEquals('builtin.personName', extEntities.get(0).getName());
        System.assertEquals('john smith', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultNoResolution() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'I want to make a repair appointment for John Smith';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(3, result.getIntentResults().getPredictedIntents().size());
        System.assertEquals('Make_Appointment', result.getIntentResults().getHighestConfidenceIntentName());
        ExternalNlpIntent extIntent = result.getIntentResults().getPredictedIntents().get('Make_Appointment');
        System.assertNotEquals(null, extIntent);
        System.assertEquals('Make_Appointment', extIntent.getName());
        System.assertEquals(Double.valueOf('0.9703875'), extIntent.getConfidenceScore());

        System.assertEquals(2, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Appointment_Type');
        System.assertNotEquals(null, extEntities);
        System.assertEquals('Appointment_Type', extEntities.get(0).getName());
        System.assertEquals('Repair', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());

        extEntities = result.getEntityResults().getPredictedEntities().get('builtin.personName');
        System.assertEquals('builtin.personName', extEntities.get(0).getName());
        System.assertEquals('john smith', extEntities.get(0).getValue());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithRole() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'withRole: i want to make an appointment to repair my car tomorrow at 9 am';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(3, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('DateTime');
        System.assertEquals('DateTime', extEntities.get(0).getName());
        System.assertEquals(DateTime.newInstanceGmt(2019, 08, 23, 9, 0, 0), nlpService.getNormalizedDateTime(extEntities.get(0).getValue()));
        System.assertEquals('friday 9am', extEntities.get(0).getMatchedText());
        System.assertEquals(24, extEntities.get(0).getStartIndex());
        System.assertEquals(33, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithCurrencyEntity() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'search for items under $10.99.';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('builtin.currency');
        System.assertEquals('builtin.currency', extEntities.get(0).getName());
        System.assertEquals(10.99, nlpService.getNormalizedNumber(extEntities.get(0).getValue()));
        System.assertEquals('$10.99', extEntities.get(0).getMatchedText());
        System.assertEquals(23, extEntities.get(0).getStartIndex());
        System.assertEquals(28, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithEmailEntity() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'please send the information to patti.owens@microsoft.com';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('builtin.email');
        System.assertEquals('builtin.email', extEntities.get(0).getName());
        System.assertEquals('patti.owens@microsoft.com', extEntities.get(0).getValue());
        System.assertEquals('patti.owens@microsoft.com', extEntities.get(0).getMatchedText());
        System.assertEquals(31, extEntities.get(0).getStartIndex());
        System.assertEquals(55, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithGeographyV2Entity() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'Carol is visiting the sphinx in gizah egypt in africa before heading to texas';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(6, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('builtin.geographyV2.continent');
        System.assertEquals('builtin.geographyV2.continent', extEntities.get(0).getName());
        System.assertEquals('africa', extEntities.get(0).getValue());
        System.assertEquals('africa', extEntities.get(0).getMatchedText());
        System.assertEquals(47, extEntities.get(0).getStartIndex());
        System.assertEquals(52, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithNumberEntity() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'order two dozen eggs';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('builtin.number');
        System.assertEquals('builtin.number', extEntities.get(0).getName());
        System.assertEquals(24, nlpService.getNormalizedNumber(extEntities.get(0).getValue()));
        System.assertEquals('two dozen', extEntities.get(0).getMatchedText());
        System.assertEquals(6, extEntities.get(0).getStartIndex());
        System.assertEquals(14, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithOrdinalV2Entity() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'what is the second to last choice in the list';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('builtin.ordinalV2.relative');
        System.assertEquals('builtin.ordinalV2.relative', extEntities.get(0).getName());
        System.assertEquals('the second to last', extEntities.get(0).getValue());
        System.assertEquals('the second to last', extEntities.get(0).getMatchedText());
        System.assertEquals(8, extEntities.get(0).getStartIndex());
        System.assertEquals(25, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithPercentageEntity() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'set a trigger when my stock goes up 2%';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('builtin.percentage');
        System.assertEquals('builtin.percentage', extEntities.get(0).getName());
        System.assertEquals('2%', extEntities.get(0).getValue());
        System.assertEquals('2%', extEntities.get(0).getMatchedText());
        System.assertEquals(36, extEntities.get(0).getStartIndex());
        System.assertEquals(37, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithEntityScore() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'Bob Jones wants 3 meatball pho';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Customer');
        System.assertEquals('Customer', extEntities.get(0).getName());
        System.assertEquals('bob jones', extEntities.get(0).getValue());
        System.assertEquals('bob jones', extEntities.get(0).getMatchedText());
        System.assertEquals(0, extEntities.get(0).getStartIndex());
        System.assertEquals(8, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('0.473899543'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithMultipleValuesEntity() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'I want to lookup appointment for tesla and volvo';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Car_Make');
        System.assertEquals('Car_Make', extEntities.get(0).getName());
        System.assertEquals('tesla', extEntities.get(0).getValue());
        System.assertEquals('tesla', extEntities.get(0).getMatchedText());
        System.assertEquals(34, extEntities.get(0).getStartIndex());
        System.assertEquals(38, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());

        System.assertEquals('Car_Make', extEntities.get(1).getName());
        System.assertEquals('volvo', extEntities.get(1).getValue());
        System.assertEquals('volvo', extEntities.get(1).getMatchedText());
        System.assertEquals(44, extEntities.get(1).getStartIndex());
        System.assertEquals(48, extEntities.get(1).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(1).getConfidenceScore());
    }

    @isTest
    private static void testGetPredictionResultWithListEntity() {
        Test.setMock(HttpCalloutMock.class, new LuisAPICalloutMockImpl());
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        String input = 'book 2 tickets to roissy';

        ExternalNlpPredictionResult result = runTestHelper(input, nlpService);
        
        System.assertEquals(1, result.getEntityResults().getPredictedEntities().size());
        List<ExternalNlpEntity> extEntities = result.getEntityResults().getPredictedEntities().get('Cities');
        System.assertEquals('Cities', extEntities.get(0).getName());
        System.assertEquals('Paris', extEntities.get(0).getValue());
        System.assertEquals('roissy', extEntities.get(0).getMatchedText());
        System.assertEquals(18, extEntities.get(0).getStartIndex());
        System.assertEquals(23, extEntities.get(0).getEndIndex());
        System.assertEquals(Double.valueOf('1.0'), extEntities.get(0).getConfidenceScore());
    }

    @isTest
    private static void testGetValidNormalizedValues() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
        Test.startTest();
            System.assertEquals(true, nlpService.getNormalizedBoolean('true'));
            System.assertEquals(false, nlpService.getNormalizedBoolean('false'));
            System.assertEquals(Double.valueOf('3.5'), nlpService.getNormalizedNumber('3.5'));
            System.assertEquals(Double.valueOf('3'), nlpService.getNormalizedNumber('3'));
            System.assertEquals(Date.newinstance(2019, 7, 3), nlpService.getNormalizedDate('2019-07-03'));
            System.assertEquals(DateTime.newInstanceGmt(2019, 7, 3, 9, 15, 5), nlpService.getNormalizedDateTime('2019-07-03T9:15:05'));
        Test.stopTest();
    }

    @isTest
    private static void testGetInvalidNormalizedValues() {
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(LuisService.class);
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
            .setAdditionalParams(null)
            .build();

        return serviceParams;
    }

}