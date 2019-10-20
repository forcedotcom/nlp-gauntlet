public with sharing class ExternalNlpSentiment {
    private final String name;
    private final Double confidenceScore;
    private final Double magnitude; //indicates how much emotional content is present within the document

    public ExternalNlpSentiment(ExternalNlpSentiment.Builder builder) {
        this.name = builder.name;
        this.confidenceScore = builder.confidenceScore;
        this.magnitude = builder.magnitude;
    }

    public String getName(){
        return this.name;
    }

    public Double getConfidenceScore(){
        return this.confidenceScore;
    }

    public Double getMagnitude(){
        return this.magnitude;
    }

    public class Builder {

        private String name;
        private Double confidenceScore;
        private Double magnitude;

        public Builder setName(String name){
            this.name = name;
            return this;
        }

        public Builder setConfidenceScore(Double confidenceScore){
            this.confidenceScore = confidenceScore;
            return this;
        }

        public Builder setMagnitude(Double magnitude){
            this.magnitude = magnitude;
            return this;
        }

        public ExternalNlpSentiment build(){
            return new ExternalNlpSentiment(this);
        }
        
    }

}
