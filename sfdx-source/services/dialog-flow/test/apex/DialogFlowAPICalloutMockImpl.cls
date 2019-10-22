public with sharing class DialogFlowAPICalloutMockImpl implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        if(req.getEndpoint().contains('/v2/projects')){
            body = '{'+
                        '"responseId": "a56ef55d-80bc-47b2-81b2-dc83ace73e1b-68e175c7",'+
                        '"queryResult": {'+
                            '"queryText": "i want to schedule an appointment for my tesla tomorrow at 9 am",'+
                            '"parameters": {'+
                                '"Car_Make": "Tesla",'+
                                '"time": "2019-07-03T09:00:00-07:00",'+
                                '"date": "2019-07-03T12:00:00-07:00"'+
                            '},'+
                            '"allRequiredParamsPresent": true,'+
                            '"intent": {'+
                                '"name": "projects/einstein-dealership-bot-fjewhd/agent/intents/b2db8090-a7ba-4631-95ba-26f0950ee1b2",'+
                                '"displayName": "Make_Appointment"'+
                            '},'+
                            '"intentDetectionConfidence": 0.8421737,'+
                            '"diagnosticInfo": {'+
                            '"end_conversation": true'+
                            '},'+
                            '"languageCode": "en"'+
                        '},'+
                        '"sentimentAnalysisResult": {'+
                            '"queryTextSentiment": {'+
                                '"score": 0.8,'+
                                '"magnitude": 0.8'+
                            '}'+
                        '}'+
                    '}';
        }
        res.setBody(body);

        return res;
    }

}