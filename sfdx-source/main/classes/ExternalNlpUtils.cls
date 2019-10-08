public with sharing class ExternalNlpUtils {

    public static Map<String, String> convertStringToMap(String params) {
        Map<String,String> parametersMap = new Map<String, String>();
        if (!String.isBlank(params)) {
            List<String> paramsList = params.split(',');
            for(String param : paramsList){
                List<String> paramValues = param.split('=');
                if (paramValues.size() != 2) { continue; }
                parametersMap.put(paramValues.get(0).trim(), paramValues.get(1).trim());
            }
        }
        return parametersMap;
    }

}
