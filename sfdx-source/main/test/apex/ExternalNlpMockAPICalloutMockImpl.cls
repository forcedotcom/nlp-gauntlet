public with sharing class ExternalNlpMockAPICalloutMockImpl implements HttpCalloutMock {

   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        if(req.getEndpoint().contains('/predict')){
            body = '{'+
                        '"intents": ['+
                            '{'+
                                '"name": "Make_Appointment",'+
                                '"probability": 0.9984889'+
                            '},'+
                            '{'+
                                '"name": "Lookup_Appointment",'+
                                '"probability": 0.00033304645'+
                            '},'+
                            '{'+
                                '"name": "Cancel_Appointment",'+
                                '"probability": 0.000053200347'+
                            '}'+
                        '],'+
                        '"entities": ['+
                            '{'+
                                '"value": "Tesla",'+
                                '"probability": 0.9984889,'+
                                '"name": "Car_Make"'+
                            '},'+
                            '{'+
                                '"value": "Repair",'+
                                '"probability": 0.9984889,'+
                                '"name": "Appointment_Type"'+
                            '}'+
                        '],'+
                        '"sentiments": ['+
                            '{'+
                                '"name": "Positive",'+
                                '"probability": 0.9984889'+
                            '},'+
                            '{'+
                                '"name": "Neutral",'+
                                '"probability": 0.00033304645'+
                            '},'+
                            '{'+
                                '"name": "Negative",'+
                                '"probability": 0.000053200347'+
                            '}'+
                        '],'+
                        '"tones": ['+
                            '{'+
                                '"name": "Analytical",'+
                                '"probability": 0.9984889'+
                            '},'+
                            '{'+
                                '"name": "Tentative",'+
                                '"probability": 0.00033304645'+
                            '},'+
                            '{'+
                                '"name": "Confident",'+
                                '"probability": 0.000053200347'+
                            '}'+
                        '],'+
                        '"emotions": ['+
                            '{'+
                                '"name": "Joy",'+
                                '"probability": 0.9984889'+
                            '},'+
                            '{'+
                                '"name": "Anger",'+
                                '"probability": 0.00033304645'+
                            '},'+
                            '{'+
                                '"name": "Fear",'+
                                '"probability": 0.000053200347'+
                            '}'+
                        ']'+
                    '}';
        }
        res.setBody(body);

        return res;
    }

}