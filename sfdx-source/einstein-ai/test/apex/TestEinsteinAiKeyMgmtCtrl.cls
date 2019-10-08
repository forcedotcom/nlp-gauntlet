@isTest
private class TestEinsteinAiKeyMgmtCtrl {

    @isTest
    private static void testDefaults() {
        Test.setCurrentPageReference(Page.EinsteinAiKeyMgmt);

        Test.startTest();
            EinsteinAiKeyMgmtCtrl ctrl = new EinsteinAiKeyMgmtCtrl();
            System.assertEquals(1, ctrl.publicKeys.size());
            System.assertEquals(false, ctrl.useStagingEndpoint);
            System.assertEquals(false, ctrl.publicKeyActive);
        Test.stopTest();
    }

    @isTest
    private static void testGetKeys() {
        Test.setMock(HttpCalloutMock.class, new EinsteinAiKeysAPICalloutMockImpl());
        Test.setCurrentPageReference(Page.EinsteinAiKeyMgmt);

        Test.startTest();
            EinsteinAiKeyMgmtCtrl ctrl = new EinsteinAiKeyMgmtCtrl();
            ctrl.userEmail = 'test@salesforce.com';
            ctrl.privateKey = getTestPrivateKey();
            System.assertEquals(1, ctrl.publicKeys.size());
            ctrl.getKeys();
            System.assertEquals(2, ctrl.publicKeys.size());
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertEquals(1, pageMessages.size());
            System.assertEquals('List of keys has been updated.', pageMessages.get(0).getDetail());
        Test.stopTest();
    }

    @isTest
    private static void testActivateKey() {
        Test.setMock(HttpCalloutMock.class, new EinsteinAiKeysAPICalloutMockImpl());
        Test.setCurrentPageReference(Page.EinsteinAiKeyMgmt);

        Test.startTest();
            EinsteinAiKeyMgmtCtrl ctrl = new EinsteinAiKeyMgmtCtrl();
            ctrl.userEmail = 'test@salesforce.com';
            ctrl.privateKey = getTestPrivateKey();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertEquals(0, pageMessages.size());
            ctrl.getKeys();
            pageMessages = ApexPages.getMessages();
            System.assertEquals(1, pageMessages.size());
            ctrl.activateKey();
            pageMessages = ApexPages.getMessages();
            System.assertEquals(2, pageMessages.size());
            System.assertEquals('A key must be selected for activation', pageMessages.get(1).getDetail());

            ctrl.selectedPublicKey = '2';
            ctrl.activateKey();
            pageMessages = ApexPages.getMessages();
            System.assertEquals(3, pageMessages.size());
            System.assertEquals('Key successfully activated', pageMessages.get(2).getDetail());

        Test.stopTest();
    }

    @isTest
    private static void testAddKey() {
        Test.setMock(HttpCalloutMock.class, new EinsteinAiKeysAPICalloutMockImpl());
        Test.setCurrentPageReference(Page.EinsteinAiKeyMgmt);

        Test.startTest();
            EinsteinAiKeyMgmtCtrl ctrl = new EinsteinAiKeyMgmtCtrl();
            ctrl.userEmail = 'test@salesforce.com';
            ctrl.privateKey = getTestPrivateKey();
            
            ctrl.addKey();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertEquals(1, pageMessages.size());
            System.assertEquals('A public key value and name must be provided', pageMessages.get(0).getDetail());

            ctrl.publicKey = 'a public key';
            ctrl.publicKeyName = 'My Key';
            ctrl.publicKeyActive = false;
            ctrl.addKey();

            pageMessages = ApexPages.getMessages();
            System.assertEquals(2, pageMessages.size());
            System.assertEquals('Key My Key was successfully added', pageMessages.get(1).getDetail());
        Test.stopTest();
    }

    @isTest
    private static void testDeleteKey() {
        Test.setMock(HttpCalloutMock.class, new EinsteinAiKeysAPICalloutMockImpl());
        Test.setCurrentPageReference(Page.EinsteinAiKeyMgmt);

        Test.startTest();
            EinsteinAiKeyMgmtCtrl ctrl = new EinsteinAiKeyMgmtCtrl();
            ctrl.userEmail = 'test@salesforce.com';
            ctrl.privateKey = getTestPrivateKey();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertEquals(0, pageMessages.size());
            ctrl.getKeys();
            pageMessages = ApexPages.getMessages();
            System.assertEquals(1, pageMessages.size());
            ctrl.deleteKey();
            pageMessages = ApexPages.getMessages();
            System.assertEquals(2, pageMessages.size());
            System.assertEquals('A key must be selected for deletion', pageMessages.get(1).getDetail());

            ctrl.selectedPublicKey = '2';
            ctrl.deleteKey();
            pageMessages = ApexPages.getMessages();
            System.assertEquals(3, pageMessages.size());
            System.assertEquals('Key successfully deleted', pageMessages.get(2).getDetail());

        Test.stopTest();
    }

