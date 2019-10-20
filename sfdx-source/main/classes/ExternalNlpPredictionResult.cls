public with sharing class ExternalNlpPredictionResult {

    private final ExternalNlpPredictionIntentResult intentResults;
    private final ExternalNlpPredictionEntityResult entityResults;
    private final ExternalNlpPredictionToneResult toneResults;
    private final ExternalNlpPredictionEmotionResult emotionResults;
    private final ExternalNlpPredictionSentimentResult sentimentResults;

    public ExternalNlpPredictionResult(ExternalNlpPredictionResult.Builder builder) {
        this.intentResults = builder.intentResults;
        this.entityResults = builder.entityResults;
        this.toneResults = builder.toneResults;
        this.emotionResults = builder.emotionResults;
        this.sentimentResults = builder.sentimentResults;
    }

    public ExternalNlpPredictionIntentResult getIntentResults() {
        return this.intentResults;
    }

    public ExternalNlpPredictionEntityResult getEntityResults() {
        return this.entityResults;
    }

    public ExternalNlpPredictionToneResult getToneResults() {
        return this.toneResults;
    }

    public ExternalNlpPredictionEmotionResult getEmotionResults() {
        return this.emotionResults;
    }

    public ExternalNlpPredictionSentimentResult getSentimentResults() {
        return this.sentimentResults;
    }

    public class Builder {

        private ExternalNlpPredictionIntentResult intentResults;
        private ExternalNlpPredictionEntityResult entityResults;
        private ExternalNlpPredictionToneResult toneResults;
        private ExternalNlpPredictionEmotionResult emotionResults;
        private ExternalNlpPredictionSentimentResult sentimentResults;

        public Builder setIntentResults(ExternalNlpPredictionIntentResult intentResults) {
            this.intentResults = intentResults;
            return this;
        }

        public Builder setEntityResults(ExternalNlpPredictionEntityResult entityResults) {
            this.entityResults = entityResults;
            return this;
        }

        public Builder setToneResults(ExternalNlpPredictionToneResult toneResults) {
            this.toneResults = toneResults;
            return this;
        }

        public Builder setEmotionResults(ExternalNlpPredictionEmotionResult emotionResults) {
            this.emotionResults = emotionResults;
            return this;
        }

        public Builder setSentimentResults(ExternalNlpPredictionSentimentResult sentimentResults) {
            this.sentimentResults = sentimentResults;
            return this;
        }

        public ExternalNlpPredictionResult build(){
            return new ExternalNlpPredictionResult(this);
        }

    }

}
