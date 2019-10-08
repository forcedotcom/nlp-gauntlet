public with sharing class ExternalNlpPredictionToneResult {

    private final ExternalNlpDocumentTone documentTone;

    public ExternalNlpPredictionToneResult(ExternalNlpPredictionToneResult.Builder builder) {
        this.documentTone = builder.documentTone;
    }

    public ExternalNlpDocumentTone getDocumentTone() {
        return this.documentTone;
    }

    public class Builder {

        private ExternalNlpDocumentTone documentTone;

        public Builder setDocumentTone(ExternalNlpDocumentTone documentTone){
            this.documentTone = documentTone;
            return this;
        }

        public ExternalNlpPredictionToneResult build(){
            return new ExternalNlpPredictionToneResult(this);
        }

    }

}
