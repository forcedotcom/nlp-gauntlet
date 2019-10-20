public with sharing class ExternalNlpPredictionSentimentResult {

    private final ExternalNlpDocumentSentiment documentSentiment;

    public ExternalNlpPredictionSentimentResult(ExternalNlpPredictionSentimentResult.Builder builder) {
        this.documentSentiment = builder.documentSentiment;
    }

    public ExternalNlpDocumentSentiment getDocumentSentiment() {
        return this.documentSentiment;
    }

    public class Builder {

        private ExternalNlpDocumentSentiment documentSentiment;

        public Builder setDocumentSentiment(ExternalNlpDocumentSentiment documentSentiment){
            this.documentSentiment = documentSentiment;
            return this;
        }

        public ExternalNlpPredictionSentimentResult build(){
            return new ExternalNlpPredictionSentimentResult(this);
        }

    }

}
