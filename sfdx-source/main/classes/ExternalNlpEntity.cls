public with sharing class ExternalNlpEntity {
    
    private final String name;
    private final String value;
    private final Double confidenceScore;
    private final String matchedText;
    private final Integer startIndex;
    private final Integer endIndex;
    private final String dataType;

    public ExternalNlpEntity(ExternalNlpEntity.Builder builder) {
        this.name = builder.name;
        this.value = builder.value;
        this.confidenceScore = builder.confidenceScore;
        this.matchedText = builder.matchedText;
        this.startIndex = builder.startIndex;
        this.endIndex = builder.endIndex;
        this.dataType = builder.dataType;
    }

    public String getName(){
        return this.name;
    }

    public String getValue(){
        return this.value;
    }

    public Double getConfidenceScore(){
        return this.confidenceScore;
    }

    public String getMatchedText(){
        return this.matchedText;
    }

    public Integer getStartIndex(){
        return this.startIndex;
    }

    public Integer getEndIndex(){
        return this.endIndex;
    }

    public String getDataType(){
        return this.dataType;
    }

    public class Builder {

        private String name;
        private String value;
        private Double confidenceScore;
        private String matchedText;
        private Integer startIndex;
        private Integer endIndex;
        private String dataType;

        public Builder setName(String name){
            this.name = name;
            return this;
        }

        public Builder setValue(String value){
            this.value = value;
            return this;
        }


        public Builder setConfidenceScore(Double confidenceScore){
            this.confidenceScore = confidenceScore;
            return this;
        }

        public Builder setMatchedText(String matchedText){
            this.matchedText = matchedText;
            return this;
        }


        public Builder setStartIndex(Integer startIndex){
            this.startIndex = startIndex;
            return this;
        }

        public Builder setEndIndex(Integer endIndex){
            this.endIndex = endIndex;
            return this;
        }

        public Builder setDataType(String dataType){
            this.dataType = dataType;
            return this;
        }

        public ExternalNlpEntity build(){
            return new ExternalNlpEntity(this);
        }
    }

}
