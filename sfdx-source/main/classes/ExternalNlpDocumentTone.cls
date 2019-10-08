public with sharing class ExternalNlpDocumentTone {

    private final Map<String, ExternalNlpTone> predictedTones;
    private final String highestConfidenceToneName;

    public ExternalNlpDocumentTone(ExternalNlpDocumentTone.Builder builder) {
        this.predictedTones = builder.predictedTones;
        this.highestConfidenceToneName = builder.highestConfidenceToneName;
    }

    public Map<String, ExternalNlpTone> getPredictedTones() {
        return this.predictedTones;
    }

    public String getHighestConfidenceToneName() {
        return this.highestConfidenceToneName;
    }

    public class Builder {

        private Map<String, ExternalNlpTone> predictedTones;
        private String highestConfidenceToneName;

        public Builder setPredictedTones(Map<String, ExternalNlpTone> predictedTones){
            this.predictedTones = predictedTones;
            return this;
        }

        public Builder setHighestConfidenceToneName(String toneName){
            this.highestConfidenceToneName = toneName;
            return this;
        }

        public ExternalNlpDocumentTone build(){
            return new ExternalNlpDocumentTone(this);
        }

    }

}
