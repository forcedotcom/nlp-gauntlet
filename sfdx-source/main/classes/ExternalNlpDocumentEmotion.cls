public with sharing class ExternalNlpDocumentEmotion {

    private final Map<String, ExternalNlpEmotion> predictedEmotions;
    private final String highestConfidenceEmotionName;

    public ExternalNlpDocumentEmotion(ExternalNlpDocumentEmotion.Builder builder) {
        this.predictedEmotions = builder.predictedEmotions;
        this.highestConfidenceEmotionName = builder.highestConfidenceEmotionName;
    }

    public Map<String, ExternalNlpEmotion> getPredictedEmotions() {
        return this.predictedEmotions;
    }

    public String getHighestConfidenceEmotionName() {
        return this.highestConfidenceEmotionName;
    }

    public class Builder {

        private Map<String, ExternalNlpEmotion> predictedEmotions;
        private String highestConfidenceEmotionName;

        public Builder setPredictedEmotions(Map<String, ExternalNlpEmotion> predictedEmotions){
            this.predictedEmotions = predictedEmotions;
            return this;
        }

        public Builder setHighestConfidenceEmotionName(String emotionName){
            this.highestConfidenceEmotionName = emotionName;
            return this;
        }

        public ExternalNlpDocumentEmotion build(){
            return new ExternalNlpDocumentEmotion(this);
        }

    }

}
