public with sharing class ExternalNlpModelParameters {

    private final String namedCredentialKey;
    private final String modelId;

    public ExternalNlpModelParameters(ExternalNlpModelParameters.Builder builder) {
        this.namedCredentialKey = builder.namedCredentialKey;
        this.modelId = builder.modelId;
    }

    public String getNamedCredentialKey() {
        return this.namedCredentialKey;
    }

    public String getModelId() {
        return this.modelId;
    }

    public class Builder {

        private String namedCredentialKey;
        private String modelId;

        public Builder setNamedCredentialKey(String namedCredentialKey){
            this.namedCredentialKey = namedCredentialKey == null ? null : namedCredentialKey.trim();
            return this;
        }

        public Builder setModelId(String modelId){
            this.modelId = modelId == null ? null : modelId.trim();
            return this;
        }

        public ExternalNlpModelParameters build(){
            return new ExternalNlpModelParameters(this);
        }
        
    }

}
