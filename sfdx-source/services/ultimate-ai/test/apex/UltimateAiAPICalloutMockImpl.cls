public with sharing class UltimateAiAPICalloutMockImpl implements HttpCalloutMock {

   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        if(req.getEndpoint().contains('/api/intents')){
            body = '{'+
                        '"intents": ['+
                            '{"confidence": 0.89,"name": "Intent1"},'+
                            '{"confidence": 0.08,"name": "Intent2"},'+
                            '{"confidence": 0.02,"name": "Intent3"},'+
                            '{"confidence": 0.01,"name": "Intent4"},'+
                            '{"confidence": 0.01,"name": "Intent5"}'+
                        '],'+
                        '"entities": ['+
                            '{"confidence":0.9,"form":"Tampere","name":"city"},'+
                            '{"confidence":1.0,"form":"123456789","name":"orderNumber"}'+
                            ''+
                        ']'+
                    '}';
        }
        res.setBody(body);

        return res;
    }

}
