@isTest
private class TestExternalNlpMockModelAPI {

    @isTest
    private static void testPredictionWithNoMatches() {
        ExternalNlpMockModelAPI.PredictionResponse response = ExternalNlpMockModelAPI.doPrediction('this is a test', 'en_US', 'America/Los_Angeles');
        System.assertEquals(0, response.intents.size());
        System.assertEquals(0, response.entities.size());
    }

    @isTest
    private static void testPredictionWithIntentMatches() {
        ExternalNlpMockModelAPI.PredictionResponse response = ExternalNlpMockModelAPI.doPrediction('i want to make an appointment', null, null);
        System.assertEquals(1, response.intents.size());
        System.assertEquals(0, response.entities.size());
    }

    @isTest
    private static void testPredictionWithEntityMatches() {
        ExternalNlpMockModelAPI.PredictionResponse response = ExternalNlpMockModelAPI.doPrediction('i want to make an appointment for my tesla', 'en_US', null);
        System.assertEquals(1, response.intents.size());
        System.assertEquals(1, response.entities.size());
    }

}
