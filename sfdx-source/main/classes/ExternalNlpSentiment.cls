public with sharing class ExternalNlpSentiment {
    private final String name;
    private final Double confidenceScore;

    public ExternalNlpSentiment(ExternalNlpSentiment.Builder builder) {
        this.name = builder.name;
        this.confidenceScore = builder.confidenceScore;
    }

    public String getName(){
        return this.name;
    }

    public Double getConfidenceScore(){
        return this.confidenceScore;
    }

    public class Builder {

        private String name;
        private Double confidenceScore;

        public Builder setName(String name){
            this.name = name;
            return this;
        }

        public Builder setConfidenceScore(Double confidenceScore){
            this.confidenceScore = confidenceScore;
            return this;
        }

        public ExternalNlpSentiment build(){
            return new ExternalNlpSentiment(this);
        }
        
    }

}
