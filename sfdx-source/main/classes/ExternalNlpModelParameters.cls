global with sharing class ExternalNlpModelParameters {

    private final String namedCredentialKey;
    private final String modelId;

    global ExternalNlpModelParameters(ExternalNlpModelParameters.Builder builder) {
        this.namedCredentialKey = builder.namedCredentialKey;
        this.modelId = builder.modelId;
    }

    global String getNamedCredentialKey() {
        return this.namedCredentialKey;
    }

    global String getModelId() {
        return this.modelId;
    }

    global class Builder {

        private String namedCredentialKey;
        private String modelId;

        global Builder setNamedCredentialKey(String namedCredentialKey){
            this.namedCredentialKey = namedCredentialKey == null ? null : namedCredentialKey.trim();
            return this;
        }

        global Builder setModelId(String modelId){
            this.modelId = modelId == null ? null : modelId.trim();
            return this;
        }

        global ExternalNlpModelParameters build(){
            return new ExternalNlpModelParameters(this);
        }
        
    }

}
