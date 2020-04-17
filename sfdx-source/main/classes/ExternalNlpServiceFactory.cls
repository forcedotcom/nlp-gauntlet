global with sharing class ExternalNlpServiceFactory {

    global static ExternalNlpService makeNlpService(String serviceDefinitionName){
        return makeNlpService(getApexTypeForDefinition(serviceDefinitionName));
    }

    global static ExternalNlpService makeNlpService(System.Type apexType){
        try {
            return (ExternalNlpService)apexType.newInstance();
        } catch (Exception e){
            throw new ExternalNlpServiceException(e.getMessage(), ExternalNlpServiceExceptionCode.UNSUPPORTED_SERVICE_TYPE);
        }
    }

    private static System.Type getApexTypeForDefinition(String serviceDefinitionName) {
        List<External_Nlp_Service_Definition__mdt> settings = [select DeveloperName,
                                                                        Apex_Class__c
                                                                        from External_Nlp_Service_Definition__mdt
                                                                        where DeveloperName = :serviceDefinitionName];
        if (settings.isEmpty() || settings.size() != 1) {
            throw new ExternalNlpServiceException('Service type has no implementation', ExternalNlpServiceExceptionCode.UNSUPPORTED_SERVICE_TYPE);
        }
        return Type.forName(settings.get(0).Apex_Class__c);
    }

}
