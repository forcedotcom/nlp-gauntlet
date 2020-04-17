global with sharing class ExternalNlpIntent {
    private final String name;
    private final Double confidenceScore;

    global ExternalNlpIntent(ExternalNlpIntent.Builder builder) {
        this.name = builder.name;
        this.confidenceScore = builder.confidenceScore;
    }

    global String getName(){
        return this.name;
    }

    global Double getConfidenceScore(){
        return this.confidenceScore;
    }

    global class Builder {

        private String name;
        private Double confidenceScore;

        global Builder setName(String name){
            this.name = name;
            return this;
        }

        global Builder setConfidenceScore(Double confidenceScore){
            this.confidenceScore = confidenceScore;
            return this;
        }

        global ExternalNlpIntent build(){
            return new ExternalNlpIntent(this);
        }
        
    }

}
