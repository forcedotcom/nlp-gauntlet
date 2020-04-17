global with sharing class ExternalNlpServiceParameters {

    global final static Double DEFAULT_INTENT_CONFIDENCE_THRESHOLD = 0.7;
    global final static Double DEFAULT_NER_CONFIDENCE_THRESHOLD = 0.7;
    global final static Double DEFAULT_SENTIMENT_CONFIDENCE_THRESHOLD = 0.7;

    private final Double intentThreshold;
    private final Double nerThreshold;
    private final Double sentimentThreshold;

    private final List<ExternalNlpModelParameters> modelParams;
    private final Map<String, String> additionalParams;
    private final Boolean disableIntentDetection;
    private final Boolean disableEntityExtraction;
    private final Boolean disableSentimentDetection;

    global ExternalNlpServiceParameters(ExternalNlpServiceParameters.Builder builder) {
        this.intentThreshold = builder.intentThreshold;
        this.nerThreshold = builder.nerThreshold;
        this.sentimentThreshold = builder.sentimentThreshold;
        this.modelParams = builder.modelParams; 
        this.additionalParams = builder.additionalParams;
        this.disableIntentDetection = builder.disableIntentDetection == null ? false : builder.disableIntentDetection;
        this.disableEntityExtraction = builder.disableEntityExtraction == null ? false : builder.disableEntityExtraction;
        this.disableSentimentDetection = builder.disableSentimentDetection == null ? false : builder.disableSentimentDetection;
    }

    global Double getIntentThreshold() {
        return this.intentThreshold == null ? DEFAULT_INTENT_CONFIDENCE_THRESHOLD : this.intentThreshold;
    }

    global Double getNerThreshold() {
        return this.nerThreshold == null ? DEFAULT_NER_CONFIDENCE_THRESHOLD : this.nerThreshold;
    }

    global Double getSentimentThreshold() {
        return this.sentimentThreshold == null ? DEFAULT_SENTIMENT_CONFIDENCE_THRESHOLD : this.sentimentThreshold;
    }

    global List<ExternalNlpModelParameters> getModelParams() {
        return this.modelParams;
    }

    global Map<String, String> getAdditionalParams() {
        return this.additionalParams;
    }

    global Boolean getDisableIntentDetection() {
        return this.disableIntentDetection;
    }

    global Boolean getDisableEntityExtraction() {
        return this.disableEntityExtraction;
    }

    global Boolean getDisableSentimentDetection() {
        return this.disableSentimentDetection;
    }

    global class Builder {

        private Double intentThreshold;
        private Double nerThreshold;
        private Double sentimentThreshold;
        private Map<String, String> additionalParams;
        private List<ExternalNlpModelParameters> modelParams;
        private Boolean disableIntentDetection;
        private Boolean disableEntityExtraction;
        private Boolean disableSentimentDetection;

        global Builder setIntentThreshold(Double intentThreshold){
            this.intentThreshold = intentThreshold;
            return this;
        }

        global Builder setNerThreshold(Double nerThreshold){
            this.nerThreshold = nerThreshold;
            return this;
        }

        global Builder setSentimentThreshold(Double sentimentThreshold){
            this.sentimentThreshold = sentimentThreshold;
            return this;
        }

        global Builder setModelParams(List<ExternalNlpModelParameters> modelParams){
            this.modelParams = modelParams;
            return this;
        }

        global Builder setAdditionalParams(Map<String, String> additionalParams){
            this.additionalParams = additionalParams;
            return this;
        }

        global Builder setDisableIntentDetection(Boolean disableIntentDetection){
            this.disableIntentDetection = disableIntentDetection;
            return this;
        }

        global Builder setDisableEntityExtraction(Boolean disableEntityExtraction){
            this.disableEntityExtraction = disableEntityExtraction;
            return this;
        }

        global Builder setDisableSentimentDetection(Boolean disableSentimentDetection){
            this.disableSentimentDetection = disableSentimentDetection;
            return this;
        }

        global ExternalNlpServiceParameters build(){
            return new ExternalNlpServiceParameters(this);
        }
        
    }

}
