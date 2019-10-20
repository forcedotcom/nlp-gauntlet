public with sharing class EinstienAiAPICalloutMockImpl implements HttpCalloutMock {

   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        if(req.getEndpoint().contains('/language/intent')){
            body = '{'+
                        '"probabilities": ['+
                            '{'+
                                '"label": "Einstein_Dealership_Bot_ld1-Make_Appointment",'+
                                '"probability": 0.9984889'+
                            '},'+
                            '{'+
                                '"label": "Einstein_Dealership_Bot_ld1-Sales_Information",'+
                                '"probability": 0.00033304645'+
                            '},'+
                            '{'+
                                '"label": "Einstein_Dealership_Bot_ld1-Confused",'+
                                '"probability": 0.000053200347'+
                            '}'+
                        '],'+
                        '"object": "predictresponse"'+
                    '}';
        } else if(req.getEndpoint().contains('/language/sentiment')) {
            body = '{'+
                        '"probabilities": ['+
                            '{'+
                                '"label": "positive",'+
                                '"probability": 0.9984889'+
                            '},'+
                            '{'+
                                '"label": "neutral",'+
                                '"probability": 0.00033304645'+
                            '},'+
                            '{'+
                                '"label": "negative",'+
                                '"probability": 0.000053200347'+
                            '}'+
                        '],'+
                        '"object": "predictresponse"'+
                    '}';
        }
        res.setBody(body);

        return res;
    }

}