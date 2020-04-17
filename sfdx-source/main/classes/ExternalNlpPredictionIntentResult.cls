global with sharing class ExternalNlpPredictionIntentResult {

    private final Map<String, ExternalNlpIntent> predictedIntents;
    private final String highestConfidenceIntentName;

    global ExternalNlpPredictionIntentResult(ExternalNlpPredictionIntentResult.Builder builder) {
        this.predictedIntents = builder.predictedIntents;
        this.highestConfidenceIntentName = builder.highestConfidenceIntentName;
    }

    global Map<String, ExternalNlpIntent> getPredictedIntents() {
        return this.predictedIntents;
    }

    global String getHighestConfidenceIntentName() {
        return this.highestConfidenceIntentName;
    }

    global class Builder {

        private Map<String, ExternalNlpIntent> predictedIntents;
        private String highestConfidenceIntentName;

        global Builder setPredictedIntents(Map<String, ExternalNlpIntent> predictedIntents){
            this.predictedIntents = predictedIntents;
            return this;
        }

        global Builder setHighestConfidenceIntentName(String intentName){
            this.highestConfidenceIntentName = intentName;
            return this;
        }

        global ExternalNlpPredictionIntentResult build(){
            return new ExternalNlpPredictionIntentResult(this);
        }

    }

}
