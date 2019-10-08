public with sharing class ExternalNlpPredictionEntityResult {

    private final Map<String, List<ExternalNlpEntity>> predictedEntities;

    public ExternalNlpPredictionEntityResult(ExternalNlpPredictionEntityResult.Builder builder) {
        this.predictedEntities = builder.predictedEntities;
    }

    public Map<String, List<ExternalNlpEntity>> getPredictedEntities() {
        return this.predictedEntities;
    }

    public class Builder {

        private Map<String, List<ExternalNlpEntity>> predictedEntities;

        public Builder setPredictedEntities(Map<String, List<ExternalNlpEntity>> predictedEntities){
            this.predictedEntities = predictedEntities;
            return this;
        }

        public ExternalNlpPredictionEntityResult build(){
            return new ExternalNlpPredictionEntityResult(this);
        }

    }

}