    private static String getTestPrivateKey() {
        return 'MIIEowIBAAKCAQEArtVTxMGW7PbyJSj+QDH9vJpo6MmkQkXCURtRMHRrIXKjcRcL\n'+
                '3GspnEr0w+9UozK54seeWc76+ld57MfWEeM/s4Obuht0zdKudlbmSgOT7Kb7mWgE\n'+
                'HsDVeMUIRet+GywQ+FqROVGqcJ63jBzOBJc9EYjQILWIu7a5XxK7gYP8X/dvXKM8\n'+
                's695ydoqg3CpVq/oPz2g+N3nwGSVi07ri1il1V4kcDIrnadP4ybqB65OYJG+v7ya\n'+
                'Icp656CQmZAuoQeh/wY+jQIHvPJC8QWFoVmAXORARo+Mo8VSLBcPOWL7S2jVK85u\n'+
                'l252+iuk97yxUZX4s0Im9XnA+6UWaJZ7yFkUHwIDAQABAoIBAF0J8XY3f1XDZMEZ\n'+
                'u5P2Bo2jrkiTZfJOpUX8P4yFp605EHlSRmGaNZ6S1QagCm5+xCVHDaHFYBJxEtVK\n'+
                '00TZpkClvO2hRttxTp5zSEIC/Wlmw2Wz0N18yR1n3Ss4Uveqz60apUXXi9g63nqV\n'+
                'qZ0PztPR9tAxSv56EtPhaB9YWanHY34LFhu3CzHEZ6+SYaT6gmU/SLDTfNTlsuOd\n'+
                'HezRl/OsDkfchsF81/szOQw2N9Caka1d4KIWKIkMK2xsXjTCCkVrvRbnPr5WlsN4\n'+
                'baZm0lNZkS53Mq/FsbF2F0c4WsXeDDmr3RD5T0nG7VSQpRaTGkDcdtRlcGo6ISuW\n'+
                '03C+vQECgYEA9wzFcSD8y0dEP9hcK8hZP8ENzbTKvbWnGFF7VwYhum0ss222fqX1\n'+
                'E0XJqgsK2SsMw+Deiuhv4tpmIYRZtkSe3mBTbJshoKZM+xFLiuljv/upqwX1mmxv\n'+
                'VTJ+7lAuknWAPtmx6kfDH7nQ9x9/cstmlAg92nxSlNTqFt2yHt99+b8CgYEAtSrL\n'+
                'LdqJSlpsJ4i93bfxMMoLMpnO4ylJXgjhogMl6e397XjnyypY4UWUiQMh+ZPtbiSa\n'+
                'fBhy6kTNw8kUr34zvrh2fmwayjrABUwLtm7gZoxNbdHvs6Aui54ixDzMdNP29XP2\n'+
                '040ERhx1Z3/CcZbF1XHNIaEGBIunzOlJyJSDvaECgYA96JZlxhVzP1WsBiT618b9\n'+
                'wfwai26u4aGQ54JYCXJUTF2CTUEJNb9XaAqkMQYz66TURTqfZqX7HC2xwn/UvBdv\n'+
                'tIXTVoCzyFjMJcZfdiMIDiGzeNfWLcwsdm32fGNfUlCj71u1UOxlu+PQubTvaGc5\n'+
                'O2N8p+Dt6PkMZ9vl/q2L8wKBgBc530aHp+ZCZW9EFqNgO6m3nWvlUCLLXj6SAOtW\n'+
                'X/v3qQBS6dSgHzjyRLK0Fhz7HAts4ela8RCbtY2OL/q3wUaIO5jFn0Gh+pAzSaUf\n'+
                '3eEHx712lrZ+qLj5kxd5e/TWX+jj7xb8Ezox19NnC7SoUcClkFjpXe4jQWYB2pW+\n'+
                'hI1BAoGBANmCNOGvpT118ztQPgrzL4tN5WellkaS8GW7IVkkjSvzcg4I4Wnc/yGU\n'+
                'L0/pU//Yq783QyFJKFmzjRSmcjywqhBkeKRuMxZyGvnJwcTQdWL6lm3yisnCTZvd\n'+
                'yJiW3uCvdCJE61sjLj/DkrjMkIYrxrtQInGLsxzwZRiMduIQObPU';
    }

}
