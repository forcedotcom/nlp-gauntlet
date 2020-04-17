global with sharing class ExternalNlpPredictionSentimentResult {

    private final ExternalNlpDocumentSentiment documentSentiment;

    global ExternalNlpPredictionSentimentResult(ExternalNlpPredictionSentimentResult.Builder builder) {
        this.documentSentiment = builder.documentSentiment;
    }

    global ExternalNlpDocumentSentiment getDocumentSentiment() {
        return this.documentSentiment;
    }

    global class Builder {

        private ExternalNlpDocumentSentiment documentSentiment;

        global Builder setDocumentSentiment(ExternalNlpDocumentSentiment documentSentiment){
            this.documentSentiment = documentSentiment;
            return this;
        }

        global ExternalNlpPredictionSentimentResult build(){
            return new ExternalNlpPredictionSentimentResult(this);
        }

    }

}
