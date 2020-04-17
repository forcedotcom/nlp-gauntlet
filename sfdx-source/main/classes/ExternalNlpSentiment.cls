global with sharing class ExternalNlpSentiment {
    private final String name;
    private final Double confidenceScore;
    private final Double magnitude; //indicates how much emotional content is present within the document

    global ExternalNlpSentiment(ExternalNlpSentiment.Builder builder) {
        this.name = builder.name;
        this.confidenceScore = builder.confidenceScore;
        this.magnitude = builder.magnitude;
    }

    global String getName(){
        return this.name;
    }

    global Double getConfidenceScore(){
        return this.confidenceScore;
    }

    global Double getMagnitude(){
        return this.magnitude;
    }

    global class Builder {

        private String name;
        private Double confidenceScore;
        private Double magnitude;

        global Builder setName(String name){
            this.name = name;
            return this;
        }

        global Builder setConfidenceScore(Double confidenceScore){
            this.confidenceScore = confidenceScore;
            return this;
        }

        global Builder setMagnitude(Double magnitude){
            this.magnitude = magnitude;
            return this;
        }

        global ExternalNlpSentiment build(){
            return new ExternalNlpSentiment(this);
        }
        
    }

}
