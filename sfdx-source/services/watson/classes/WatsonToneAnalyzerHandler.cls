public with sharing class WatsonToneAnalyzerHandler {

    private final static String DEFAULT_LANGUAGE = 'en';

    private static final String TONE_API_VERSION = '2017-09-21';

    private final static Map<String, String> LANGUAGE_CODE_MAP = new Map<String, String>{
        'en_US' => 'en'
    };

    // API Docs: https://cloud.ibm.com/apidocs/tone-analyzer
    public static HttpRequest buildRequest(ExternalNlpModelParameters modelParams, ExternalNlpPredictionRequestParameters reqParams) {
        String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
        endpoint += '/tone-analyzer/api/v3/tone?version='+TONE_API_VERSION;
        endpoint += '&sentences=false'; // no support for sentence analysis for now

        Map<String, Object> queryInputMap = new Map<String,Object>{
            'text' => reqParams.getInput()
        };

        String body = JSON.serialize(queryInputMap);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        if (body != null) {
            req.setBody(body);
        }
        req.setHeader('Content-Type', 'application/json');
        String serviceLanguage = LANGUAGE_CODE_MAP.get(reqParams.getLanguage());
        req.setHeader('Content-Language', serviceLanguage != null ? serviceLanguage : DEFAULT_LANGUAGE);
        return req;
    }

    public static ExternalNlpPredictionResult buildResult(List<Map<String, Object>> responseMap) {
        Map<String, ExternalNlpTone> tonesMap = new Map<String, ExternalNlpTone>();
        ExternalNlpTone highestConfienceTone = null;

        for (Map<String, Object> bodyMap : responseMap) {

            Map<String, Object> documentTone = (Map<String, Object>)bodyMap.get('document_tone');
            List<Object> tones = (List<Object>)documentTone.get('tones');

            List<ExternalNlpTone> extNlpTones = new List<ExternalNlpTone>();

            for(Object t : tones) {
                Map<String, Object> toneObj = (Map<String, Object>)t;
                String toneName = (String)toneObj.get('tone_name');
                Double toneScore =(Double)toneObj.get('score');

                ExternalNlpTone extNlpTone = new ExternalNlpTone.Builder()
                                                .setName(toneName)
                                                .setConfidenceScore(toneScore)
                                                .build();

                tonesMap.put(toneName, extNlpTone);
                if (highestConfienceTone == null || extNlpTone.getConfidenceScore() > highestConfienceTone.getConfidenceScore()) {
                    highestConfienceTone = extNlpTone;
                }

            }

        }

        if (tonesMap.isEmpty()) {
            return new ExternalNlpPredictionResult.Builder()
                .setToneResults(null)
                .build();
        }

        String highestConfienceToneName = highestConfienceTone != null ? highestConfienceTone.getName() : null;
        ExternalNlpDocumentTone extDocTone = new ExternalNlpDocumentTone.Builder()
                                                    .setPredictedTones(tonesMap)
                                                    .setHighestConfidenceToneName(highestConfienceToneName)
                                                    .build();
        ExternalNlpPredictionToneResult extPredToneResult = new ExternalNlpPredictionToneResult.Builder()
                                                                    .setDocumentTone(extDocTone)
                                                                    .build();

        return new ExternalNlpPredictionResult.Builder()
            .setToneResults(extPredToneResult)
            .build();
    }

}
