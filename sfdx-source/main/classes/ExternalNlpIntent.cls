public with sharing class ExternalNlpIntent {
    private final String name;
    private final Double confidenceScore;

    public ExternalNlpIntent(ExternalNlpIntent.Builder builder) {
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

        public ExternalNlpIntent build(){
            return new ExternalNlpIntent(this);
        }
        
    }

}
