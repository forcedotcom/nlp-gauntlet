@RestResource(urlMapping='/ExternalNlpMockModelAPI/*')
global with sharing class ExternalNlpMockModelAPI {

    // Update this map to include any intents / entities you're interested in
    private static final Map<String, Set<String>> INTENT_MATCH_MAP = new Map<String,Set<String>> {
        'Make_Appointment' => new Set<String>{
            'make appointment',
            'make an appointment',
            'schedule appointment',
            'schedule an appointment'
        },
        'Lookup_Appointment' => new Set<String>{
            'lookup appointment',
            'lookup my appointment',
            'find appointment',
            'find my appointment'
        }
    };

    private static final Map<String, Set<String>> ENTITY_MATCH_MAP = new Map<String,Set<String>> {
        'Car_Make' => new Set<String>{
            'Tesla',
            'Honda',
            'Audi'
        },
        'Appointment_Type' => new Set<String>{
            'Repair',
            'Maintenance'
        }
    };

    @HttpPost
    global static PredictionResponse doPrediction(String message, String language, String timeZone) {
        //TODO: Handle language & time zone
        PredictionResponse response = new PredictionResponse();
        response.intents.addAll(findIntentMatches(message));
        response.entities.addAll(findEntityMatches(message));
        return response;
    }

    /**
    * Dummy methods used for sinmple matching based on map values
    */
    private static List<IntentPredictionResponse> findIntentMatches(String message) {
        List<IntentPredictionResponse> intentPredictions = new List<IntentPredictionResponse>();
        for (String intentName : INTENT_MATCH_MAP.keySet()) {
            Set<String> matchPhrases = INTENT_MATCH_MAP.get(intentName);
            if (matchPhrases == null) { continue; }
            for (String matchPhrase : matchPhrases){
                if (!message.containsIgnoreCase(matchPhrase)) { continue; }
                intentPredictions.add(new IntentPredictionResponse(intentName, (Double)1.0));
            }
        }
        return intentPredictions;
    }
    
    private static List<EntityPredictionResponse> findEntityMatches(String message) {
        List<EntityPredictionResponse> entityPredictions = new List<EntityPredictionResponse>();
        for (String entityName : ENTITY_MATCH_MAP.keySet()) {
            Set<String> matchValues = ENTITY_MATCH_MAP.get(entityName);
            if (matchValues == null) { continue; }
            for (String matchValue : matchValues){
                if (!message.containsIgnoreCase(matchValue)) { continue; }
                entityPredictions.add(new EntityPredictionResponse(entityName, (Double)1.0, matchValue));
            }
        }
        return entityPredictions;
    }

    /**
    * Mock user-defined apex classes to simulate prediction responses
    */
    global class PredictionResponse {
        global List<IntentPredictionResponse> intents{get;set;}
        global List<EntityPredictionResponse> entities{get;set;}

        global PredictionResponse(){
            intents = new List<IntentPredictionResponse>();
            entities = new List<EntityPredictionResponse>();
        }
    }

    global class IntentPredictionResponse{
        global String name;
        global Double probability;

        global IntentPredictionResponse(String name, Double probability) {
            this.name = name;
            this.probability = probability;
        }
    }

    global class EntityPredictionResponse{
        global String name;
        global Double probability;
        global String value;

        global EntityPredictionResponse(String name, Double probability, String value) {
            this.name = name;
            this.probability = probability;
            this.value = value;
        }
    }

}