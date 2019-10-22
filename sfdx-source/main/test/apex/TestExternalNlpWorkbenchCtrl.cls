@isTest
private class TestExternalNlpWorkbenchCtrl {
    
    @isTest
    private static void test() {
        Test.setMock(HttpCalloutMock.class, new ExternalNlpMockAPICalloutMockImpl());

        Test.setCurrentPageReference(Page.ExternalNlpWorkbench);
        Test.startTest();
            ExternalNlpWorkbenchCtrl ctrl = new ExternalNlpWorkbenchCtrl();

            List<SelectOption> serviceDefinitions = ctrl.getServiceDefinitions();
            System.assert(serviceDefinitions.size() > 0, 'Expected at least 1 service type');
            List<SelectOption> userLanguages = ctrl.getUserLanguages();
            System.assert(userLanguages.size() > 0, 'Expected at least 1 user language');
            List<SelectOption> timeZones = ctrl.getTimeZones();
            System.assert(timeZones.size() > 0, 'Expected at least 1 time zone');
            List<SelectOption> settings = ctrl.getSettings();
            System.assert(settings.size() > 0, 'Expected at least 1 setting');
            List<SelectOption> namdCreds = ctrl.getNamedCredentials();
            System.assert(namdCreds.size() > 0, 'Expected at least 1 named credential');
            List<ExternalNlpWorkbenchCtrl.ModelSetting> modelSettings = ctrl.modelSettings;
            System.assert(modelSettings.size() > 0, 'Expected at least 1 endpoint setting');

            ctrl.selectedDefinitionName = 'ExternalNlpTest';
            ctrl.additionalParameters = 'session=12345';
            ctrl.inputText = 'i want to schedule an appointment for my tesla tomorrow';
            ctrl.language = 'en_US';
            ctrl.selectedTimeZoneId = Timezone.getTimeZone('America/New_York').getDisplayName();
            ctrl.intentConfidenceThresholdDouble = (Double)0.7;
            ctrl.nerConfidenceThresholdDouble = (Double)0.7;
            ctrl.selectedSettingName = '-1';

            ExternalNlpWorkbenchCtrl.ModelSetting modelSetting = modelSettings.get(0);
            modelSetting.namedCredentialKey = 'ExternalNlpAPI';
            modelSetting.modelId = 'testModelId';

            Integer origModelSettingsSize = modelSettings.size();
            ctrl.addModelSetting();
            System.assertEquals(origModelSettingsSize+1, ctrl.modelSettings.size());
            ctrl.removeModelSetting();
            System.assertEquals(origModelSettingsSize, ctrl.modelSettings.size());

            PageReference result = ctrl.test();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertEquals(0, pageMessages.size());
            System.assert(ctrl.response != null);

        Test.stopTest();

    }

}
