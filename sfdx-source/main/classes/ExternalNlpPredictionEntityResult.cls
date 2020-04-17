global with sharing class ExternalNlpPredictionEntityResult {

    private final Map<String, List<ExternalNlpEntity>> predictedEntities;

    global ExternalNlpPredictionEntityResult(ExternalNlpPredictionEntityResult.Builder builder) {
        this.predictedEntities = builder.predictedEntities;
    }

    global Map<String, List<ExternalNlpEntity>> getPredictedEntities() {
        return this.predictedEntities;
    }

    global class Builder {

        private Map<String, List<ExternalNlpEntity>> predictedEntities;

        global Builder setPredictedEntities(Map<String, List<ExternalNlpEntity>> predictedEntities){
            this.predictedEntities = predictedEntities;
            return this;
        }

        global ExternalNlpPredictionEntityResult build(){
            return new ExternalNlpPredictionEntityResult(this);
        }

    }

}
