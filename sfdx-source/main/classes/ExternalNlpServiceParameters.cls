public with sharing class ExternalNlpServiceParameters {

    public final static Double DEFAULT_INTENT_CONFIDENCE_THRESHOLD = 0.7;
    public final static Double DEFAULT_NER_CONFIDENCE_THRESHOLD = 0.7;
    
    private final Double intentThreshold;
    private final Double nerThreshold;
    private final List<ExternalNlpModelParameters> modelParams;
    private final Map<String, String> additionalParams;
    private final Boolean disableIntentDetection;
    private final Boolean disableEntityExtraction;

    public ExternalNlpServiceParameters(ExternalNlpServiceParameters.Builder builder) {
        this.intentThreshold = builder.intentThreshold;
        this.nerThreshold = builder.nerThreshold;
        this.modelParams = builder.modelParams; 
        this.additionalParams = builder.additionalParams;
        this.disableIntentDetection = builder.disableIntentDetection == null ? false : builder.disableIntentDetection;
        this.disableEntityExtraction = builder.disableEntityExtraction == null ? false : builder.disableEntityExtraction;
    }

    public Double getIntentThreshold() {
        return this.intentThreshold == null ? DEFAULT_INTENT_CONFIDENCE_THRESHOLD : this.intentThreshold;
    }

    public Double getNerThreshold() {
        return this.nerThreshold == null ? DEFAULT_NER_CONFIDENCE_THRESHOLD : this.nerThreshold;
    }

    public List<ExternalNlpModelParameters> getModelParams() {
        return this.modelParams;
    }

    public Map<String, String> getAdditionalParams() {
        return this.additionalParams;
    }

    public Boolean getDisableIntentDetection() {
        return this.disableIntentDetection;
    }

    public Boolean getDisableEntityExtraction() {
        return this.disableEntityExtraction;
    }

    public class Builder {

        private Double intentThreshold;
        private Double nerThreshold;
        private Map<String, String> additionalParams;
        private List<ExternalNlpModelParameters> modelParams;
        private Boolean disableIntentDetection;
        private Boolean disableEntityExtraction;

        public Builder setIntentThreshold(Double intentThreshold){
            this.intentThreshold = intentThreshold;
            return this;
        }

        public Builder setNerThreshold(Double nerThreshold){
            this.nerThreshold = nerThreshold;
            return this;
        }

        public Builder setModelParams(List<ExternalNlpModelParameters> modelParams){
            this.modelParams = modelParams;
            return this;
        }

        public Builder setAdditionalParams(Map<String, String> additionalParams){
            this.additionalParams = additionalParams;
            return this;
        }

        public Builder setDisableIntentDetection(Boolean disableIntentDetection){
            this.disableIntentDetection = disableIntentDetection;
            return this;
        }

        public Builder setDisableEntityExtraction(Boolean disableEntityExtraction){
            this.disableEntityExtraction = disableEntityExtraction;
            return this;
        }

        public ExternalNlpServiceParameters build(){
            return new ExternalNlpServiceParameters(this);
        }
        
    }

}
