global with sharing class ExternalNlpPredictionResult {

    private final ExternalNlpPredictionIntentResult intentResults;
    private final ExternalNlpPredictionEntityResult entityResults;
    private final ExternalNlpPredictionToneResult toneResults;
    private final ExternalNlpPredictionEmotionResult emotionResults;
    private final ExternalNlpPredictionSentimentResult sentimentResults;

    global ExternalNlpPredictionResult(ExternalNlpPredictionResult.Builder builder) {
        this.intentResults = builder.intentResults;
        this.entityResults = builder.entityResults;
        this.toneResults = builder.toneResults;
        this.emotionResults = builder.emotionResults;
        this.sentimentResults = builder.sentimentResults;
    }

    global ExternalNlpPredictionIntentResult getIntentResults() {
        return this.intentResults;
    }

    global ExternalNlpPredictionEntityResult getEntityResults() {
        return this.entityResults;
    }

    global ExternalNlpPredictionToneResult getToneResults() {
        return this.toneResults;
    }

    global ExternalNlpPredictionEmotionResult getEmotionResults() {
        return this.emotionResults;
    }

    global ExternalNlpPredictionSentimentResult getSentimentResults() {
        return this.sentimentResults;
    }

    global class Builder {

        private ExternalNlpPredictionIntentResult intentResults;
        private ExternalNlpPredictionEntityResult entityResults;
        private ExternalNlpPredictionToneResult toneResults;
        private ExternalNlpPredictionEmotionResult emotionResults;
        private ExternalNlpPredictionSentimentResult sentimentResults;

        global Builder setIntentResults(ExternalNlpPredictionIntentResult intentResults) {
            this.intentResults = intentResults;
            return this;
        }

        global Builder setEntityResults(ExternalNlpPredictionEntityResult entityResults) {
            this.entityResults = entityResults;
            return this;
        }

        global Builder setToneResults(ExternalNlpPredictionToneResult toneResults) {
            this.toneResults = toneResults;
            return this;
        }

        global Builder setEmotionResults(ExternalNlpPredictionEmotionResult emotionResults) {
            this.emotionResults = emotionResults;
            return this;
        }

        global Builder setSentimentResults(ExternalNlpPredictionSentimentResult sentimentResults) {
            this.sentimentResults = sentimentResults;
            return this;
        }

        global ExternalNlpPredictionResult build(){
            return new ExternalNlpPredictionResult(this);
        }

    }

}
