global with sharing class ExternalNlpPredictionEmotionResult {

    private final ExternalNlpDocumentEmotion documentEmotion;

    global ExternalNlpPredictionEmotionResult(ExternalNlpPredictionEmotionResult.Builder builder) {
        this.documentEmotion = builder.documentEmotion;
    }

    global ExternalNlpDocumentEmotion getDocumentEmotion() {
        return this.documentEmotion;
    }

    global class Builder {

        private ExternalNlpDocumentEmotion documentEmotion;

        global Builder setDocumentEmotion(ExternalNlpDocumentEmotion documentEmotion){
            this.documentEmotion = documentEmotion;
            return this;
        }

        global ExternalNlpPredictionEmotionResult build(){
            return new ExternalNlpPredictionEmotionResult(this);
        }

    }

}