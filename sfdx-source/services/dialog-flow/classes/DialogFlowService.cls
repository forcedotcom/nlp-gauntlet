public with sharing class DialogFlowService extends ExternalNlpService {

    private final static String DEFAULT_LANGUAGE = 'en';

    // More Info here : https://developers.google.com/identity/protocols/OAuth2ServiceAccount#jwt-auth
    private final static String API_VERSION = 'v2';
    private final static Map<String, String> LANGUAGE_CODE_MAP = new Map<String, String>{
        'en_US' => 'en'
    };

    /*
     * How to upload your Google Account Key as a Salesforce Certificate:
     * 
     * You'll need to convert your service account key from Google into a Java keystore (JKS) file. 
     * Make sure you create a P12 format key for your service account and download the associated key.
     * 
     * The following creates keystorefile.jks with a certificate named google_cloud, and password notasecret (what Google exports), which must match the P12 store password :
     * 
     * keytool -importkeystore -srckeystore private-key-from-google.p12 -destkeystore keystorefile.jks -srcstoretype pkcs12 -srcstorepass notasecret -deststorepass notasecret -deststoretype jks -destalias google_cloud -srcalias privatekey 
     * 
     * Next, go to Setup > Security > Certificate and Key Management and click "Import from Keystore"
     * Select the generated keystorefile.jks generated from the previous command, use "notasecret" as the password and save.
     * You should see a new certificate called "google_cloud" in your list of certificates
     * 
     */

    // API Docs : https://cloud.google.com/dialogflow-enterprise/docs/reference/rest/v2/projects.agent.sessions/detectIntent
    public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        
        String sessionId = serviceParams.getAdditionalParams().get('sessionId');

        if (String.isBlank(sessionId)) {
            sessionId = String.valueof(DateTime.now().getTime());
        }

        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
            String endpoint = '';

            endpoint = 'callout:'+modelParams.getNamedCredentialKey();
            endpoint += '/'+API_VERSION+'/projects/'+modelParams.getModelId()+'/agent/sessions/'+sessionId+':detectIntent';

            Map<String, Object> queryInputMap = new Map<String,Object>{
                'queryInput' => new Map<String,Object>{
                    'text' => new Map<String, Object>{
                        'text' => params.getInput(),
                        'languageCode' => LANGUAGE_CODE_MAP.containsKey(params.getLanguage()) ? LANGUAGE_CODE_MAP.get(params.getLanguage()) : DEFAULT_LANGUAGE
                    }
                }
            };

            if (!serviceParams.getDisableSentimentDetection()) {
                queryInputMap.put('queryParams', new Map<String, Object>{
                    'sentimentAnalysisRequestConfig' => new Map<String, Object>{
                        'analyzeQueryTextSentiment' => true
                    }
                });
            }
            
            String body = JSON.serialize(queryInputMap);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            if (body != null) {
                req.setBody(body);
            }
            req.setHeader('Content-Type', 'application/json');
            reqs.add(req);
        }

        return reqs;
    }

    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionResultParameters params) {
        List<HttpResponse> responses = params.getHttpResponses();

        Map<String, ExternalNlpIntent> intentsMap = new Map<String, ExternalNlpIntent>();
        ExternalNlpIntent highestScoringExtIntent = null;
        Map<String, List<ExternalNlpEntity>> entitiesMap = new Map<String, List<ExternalNlpEntity>>();
        Map<String, ExternalNlpSentiment> sentimentsMap = new Map<String, ExternalNlpSentiment>();
        ExternalNlpSentiment highestScoringExtSentiment = null;

        for (HttpResponse response : responses) {
            if(response.getStatusCode() != 200){ throw new ExternalNlpServiceException(
                'Received unexpected response code : '+response.getStatusCode(),
                ExternalNlpServiceExceptionCode.INVALID_HTTP_RESPONSE_CODE); }

            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

            // Intent Detection
            highestScoringExtIntent = detectIntents(serviceParams, bodyMap, intentsMap, highestScoringExtIntent);

            // Named Entity Recognition
            detectEntities(serviceParams, bodyMap, entitiesMap);

            // Sentiment Recognition
            highestScoringExtSentiment = detectSentiments(serviceParams, bodyMap, sentimentsMap, highestScoringExtSentiment);
        }

        String highestConfidenceIntentName = null;
        if (highestScoringExtIntent != null && highestScoringExtIntent.getConfidenceScore() >= serviceParams.getIntentThreshold()) {
            highestConfidenceIntentName = highestScoringExtIntent.getName();
        }

        ExternalNlpPredictionIntentResult intentPredResult = new ExternalNlpPredictionIntentResult.Builder()
            .setHighestConfidenceIntentName(highestConfidenceIntentName)
            .setPredictedIntents(intentsMap)
            .build();

        ExternalNlpPredictionEntityResult entityPredResult = new ExternalNlpPredictionEntityResult.Builder()
            .setPredictedEntities(entitiesMap)
            .build();

        String highestConfidenceSentimentName = null;
        if (highestScoringExtSentiment != null && Math.abs(highestScoringExtSentiment.getConfidenceScore()) >= serviceParams.getSentimentThreshold()) {
            highestConfidenceSentimentName = highestScoringExtSentiment.getName();
        }

        ExternalNlpPredictionSentimentResult sentimentPredResult = new ExternalNlpPredictionSentimentResult.Builder()
            .setDocumentSentiment(new ExternalNlpDocumentSentiment.Builder()
                .setHighestConfidenceSentimentName(highestConfidenceSentimentName)
                .setPredictedSentiments(sentimentsMap)
                .build())
            .build();

        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentPredResult)
            .setEntityResults(entityPredResult)
            .setSentimentResults(sentimentPredResult)
            .build();
    }

    private ExternalNlpIntent detectIntents(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpIntent> intentsMap, ExternalNlpIntent highestScoringExtIntent) {
        
        if (serviceParams.getDisableIntentDetection()) { return highestScoringExtIntent; }

        Map<String, Object> resultMap = (Map<String, Object>)bodyMap.get('queryResult');
        Map<String, Object> intentMap = (Map<String, Object>)resultMap.get('intent');

        if (intentMap!= null && intentMap.get('displayName') != null) {
            Double intentDetectionConfidence = (Double)resultMap.get('intentDetectionConfidence');
            String intentName = (String)intentMap.get('displayName');
            ExternalNlpIntent extIntent = new ExternalNlpIntent.Builder()
                                            .setName(intentName)
                                            .setConfidenceScore(intentDetectionConfidence)
                                            .build();
            intentsMap.put(intentName, extIntent);

            if (highestScoringExtIntent == null || intentDetectionConfidence > highestScoringExtIntent.getConfidenceScore()) {
                highestScoringExtIntent = extIntent;
            }
        }

        return highestScoringExtIntent;

    }

    private void detectEntities(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, List<ExternalNlpEntity>> entitiesMap) {

        if (serviceParams.getDisableEntityExtraction()) { return; }

        Map<String, Object> resultMap = (Map<String, Object>)bodyMap.get('queryResult');
        Map<String, Object> parametersMap = (Map<String, Object>)resultMap.get('parameters');

        if (parametersMap == null) { return; }

        for(String parameterName : parametersMap.keySet()) {
            String parameterValue = null;
            try{
                Map<String, Object> mapValue = (Map<String, Object>)parametersMap.get(parameterName);
                parameterValue = JSON.serialize(mapValue);
            } catch(System.JSONException je) {
                parameterValue = String.valueOf(parametersMap.get(parameterName));
            } catch(System.TypeException te) {
                parameterValue = String.valueOf(parametersMap.get(parameterName));
            }
            if (String.isBlank(parameterValue)) { continue; }
            // NOTE: Dialogflow doesn't return a confidence score for detected entities
            List<ExternalNlpEntity> extEntities = new List<ExternalNlpEntity>{
                                                            new ExternalNlpEntity.Builder()
                                                                .setName(parameterName)
                                                                .setValue(parameterValue)
                                                                .setConfidenceScore((Double)1.0)
                                                                .build()};
            entitiesMap.put(parameterName, extEntities);
        }

    }

    private ExternalNlpSentiment detectSentiments(ExternalNlpServiceParameters serviceParams, Map<String, Object> bodyMap, Map<String, ExternalNlpSentiment> sentimentsMap, ExternalNlpSentiment highestScoringExtSentiment) {
        //https://cloud.google.com/natural-language/docs/basics#interpreting_sentiment_analysis_values

        if (serviceParams.getDisableSentimentDetection()) { return highestScoringExtSentiment; }

        Map<String, Object> resultMap = (Map<String, Object>)bodyMap.get('sentimentAnalysisResult');
        if (resultMap == null) { return highestScoringExtSentiment; }
        Map<String, Object> textSentimentMap = (Map<String, Object>)resultMap.get('queryTextSentiment');
        if (textSentimentMap == null) { return highestScoringExtSentiment; }

        Double sentimentScore = (Double)textSentimentMap.get('score');
        Double sentimentMagnitude = (Double)textSentimentMap.get('magnitude');

        String sentimentName = 'neutral';
        if (sentimentScore == 0) {
            if (sentimentMagnitude > 0.2) { // TODO: Should be configurable
                sentimentName = 'mixed';
            }
        } else {
            if (sentimentScore > 0) {
                sentimentName = 'positive';
            } else {
                sentimentName = 'negative';
            }
        }

        ExternalNlpSentiment extSentiment = new ExternalNlpSentiment.Builder()
                            .setName(sentimentName)
                            .setConfidenceScore(sentimentScore)
                            .setMagnitude(sentimentMagnitude)
                            .build();
        sentimentsMap.put(sentimentName, extSentiment);

        if (highestScoringExtSentiment == null || Math.abs(sentimentScore) > Math.abs(highestScoringExtSentiment.getConfidenceScore())) {
            highestScoringExtSentiment = extSentiment;
        }

        return highestScoringExtSentiment;
    }

    public override String getNormalizedText(String value) {
        try {
            String normalizedTextValue = null;
            try{
                Map<String, Object> mapValue = (Map<String, Object>)JSON.deserializeUntyped(value);
                normalizedTextValue = (String)mapValue.get('name');
            } catch(System.JSONException je) {
                normalizedTextValue = value; 
            } catch(System.TypeException te) {
                normalizedTextValue = value; 
            }
            return normalizedTextValue;
        } catch(Exception e) {
            System.debug(e);
            throw new ExternalNlpServiceException(getNormalizationExceptionMessage(value, e),
                ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR);
        }
    }

    public override DateTime getNormalizedDateTime(String value) {
        try {
            Map<String, Object> dateMap = (Map<String, Object>)JSON.deserializeUntyped(value);
            return (DateTime) JSON.deserialize('"' + dateMap.get('date_time') + '"', DateTime.class);
        } catch(Exception e) {
            try {
                return (DateTime) JSON.deserialize('"' + value + '"', DateTime.class);
            } catch (Exception e2){
                throw new ExternalNlpServiceException(getNormalizationExceptionMessage(value, e),
                    ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR);
            }
        }
    }

}