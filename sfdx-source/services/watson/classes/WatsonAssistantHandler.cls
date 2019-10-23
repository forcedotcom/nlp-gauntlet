public with sharing class WatsonAssistantHandler {

    private static final String API_VERSION = '2019-02-28';

    // API Docs: https://cloud.ibm.com/apidocs/assistant#get-response-to-user-input
    // NOTE: V2 of the Assistant API requires creating a session which we don't need for just doing NLU
    public static HttpRequest buildRequest(ExternalNlpModelParameters modelParams, ExternalNlpPredictionRequestParameters reqParams) {
        String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
        endpoint += '/assistant/api/v1/workspaces/'+modelParams.getModelId()+'/message?version='+API_VERSION;

        Map<String, Object> queryInputMap = new Map<String,Object>{
            'input' => new Map<String,Object>{
                'text' => reqParams.getInput()
            }
        };

        String body = JSON.serialize(queryInputMap);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');

        if (body != null) {
            req.setBody(body);
        }
        req.setHeader('Content-Type', 'application/json');
        return req;
    }

    public static ExternalNlpPredictionResult buildResult(List<Map<String, Object>> responseMap,
        Double intentConfidenceThreshold, Double nerConfidenceThreshold,
        Boolean disableIntentDetection, Boolean disableEntityExtraction) {

        Map<String, ExternalNlpIntent> intentsMap = new Map<String, ExternalNlpIntent>();
        ExternalNlpIntent highestScoringExtIntent = null;
        Map<String, List<ExternalNlpEntity>> entitiesMap = new Map<String, List<ExternalNlpEntity>>();

        for (Map<String, Object> bodyMap : responseMap) {
            if (!disableIntentDetection) {
                // Intent Detection
                highestScoringExtIntent = detectIntents(bodyMap, intentsMap, highestScoringExtIntent);
            }
            if (!disableEntityExtraction) {
                // Named Entity Recognition
                detectEntities(bodyMap, entitiesMap, nerConfidenceThreshold);
            }
        }

        String highestConfidenceIntentName = null;
        if (highestScoringExtIntent != null && highestScoringExtIntent.getConfidenceScore() >= intentConfidenceThreshold) {
            highestConfidenceIntentName = highestScoringExtIntent.getName();
        }

        ExternalNlpPredictionIntentResult intentPredResult = new ExternalNlpPredictionIntentResult.Builder()
            .setHighestConfidenceIntentName(highestConfidenceIntentName)
            .setPredictedIntents(intentsMap)
            .build();

        ExternalNlpPredictionEntityResult entityPredResult = new ExternalNlpPredictionEntityResult.Builder()
            .setPredictedEntities(entitiesMap)
            .build();

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentPredResult)
            .setEntityResults(entityPredResult)
            .build();
    }

    private static ExternalNlpIntent detectIntents(Map<String, Object> bodyMap, Map<String, ExternalNlpIntent> intentsMap, ExternalNlpIntent highestScoringExtIntent) {

        List<Object> intents = (List<Object>)bodyMap.get('intents');
        if (intents == null || intents.isEmpty()) { return highestScoringExtIntent; }

        for (Object o : intents) {
            Map<String, Object> intent = (Map<String, Object>)o;
            String intentName = (String)intent.get('intent');
            Double intentDetectionConfidence = (Double)intent.get('confidence');
            ExternalNlpIntent extIntent = new ExternalNlpIntent.Builder()
                                                    .setName(intentName)
                                                    .setConfidenceScore(intentDetectionConfidence)
                                                    .build();
            intentsMap.put(extIntent.getName(), extIntent);

            if (highestScoringExtIntent == null || intentDetectionConfidence > highestScoringExtIntent.getConfidenceScore()) {
                highestScoringExtIntent = extIntent;
            }
        }

        return highestScoringExtIntent;
    }

    private static void detectEntities(Map<String, Object> bodyMap, Map<String, List<ExternalNlpEntity>> entitiesMap, Double nerConfidenceThreshold) {
        List<Object> entities = (List<Object>)bodyMap.get('entities');
        if (entities == null || entities.isEmpty()) { return; }
        for(Object o : entities) {
            Map<String, Object> entity = (Map<String, Object>)o;
            String entityValue = String.valueOf(entity.get('value'));
            Double entityDetectionConfidence = (Double)entity.get('confidence');
            String entityName = (String)entity.get('entity');
            if (entityDetectionConfidence < nerConfidenceThreshold) { continue; }
            if (!entitiesMap.containsKey(entityName)) {
                entitiesMap.put(entityName, new List<ExternalNlpEntity>());
            }
            entitiesMap.get(entityName).add(new ExternalNlpEntity.Builder()
                                            .setName(entityName)
                                            .setValue(entityValue)
                                            .setConfidenceScore(entityDetectionConfidence)
                                            .build());
        }
    }

}
