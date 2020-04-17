global with sharing class ExternalNlpPredictionRequestParameters {

    private final String input;
    private final String language;
    private final TimeZone timeZone;

    global ExternalNlpPredictionRequestParameters(ExternalNlpPredictionRequestParameters.Builder builder){
        this.input = builder.input;
        this.language = builder.language;
        this.timeZone = builder.timeZone;
    }

    global String getInput() {
        return this.input;
    }

    global String getLanguage() {
        return this.language;
    }

    global TimeZone getTimeZone() {
        return this.timeZone;
    }

    global class Builder {
        private String input;
        private String language;
        private TimeZone timeZone;

        global Builder setInput(String input){
            this.input = input != null ? input.trim() : null;
            return this;
        }

        global Builder setLanguage(String language){
            this.language = language;
            return this;
        }

        global Builder setTimeZone(TimeZone timeZone){
            this.timeZone = timeZone;
            return this;
        }

        global ExternalNlpPredictionRequestParameters build(){
            return new ExternalNlpPredictionRequestParameters(this);
        }
    }

}
