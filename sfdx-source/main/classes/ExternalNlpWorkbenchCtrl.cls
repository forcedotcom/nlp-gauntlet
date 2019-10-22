public with sharing class ExternalNlpWorkbenchCtrl {

    public String selectedDefinitionName{get;set;}
    public List<ModelSetting> modelSettings{get;set;}

    public String additionalParameters{get;set;}
    
    public String inputText{get;set;}
    public String language{get;set;}
    public String selectedTimeZoneId{get;set;}
    public String selectedSettingName{get;set;}
    public Double intentConfidenceThresholdDouble{get;set;}
    public Double nerConfidenceThresholdDouble{get;set;}
    public Double sentimentConfidenceThresholdDouble{get;set;}
    public transient String response{get;set;} 

    public class ModelSetting {
        public String namedCredentialKey{get;set;}
        public String modelId{get;set;}

        public ModelSetting(String namedCredentialKey, String modelId) {
            this.namedCredentialKey = namedCredentialKey;
            this.modelId = modelId;
        }
    }

    public ExternalNlpWorkbenchCtrl() {
        this.modelSettings = new List<ModelSetting>{new ModelSetting(null, null)};
        this.selectedTimeZoneId = UserInfo.getTimeZone().getID();
        this.language = UserInfo.getLanguage();
    }

    public List<SelectOption> getSettings() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-1','-- None --'));
        if (System.Test.isRunningTest()) {
            options.add(new SelectOption('ExternalNlpTest','External Nlp Test'));
        }
        for(External_Nlp_Service_Setting__mdt setting : [select DeveloperName, MasterLabel from External_Nlp_Service_Setting__mdt]) {
            options.add(new SelectOption(setting.DeveloperName,setting.MasterLabel));
        }
        return options;
    }

    public List<SelectOption> getServiceDefinitions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-1','-- None --'));
        for(External_Nlp_Service_Definition__mdt setting : [select DeveloperName, MasterLabel from External_Nlp_Service_Definition__mdt]) {
            options.add(new SelectOption(setting.DeveloperName,setting.MasterLabel));
        }
        return options;
    }

    public List<SelectOption> getUserLanguages() {
        List<PicklistEntry> entries = Schema.SObjectType.User.fields.LanguageLocaleKey.picklistValues;
        List<SelectOption> options = new List<SelectOption>();
        for(PicklistEntry v : entries) {
            options.add(new SelectOption(v.getValue(),v.getLabel()));
        }
        return options;
    }

    public List<SelectOption> getTimeZones() {
        List<PicklistEntry> entries = Schema.SObjectType.User.fields.TimeZoneSidKey.picklistValues;
        List<SelectOption> options = new List<SelectOption>();
        for(PicklistEntry v : entries) {
            options.add(new SelectOption(v.getValue(),v.getLabel()));
        }
        return options;
    }
    
    public List<SelectOption> getNamedCredentials() {
        List<NamedCredential> ncs = [SELECT DeveloperName,MasterLabel FROM NamedCredential];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-1','-- None --'));
        for(NamedCredential v : ncs) {
            options.add(new SelectOption(v.DeveloperName,v.MasterLabel));
        }
        return options;
    }

    public PageReference addModelSetting() {
        // Limit number of models to 3 for now 
        if (this.modelSettings.size() < 3) {
            this.modelSettings.add(new ModelSetting(null, null));
        }
        return null;
    }

    public PageReference removeModelSetting() {
        if (this.modelSettings.size() > 0) {
            this.modelSettings.remove(this.modelSettings.size() -1);
        }
        return null;
    }

    public PageReference populateFromSetting() {
        List<External_Nlp_Service_Setting__mdt> settings = [select Additional_Parameters__c
                                                        ,Intent_Confidence_Threshold__c
                                                        ,NER_Confidence_Threshold__c
                                                        ,Sentiment_Confidence_Threshold__c
                                                        ,External_Nlp_Service_Definition__r.DeveloperName
                                                        ,(select Model_Id__c, Named_Credential_Name__c from External_Nlp_Model_Settings__r)
                                                        from External_Nlp_Service_Setting__mdt 
                                                        where DeveloperName = :selectedSettingName
                                                        limit 1];
        External_Nlp_Service_Setting__mdt setting = null;
        List<ModelSetting> newModelSettings = new List<ModelSetting>();
        if (!settings.isEmpty()) {
            setting = settings.get(0);
            for(External_Nlp_Model_Setting__mdt es : setting.External_Nlp_Model_Settings__r) {
                newModelSettings.add(new ModelSetting(es.Named_Credential_Name__c, es.Model_Id__c));
            }
        }
        this.modelSettings = newModelSettings.isEmpty() ? new List<ModelSetting>{new ModelSetting(null, null)} : newModelSettings;
        this.additionalParameters = setting == null ? '' : setting.Additional_Parameters__c;
        this.selectedDefinitionName = setting == null ? '' : setting.External_Nlp_Service_Definition__r.DeveloperName;
        this.intentConfidenceThresholdDouble = setting == null ? null : setting.Intent_Confidence_Threshold__c;
        this.nerConfidenceThresholdDouble = setting == null ? null : setting.NER_Confidence_Threshold__c;
        this.sentimentConfidenceThresholdDouble = setting == null ? null : setting.Sentiment_Confidence_Threshold__c;
        return null;
    }

    public PageReference test() {
        Map<String,String> additionalParametersMap = ExternalNlpUtils.convertStringToMap(additionalParameters);

        try{
            List<ExternalNlpModelParameters> modelParams = new List<ExternalNlpModelParameters>();

            for(ModelSetting modelSetting : this.modelSettings) {
                modelParams.add(new ExternalNlpModelParameters.Builder()
                    .setModelId(modelSetting.modelId)
                    .setNamedCredentialKey(modelSetting.namedCredentialKey)
                    .build());
            }

            ExternalNlpServiceParameters serviceParams = new ExternalNlpServiceParameters.Builder()
                .setModelParams(modelParams)
                .setIntentThreshold(intentConfidenceThresholdDouble)
                .setNerThreshold(nerConfidenceThresholdDouble)
                .setSentimentThreshold(sentimentConfidenceThresholdDouble)
                .setAdditionalParams(additionalParametersMap)
                .build();

            // Return prediction results
            ExternalNLPService nlpService = System.Test.isRunningTest() 
                ? ExternalNlpServiceFactory.makeNlpService(ExternalNlpMockService.class)
                : ExternalNlpServiceFactory.makeNlpService(selectedDefinitionName);
            
            ExternalNlpPredictionResult result = nlpService.predict(serviceParams, inputText, language);
            response = JSON.serializePretty(result, true);
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }


}