public with sharing class WitAiAPICalloutMockImpl implements HttpCalloutMock {

   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        if(req.getEndpoint().contains('/api/intents')){
            body = '{'+
                        '"intents": ['+
                            '{"confidence": 0.08208152651786804,"name": "Mitä osaat"},'+
                            '{"confidence": 0.2620494067668915,"name": "Kikki hiiri"},'+
                            '{"confidence": 0.3722572326660156,"name": "Example"},'+
                            '{"confidence": 0.06704168021678925,"name": "Submitted to2"},'+
                            '{"confidence": 0.058408066630363464,"name": "What's up?"}'+
                        '],'+
                        '"entities": []'+'
                    '}';
        }
        res.setBody(body);

        return res;
    }

}
