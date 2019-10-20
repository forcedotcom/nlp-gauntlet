public with sharing class ExternalNlpServiceFactory {

    public static ExternalNlpService makeNlpServiceFromCustomMetadata(String customMetadataName){
        External_Nlp_Service_Setting__mdt setting = getCustomMetadata(customMetadataName);

        Map<String, ExternalNlpServiceType> extNlpServiceTypeMap = new Map<String, ExternalNlpServiceType>();
        for(ExternalNlpServiceType v : ExternalNlpServiceType.values()) {
            extNlpServiceTypeMap.put(v.name(), v);
        }

        ExternalNlpServiceType serviceType = extNlpServiceTypeMap.get(setting.Type__c);
        Map<String,String> additionalParametersMap = ExternalNlpUtils.convertStringToMap(setting.Additional_Parameters__c);
        Decimal intentConfidenceThreshold = setting.Intent_Confidence_Threshold__c;
        Decimal nerConfidenceThreshold = setting.NER_Confidence_Threshold__c;
        Decimal sentimentConfidenceThreshold = setting.Sentiment_Confidence_Threshold__c;

        List<ExternalNlpModelParameters> modelParams = new List<ExternalNlpModelParameters>();

        if (Test.isRunningTest()) {
            modelParams.add(new ExternalNlpModelParameters.Builder()
                .setModelId('TestModelId')
                .setNamedCredentialKey('TestNamedCredentialKey')
                .build());
        } else {
            for (External_Nlp_Model_Setting__mdt modelSetting : setting.External_Nlp_Model_Settings__r) {
                modelParams.add(new ExternalNlpModelParameters.Builder()
                    .setModelId(modelSetting.Model_Id__c)
                    .setNamedCredentialKey(modelSetting.Named_Credential_Name__c)
                    .build());
            }
        }

        ExternalNlpServiceParameters serviceParams = new ExternalNlpServiceParameters.Builder()
            .setModelParams(modelParams)
            .setIntentThreshold(intentConfidenceThreshold == null ? null : intentConfidenceThreshold.doubleValue())
            .setNerThreshold(nerConfidenceThreshold == null ? null : nerConfidenceThreshold.doubleValue())
            .setSentimentThreshold(sentimentConfidenceThreshold == null ? null : sentimentConfidenceThreshold.doubleValue())
            .setAdditionalParams(additionalParametersMap)
            .build();

        return makeNlpService(serviceType, serviceParams);
    }

    public static ExternalNlpService makeNlpService(ExternalNlpServiceType serviceType, ExternalNlpServiceParameters serviceParams){
        switch on serviceType {
            when EINSTEIN_AI {
                return new EinsteinAiService(serviceParams);
            } when DIALOG_FLOW {
                return new DialogFlowService(serviceParams);
            } when WIT_AI {
                return new WitAiService(serviceParams);
            } when LUIS {
                return new LuisService(serviceParams);
            } when WATSON {
                return new WatsonService(serviceParams);
            } when else {
                throw new ExternalNlpServiceException('Service type has no implementation', ExternalNlpServiceExceptionCode.UNSUPPORTED_SERVICE_TYPE);
            }
        }
    }

    private static External_Nlp_Service_Setting__mdt getCustomMetadata(String customMetadataName) {
        List<External_Nlp_Service_Setting__mdt> settings = new List<External_Nlp_Service_Setting__mdt>();
        if (Test.isRunningTest()) {
            External_Nlp_Service_Setting__mdt testSetting = new External_Nlp_Service_Setting__mdt(
                DeveloperName = 'Test',
                Type__c = 'EINSTEIN_AI',
                Additional_Parameters__c = 'param1=value1',
                Intent_Confidence_Threshold__c = 0.9,
                NER_Confidence_Threshold__c = 0.9,
                Sentiment_Confidence_Threshold__c = 0.7
            );
            settings.add(testSetting);
        } else {
            settings = [select Id
                ,DeveloperName
                ,Type__c
                ,Additional_Parameters__c
                ,Intent_Confidence_Threshold__c
                ,NER_Confidence_Threshold__c
                ,Sentiment_Confidence_Threshold__c
                ,(select Model_Id__c, Named_Credential_Name__c from External_Nlp_Model_Settings__r)
                from External_Nlp_Service_Setting__mdt
                where DeveloperName = :customMetadataName
                limit 1];
        }
        if (settings.isEmpty()) {
            throw new ExternalNlpServiceException('Invalid setting name', ExternalNlpServiceExceptionCode.INVALID_SETTTING); 
        }
        return settings.get(0);
    }

}
