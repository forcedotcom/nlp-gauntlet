public with sharing class ExternalNlpPredictionResultParameters {

    private final List<HttpResponse> httpResponses;

    public ExternalNlpPredictionResultParameters(ExternalNlpPredictionResultParameters.Builder builder) {
        this.httpResponses = builder.httpResponses;
    }

    public List<HttpResponse> getHttpResponses() {
        return this.httpResponses;
    }
    
    public class Builder {
        private List<HttpResponse> httpResponses;

        public Builder setHttpResponses(List<HttpResponse> httpResponses){
            this.httpResponses = httpResponses;
            return this;
        }

        public ExternalNlpPredictionResultParameters build(){
            return new ExternalNlpPredictionResultParameters(this);
        }
    }

}
