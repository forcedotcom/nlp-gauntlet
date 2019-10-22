@isTest
private class TestExternalNlpServiceFactory {

    @isTest
    private static void testFactoryWithParameters() {
        Test.startTest();
        ExternalNlpService nlpService = ExternalNlpServiceFactory.makeNlpService(
                    ExternalNlpMockService.class);
            System.assertNotEquals(null, nlpService);
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