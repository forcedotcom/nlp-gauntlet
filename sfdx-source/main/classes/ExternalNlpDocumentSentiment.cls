public with sharing class ExternalNlpDocumentSentiment {

    private final Map<String, ExternalNlpSentiment> predictedSentiments;
    private final String highestConfidenceSentimentName;

    public ExternalNlpDocumentSentiment(ExternalNlpDocumentSentiment.Builder builder) {
        this.predictedSentiments = builder.predictedSentiments;
        this.highestConfidenceSentimentName = builder.highestConfidenceSentimentName;
    }

    public Map<String, ExternalNlpSentiment> getPredictedSentiments() {
        return this.predictedSentiments;
    }

    public String getHighestConfidenceSentimentName() {
        return this.highestConfidenceSentimentName;
    }

    public class Builder {

        private Map<String, ExternalNlpSentiment> predictedSentiments;
        private String highestConfidenceSentimentName;

        public Builder setPredictedSentiments(Map<String, ExternalNlpSentiment> predictedSentiments){
            this.predictedSentiments = predictedSentiments;
            return this;
        }

        public Builder setHighestConfidenceSentimentName(String sentimentName){
            this.highestConfidenceSentimentName = sentimentName;
            return this;
        }

        public ExternalNlpDocumentSentiment build(){
            return new ExternalNlpDocumentSentiment(this);
        }

    }

}
