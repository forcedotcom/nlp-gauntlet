public with sharing class ExternalNlpPredictionRequestParameters {

    private final String input;
    private final String language;
    private final TimeZone timeZone;

    public ExternalNlpPredictionRequestParameters(ExternalNlpPredictionRequestParameters.Builder builder){
        this.input = builder.input;
        this.language = builder.language;
        this.timeZone = builder.timeZone;
    }

    public String getInput() {
        return this.input;
    }

    public String getLanguage() {
        return this.language;
    }

    public TimeZone getTimeZone() {
        return this.timeZone;
    }

    public class Builder {
        private String input;
        private String language;
        private TimeZone timeZone;

        public Builder setInput(String input){
            this.input = input != null ? input.trim() : null;
            return this;
        }

        public Builder setLanguage(String language){
            this.language = language;
            return this;
        }

        public Builder setTimeZone(TimeZone timeZone){
            this.timeZone = timeZone;
            return this;
        }

        public ExternalNlpPredictionRequestParameters build(){
            return new ExternalNlpPredictionRequestParameters(this);
        }
    }

}
