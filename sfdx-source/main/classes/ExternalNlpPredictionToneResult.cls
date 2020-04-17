global with sharing class ExternalNlpPredictionToneResult {

    private final ExternalNlpDocumentTone documentTone;

    global ExternalNlpPredictionToneResult(ExternalNlpPredictionToneResult.Builder builder) {
        this.documentTone = builder.documentTone;
    }

    global ExternalNlpDocumentTone getDocumentTone() {
        return this.documentTone;
    }

    global class Builder {

        private ExternalNlpDocumentTone documentTone;

        global Builder setDocumentTone(ExternalNlpDocumentTone documentTone){
            this.documentTone = documentTone;
            return this;
        }

        global ExternalNlpPredictionToneResult build(){
            return new ExternalNlpPredictionToneResult(this);
        }

    }

}
