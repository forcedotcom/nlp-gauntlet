global with sharing class ExternalNlpDocumentEmotion {

    private final Map<String, ExternalNlpEmotion> predictedEmotions;
    private final String highestConfidenceEmotionName;

    global ExternalNlpDocumentEmotion(ExternalNlpDocumentEmotion.Builder builder) {
        this.predictedEmotions = builder.predictedEmotions;
        this.highestConfidenceEmotionName = builder.highestConfidenceEmotionName;
    }

    global Map<String, ExternalNlpEmotion> getPredictedEmotions() {
        return this.predictedEmotions;
    }

    global String getHighestConfidenceEmotionName() {
        return this.highestConfidenceEmotionName;
    }

    global class Builder {

        private Map<String, ExternalNlpEmotion> predictedEmotions;
        private String highestConfidenceEmotionName;

        global Builder setPredictedEmotions(Map<String, ExternalNlpEmotion> predictedEmotions){
            this.predictedEmotions = predictedEmotions;
            return this;
        }

        global Builder setHighestConfidenceEmotionName(String emotionName){
            this.highestConfidenceEmotionName = emotionName;
            return this;
        }

        global ExternalNlpDocumentEmotion build(){
            return new ExternalNlpDocumentEmotion(this);
        }

    }

}
