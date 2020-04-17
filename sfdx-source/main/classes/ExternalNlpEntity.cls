global with sharing class ExternalNlpEntity {
    
    private final String name;
    private final String value;
    private final Double confidenceScore;
    private final String matchedText;
    private final Integer startIndex;
    private final Integer endIndex;
    private final String dataType;

    global ExternalNlpEntity(ExternalNlpEntity.Builder builder) {
        this.name = builder.name;
        this.value = builder.value;
        this.confidenceScore = builder.confidenceScore;
        this.matchedText = builder.matchedText;
        this.startIndex = builder.startIndex;
        this.endIndex = builder.endIndex;
        this.dataType = builder.dataType;
    }

    global String getName(){
        return this.name;
    }

    global String getValue(){
        return this.value;
    }

    global Double getConfidenceScore(){
        return this.confidenceScore;
    }

    global String getMatchedText(){
        return this.matchedText;
    }

    global Integer getStartIndex(){
        return this.startIndex;
    }

    global Integer getEndIndex(){
        return this.endIndex;
    }

    global String getDataType(){
        return this.dataType;
    }

    global class Builder {

        private String name;
        private String value;
        private Double confidenceScore;
        private String matchedText;
        private Integer startIndex;
        private Integer endIndex;
        private String dataType;

        global Builder setName(String name){
            this.name = name;
            return this;
        }

        global Builder setValue(String value){
            this.value = value;
            return this;
        }


        global Builder setConfidenceScore(Double confidenceScore){
            this.confidenceScore = confidenceScore;
            return this;
        }

        global Builder setMatchedText(String matchedText){
            this.matchedText = matchedText;
            return this;
        }


        global Builder setStartIndex(Integer startIndex){
            this.startIndex = startIndex;
            return this;
        }

        global Builder setEndIndex(Integer endIndex){
            this.endIndex = endIndex;
            return this;
        }

        global Builder setDataType(String dataType){
            this.dataType = dataType;
            return this;
        }

        global ExternalNlpEntity build(){
            return new ExternalNlpEntity(this);
        }
    }

}
