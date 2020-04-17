global with sharing class ExternalNlpDocumentTone {

    private final Map<String, ExternalNlpTone> predictedTones;
    private final String highestConfidenceToneName;

    global ExternalNlpDocumentTone(ExternalNlpDocumentTone.Builder builder) {
        this.predictedTones = builder.predictedTones;
        this.highestConfidenceToneName = builder.highestConfidenceToneName;
    }

    global Map<String, ExternalNlpTone> getPredictedTones() {
        return this.predictedTones;
    }

    global String getHighestConfidenceToneName() {
        return this.highestConfidenceToneName;
    }

    global class Builder {

        private Map<String, ExternalNlpTone> predictedTones;
        private String highestConfidenceToneName;

        global Builder setPredictedTones(Map<String, ExternalNlpTone> predictedTones){
            this.predictedTones = predictedTones;
            return this;
        }

        global Builder setHighestConfidenceToneName(String toneName){
            this.highestConfidenceToneName = toneName;
            return this;
        }

        global ExternalNlpDocumentTone build(){
            return new ExternalNlpDocumentTone(this);
        }

    }

}
