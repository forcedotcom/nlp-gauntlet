public with sharing class ExternalNlpPredictionResult {

    private final ExternalNlpPredictionIntentResult intentResults;
    private final ExternalNlpPredictionEntityResult entityResults;
    private final ExternalNlpPredictionToneResult toneResults;
    private final ExternalNlpPredictionEmotionResult emotionResults;

    public ExternalNlpPredictionResult(ExternalNlpPredictionResult.Builder builder) {
        this.intentResults = builder.intentResults;
        this.entityResults = builder.entityResults;
        this.toneResults = builder.toneResults;
        this.emotionResults = builder.emotionResults;
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

    public class Builder {

        private ExternalNlpPredictionIntentResult intentResults;
        private ExternalNlpPredictionEntityResult entityResults;
        private ExternalNlpPredictionToneResult toneResults;
        private ExternalNlpPredictionEmotionResult emotionResults;

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

        public ExternalNlpPredictionResult build(){
            return new ExternalNlpPredictionResult(this);
        }

    }

}
