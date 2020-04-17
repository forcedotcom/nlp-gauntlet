global with sharing class ExternalNlpPredictionResultParameters {

    private final List<HttpResponse> httpResponses;

    global ExternalNlpPredictionResultParameters(ExternalNlpPredictionResultParameters.Builder builder) {
        this.httpResponses = builder.httpResponses;
    }

    global List<HttpResponse> getHttpResponses() {
        return this.httpResponses;
    }
    
    global class Builder {
        private List<HttpResponse> httpResponses;

        global Builder setHttpResponses(List<HttpResponse> httpResponses){
            this.httpResponses = httpResponses;
            return this;
        }

        global ExternalNlpPredictionResultParameters build(){
            return new ExternalNlpPredictionResultParameters(this);
        }
    }

}
