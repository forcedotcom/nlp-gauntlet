global abstract class ExternalNlpService {

    // Must provide a concrete implementation for the following 
    global abstract List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params);
    global abstract ExternalNlpPredictionResult getPredictionResult(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionResultParameters params);

    global ExternalNlpPredictionResult predict(ExternalNlpServiceParameters serviceParams, String input, String language) {
        
        External_Nlp_Custom_Settings__c cs = External_Nlp_Custom_Settings__c.getInstance();
        Boolean debugModeEnabled = cs != null && cs.Debug_Mode__c;

        // Build request parameters
        ExternalNlpPredictionRequestParameters params = new ExternalNlpPredictionRequestParameters.Builder()
            .setInput(input)
            .setLanguage(language)
            .build();
        List<HttpRequest> reqs = getPredictionRequests(serviceParams, params);

        // Make callouts for the built requests and collect responses
        Http http = new Http();
        List<HTTPResponse> responses = new List<HTTPResponse>();
        for(HttpRequest req : reqs) {
            HTTPResponse res = http.send(req);
            if (debugModeEnabled) {
                System.debug(' -- BEGIN RAW RESPONSE --');
                System.debug(res.getBody());
                System.debug(' -- END RAW RESPONSE --');
            }
            responses.add(res);
        }

        // Map responses to prediction results
        ExternalNlpPredictionResultParameters resultParams = new ExternalNlpPredictionResultParameters.Builder()
            .setHttpResponses(responses)
            .build();

        // Return prediction results
        ExternalNlpPredictionResult result = getPredictionResult(serviceParams, resultParams);
        if (result == null) {
            return null;
        }
        if (debugModeEnabled) {
            System.debug(' -- BEGIN PARSED RESPONSE --');
            System.debug(JSON.serializePretty(result));
            System.debug(' -- END PARSED RESPONSE --');
        }
        return result;
    }

    // A default implementation for value normalization is provided here
    // Normalized value methods can be overwritten by concrete implementations if needed
    global virtual DateTime getNormalizedDateTime(String value) {
        try {
            DateTime dt = (DateTime) JSON.deserialize('"' + value + '"', DateTime.class);
            return dt;
        } catch(Exception e) {
            throw new ExternalNlpServiceException(getNormalizationExceptionMessage(value, e),
                ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR);
        }
    }
    
    global virtual Date getNormalizedDate(String value) {
        try {
            return Date.valueOf(value);
        } catch(Exception e) {
            throw new ExternalNlpServiceException(getNormalizationExceptionMessage(value, e),
                ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR);
        }
    }

    global virtual Double getNormalizedNumber(String value) {
        try {
            return Double.valueOf(value);
        } catch(Exception e) {
            throw new ExternalNlpServiceException(getNormalizationExceptionMessage(value, e),
                ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR);
        }
    }
    
    global virtual Boolean getNormalizedBoolean(String value){
        try {
            return Boolean.valueOf(value);
        } catch(Exception e) {
            throw new ExternalNlpServiceException(getNormalizationExceptionMessage(value, e),
                ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR);
        }
    }

    global virtual String getNormalizedText(String value) {
        try {
            return value;
        } catch(Exception e) {
            throw new ExternalNlpServiceException(getNormalizationExceptionMessage(value, e),
                ExternalNlpServiceExceptionCode.NORMALIZED_VALUE_ERROR);
        }
    }

    global protected String getNormalizationExceptionMessage(String value, Exception e){
        return 'Unable to normalize value ' + value + ' ' +e.getMessage();
    }

}