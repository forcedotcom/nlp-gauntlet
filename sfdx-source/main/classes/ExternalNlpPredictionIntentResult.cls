public with sharing class ExternalNlpPredictionIntentResult {

    private final Map<String, ExternalNlpIntent> predictedIntents;
    private final String highestConfidenceIntentName;

    public ExternalNlpPredictionIntentResult(ExternalNlpPredictionIntentResult.Builder builder) {
        this.predictedIntents = builder.predictedIntents;
        this.highestConfidenceIntentName = builder.highestConfidenceIntentName;
    }

    public Map<String, ExternalNlpIntent> getPredictedIntents() {
        return this.predictedIntents;
    }

    public String getHighestConfidenceIntentName() {
        return this.highestConfidenceIntentName;
    }

    public class Builder {

        private Map<String, ExternalNlpIntent> predictedIntents;
        private String highestConfidenceIntentName;

        public Builder setPredictedIntents(Map<String, ExternalNlpIntent> predictedIntents){
            this.predictedIntents = predictedIntents;
            return this;
        }

        public Builder setHighestConfidenceIntentName(String intentName){
            this.highestConfidenceIntentName = intentName;
            return this;
        }

        public ExternalNlpPredictionIntentResult build(){
            return new ExternalNlpPredictionIntentResult(this);
        }

    }

}
