public with sharing class ExternalNlpPredictionEmotionResult {

    private final ExternalNlpDocumentEmotion documentEmotion;

    public ExternalNlpPredictionEmotionResult(ExternalNlpPredictionEmotionResult.Builder builder) {
        this.documentEmotion = builder.documentEmotion;
    }

    public ExternalNlpDocumentEmotion getDocumentEmotion() {
        return this.documentEmotion;
    }

    public class Builder {

        private ExternalNlpDocumentEmotion documentEmotion;

        public Builder setDocumentEmotion(ExternalNlpDocumentEmotion documentEmotion){
            this.documentEmotion = documentEmotion;
            return this;
        }

        public ExternalNlpPredictionEmotionResult build(){
            return new ExternalNlpPredictionEmotionResult(this);
        }

    }

}