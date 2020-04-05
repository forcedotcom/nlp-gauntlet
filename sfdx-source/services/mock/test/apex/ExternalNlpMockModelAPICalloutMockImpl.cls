public with sharing class ExternalNlpMockModelAPICalloutMockImpl implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        if(req.getBody().contains('i want to make an appointment for my tesla please')){
            return respondWithIntent();
        }
        
        if(req.getBody().contains('i want to make an appointment for my tesla')){
            return respondWithOneEntity();
        }

        if(req.getBody().contains('i want to make an appointment to repair my tesla')){
            return respondWithMultipleEntities();
        }
        return null;
    }

   private HTTPResponse respondWithIntent() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{' +
                '"intents": ['+
                    '{'+
                        '"probability": 1.0,'+
                        '"name": "Make_Appointment"'+
                    '}'+
                '],'+
                '"entities": []'+
                '}';
        res.setBody(body);
        return res;
    }

    private HTTPResponse respondWithOneEntity() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{' +
                '"intents": ['+
                    '{'+
                        '"probability": 1.0,'+
                        '"name": "Make_Appointment"'+
                    '}'+
                '],'+
                '"entities": ['+
                    '{'+
                        '"value": "Tesla",'+
                        '"probability": 1.0,'+
                        '"name": "Car_Make"'+
                    '}'+
                ']'+
                '}';
        res.setBody(body);
        return res;
    }

    private HTTPResponse respondWithMultipleEntities() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{' +
                '"intents": ['+
                    '{'+
                        '"probability": 1.0,'+
                        '"name": "Make_Appointment"'+
                    '}'+
                '],'+
                '"entities": ['+
                    '{'+
                        '"value": "Tesla",'+
                        '"probability": 1.0,'+
                        '"name": "Car_Make"'+
                    '},'+
                    '{'+
                        '"value": "Repair",'+
                        '"probability": 1.0,'+
                        '"name": "Appointment_Type"'+
                    '}'+
                ']'+
                '}';
        res.setBody(body);
        return res;
    }
}
