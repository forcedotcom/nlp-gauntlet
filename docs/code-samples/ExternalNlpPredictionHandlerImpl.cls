public class ExternalNlpPredictionHandlerImpl implements NLPPredictions.PredictionHandler {

    /**
    * By default, this handler maps external intents to bot intents based on direct name match
    * If intents cannot be matched by name directly, the following map can be updated with the corresponding mappings.
    */
    private static final Map<String, String> CUSTOM_INTENT_MAPPINGS = new Map<String, String>{
        'EXTERNAL_INTENT_NAME' => 'INTERNAL_INTENT_NAME'
    };
    
    /**
    * By default, this handler maps external entities to bot entities based on direct name match
    * If entities in global Intent Sets are being used or if entities cannot be matched by name directly
    * The following map can be updated with the corresponding mappings.
    * 
    * For example:
    * If your Bot is using entities in a global intent set, you must provide the fully qualified name in this map
    *    'Appointment_Type' => 'Car_Dealership_External.Appointment_Type'
    * If your Bot has a local entity that doesn't have a direct match to the external entity, you can set the mapping to this 
    *    'External_Apt_Type' => 'Appointment_Type'
    *
    */
    private static final Map<String, String> CUSTOM_ENTITY_MAPPINGS = new Map<String, String>{
        'EXTERNAL_ENTITY_NAME' => 'FULLY_QUALIFIED_SLOT_CLASS_NAME'
    };

    /**
    * ExternalNLP classes are convenience classes that consolidate all the 
    * request setup / response mappings in a single place.
    */
    
    /**
    * Replace with your external nlp service class
    * NOTE: Reading Custom metadata in PredictionHandler is not supported at the moment
    */
    private ExternalNLPService getExternalNLPService() {
        return ExternalNlpServiceFactory.makeNlpService(DialogFlowService.class);
    }

    /**
    * Replace with your external nlp service provider configuration parameters
    */
    private ExternalNlpServiceParameters getExternalNlpServiceParameters(Boolean disableIntentDetection, Boolean disableEntityExtraction) {
        // Update these parameters to use a different service provider
        List<ExternalNlpModelParameters> modelParams = new List<ExternalNlpModelParameters>();
        modelParams.add(new ExternalNlpModelParameters.Builder()
            .setModelId('YOUR_MODEL_ID')
            .setNamedCredentialKey('YOUR_NAMED_CREDENTIAL') // Case-sensitive
            .build());

        ExternalNlpServiceParameters serviceParams = new ExternalNlpServiceParameters.Builder()
            .setModelParams(modelParams)
            .setIntentThreshold((Double)0.7)
            .setNerThreshold((Double)0.7)
            .setAdditionalParams(new Map<String, String>())
            .setDisableIntentDetection(disableIntentDetection)
            .setDisableEntityExtraction(disableEntityExtraction)
            .build();
       return serviceParams;
    }

    // Setup the http requests
    public void handlePredictionRequest(NLPPredictions.PredictionRequestContext predRequest) {

        Set<NlpPredictions.PredictionRequestType> requestTypes = predRequest.getPredictionRequestTypes();
        Boolean disableIntentDetection = !requestTypes.contains(NlpPredictions.PredictionRequestType.DETECT_INTENTS);
        Boolean disableEntityExtraction = !requestTypes.contains(NlpPredictions.PredictionRequestType.EXTRACT_SLOTCLASSES);

        // Build http requests for the configured service provider
        ExternalNLPService extNlpService = getExternalNLPService();

        List<HttpRequest> httpRequests = extNlpService.getPredictionRequests(
            getExternalNlpServiceParameters(disableIntentDetection, disableEntityExtraction),
            new ExternalNlpPredictionRequestParameters.Builder()
                .setInput(predRequest.getInputText())
                .setLanguage(predRequest.getLanguage())
                .build());

        // Add the request to the prediction continuation requests
        predRequest.getContinuationRequests().addAll(httpRequests);
    }

    // Process the http responses
    public void handlePredictionResponse(NLPPredictions.PredictionResponseContext predResponse) {

        List<HttpResponse> responses = predResponse.getContinuationResponses();
        Set<NlpPredictions.PredictionRequestType> requestTypes = predResponse.getPredictionRequestTypes();
        Boolean disableIntentDetection = !requestTypes.contains(NlpPredictions.PredictionRequestType.DETECT_INTENTS);
        Boolean disableEntityExtraction = !requestTypes.contains(NlpPredictions.PredictionRequestType.EXTRACT_SLOTCLASSES);

        // Parse the http responses for the configured service provider
        ExternalNLPService extNlpService = getExternalNLPService();

        ExternalNlpPredictionResult extPredictionResult = null;
        try {
            extPredictionResult = extNlpService.getPredictionResult(
                getExternalNlpServiceParameters(disableIntentDetection, disableEntityExtraction),
                new ExternalNlpPredictionResultParameters.Builder()
                    .setHttpResponses(responses)
                    .build());
        } catch (ExternalNlpServiceException e) {
            System.debug(e);
            return;
        }

        if (!disableIntentDetection) {
            // Map intents from the external nlp service to MlIntentPredictions
            Map<String, ExternalNlpIntent> extIntentResultMap = extPredictionResult.getIntentResults().getPredictedIntents();
            if (predResponse.getAvailableMlIntents() != null && extIntentResultMap != null && !extIntentResultMap.isEmpty()){
                List<NLPPredictions.MlIntentPrediction> mlIntentPredictions = new List<NLPPredictions.MlIntentPrediction>();
                String highestConfidenceIntentName = extPredictionResult.getIntentResults().getHighestConfidenceIntentName();
                // NOTE: This handler matches ml intents based on exact name match
                
                // First try to auto-match ext intent to prediction intents based on name
                NLPPredictions.MlIntent ctxMlIntent = predResponse.getAvailableMlIntents().get(highestConfidenceIntentName);
 
                // If there are no matches, look for matches based on custom mappings
                if (ctxMlIntent == null) {
                    ctxMlIntent = predResponse.getAvailableMlIntents().get(CUSTOM_INTENT_MAPPINGS.get(highestConfidenceIntentName));
                }
                    
                if (ctxMlIntent != null) {
                    ExternalNlpIntent extIntent = extIntentResultMap.get(highestConfidenceIntentName);

                    NLPPredictions.MlIntentPrediction predMlIntent = new NLPPredictions.MlIntentPrediction();
                    predMlIntent.setConfidence(extIntent.getConfidenceScore());
                    predMlIntent.setIntentName(ctxMlIntent.getName());
                    // NOTE: We only support 1 intent for now, so just setting the highest confidence one for now
                    mlIntentPredictions = new List<NLPPredictions.MlIntentPrediction>{predMlIntent};
                }
                predResponse.setDetectedMlIntents(mlIntentPredictions);
            }
        }
        
        if (!disableEntityExtraction) {
            // Map entities from the external nlp service to ExtractedMlSlotClassValue
            Map<String, List<ExternalNlpEntity>> extEntityResultMap = extPredictionResult.getEntityResults().getPredictedEntities();
            if(predResponse.getAvailableMlSlotClasses() != null && extEntityResultMap != null && !extEntityResultMap.isEmpty()) {
            
                List<NLPPredictions.ExtractedMlSlotClassValue> mlSlotClassPredictions = new List<NLPPredictions.ExtractedMlSlotClassValue>();
                
                for(String extEntityName : extEntityResultMap.keySet()) {
                    
                    // First try to auto-match ext entities to prediction entities based on name
                    NLPPredictions.MlSlotClass ctxMlSlotClass = predResponse.getAvailableMlSlotClasses().get(extEntityName);

                    // If there are no matches, look for matches based on custom mappings
                    if (ctxMlSlotClass == null) {
                        ctxMlSlotClass = predResponse.getAvailableMlSlotClasses().get(CUSTOM_ENTITY_MAPPINGS.get(extEntityName));
                    }

                    // If we have no matches still, skip this external entity
                    if (ctxMlSlotClass == null) { continue; }

                    List<ExternalNlpEntity> extEntities = extEntityResultMap.get(extEntityName);
                    ExternalNlpEntity extEntity = extEntities.get(0); // Bots don't support multi list entities yet.

                    NLPPredictions.ExtractedMlSlotClassValue predMlSlotClass = new NLPPredictions.ExtractedMlSlotClassValue();
                    predMlSlotClass.setSlotClassName(ctxMlSlotClass.getName());
                    predMlSlotClass.setConfidence(extEntity.getConfidenceScore());
                    predMlSlotClass.setMatchedText(extEntity.getMatchedText());
                    predMlSlotClass.setStartIndex(extEntity.getStartIndex());
                    predMlSlotClass.setEndIndex(extEntity.getEndIndex());

                    try {
                        switch on ctxMlSlotClass.getDataType(){
                            when TEXT_SLOT_CLASS {
                                predMlSlotClass.setNormalizedTextValue(extNlpService.getNormalizedText(extEntity.getValue()));
                            } when NUMBER_SLOT_CLASS {
                                predMlSlotClass.setNormalizedNumberValue(extNlpService.getNormalizedNumber(extEntity.getValue()));
                            } when BOOLEAN_SLOT_CLASS {
                                predMlSlotClass.setNormalizedBooleanValue(extNlpService.getNormalizedBoolean(extEntity.getValue()));
                            } when DATE_SLOT_CLASS {
                                predMlSlotClass.setNormalizedDateValue(extNlpService.getNormalizedDate(extEntity.getValue()));
                            } when DATETIME_SLOT_CLASS {
                                predMlSlotClass.setNormalizedDateTimeValue(extNlpService.getNormalizedDateTime(extEntity.getValue()));
                            } when CURRENCY_SLOT_CLASS {
                                predMlSlotClass.setNormalizedNumberValue(extNlpService.getNormalizedNumber(extEntity.getValue()));
                            } when else {
                                // no op
                            }
                        }
                    } catch (ExternalNlpServiceException e) {
                        System.debug(e);
                        // Skip setting any slot classes that fail normalization
                        continue;
                    }
                    mlSlotClassPredictions.add(predMlSlotClass);
                }
                predResponse.setExtractedSlotClassValues(mlSlotClassPredictions);
            }
        }

    }

}