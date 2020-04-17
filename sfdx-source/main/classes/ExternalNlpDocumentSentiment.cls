global with sharing class ExternalNlpDocumentSentiment {

    private final Map<String, ExternalNlpSentiment> predictedSentiments;
    private final String highestConfidenceSentimentName;

    global ExternalNlpDocumentSentiment(ExternalNlpDocumentSentiment.Builder builder) {
        this.predictedSentiments = builder.predictedSentiments;
        this.highestConfidenceSentimentName = builder.highestConfidenceSentimentName;
    }

    global Map<String, ExternalNlpSentiment> getPredictedSentiments() {
        return this.predictedSentiments;
    }

    global String getHighestConfidenceSentimentName() {
        return this.highestConfidenceSentimentName;
    }

    global class Builder {

        private Map<String, ExternalNlpSentiment> predictedSentiments;
        private String highestConfidenceSentimentName;

        global Builder setPredictedSentiments(Map<String, ExternalNlpSentiment> predictedSentiments){
            this.predictedSentiments = predictedSentiments;
            return this;
        }

        global Builder setHighestConfidenceSentimentName(String sentimentName){
            this.highestConfidenceSentimentName = sentimentName;
            return this;
        }

        global ExternalNlpDocumentSentiment build(){
            return new ExternalNlpDocumentSentiment(this);
        }

    }

}
