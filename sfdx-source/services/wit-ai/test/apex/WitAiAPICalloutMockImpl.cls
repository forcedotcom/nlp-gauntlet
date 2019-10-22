public with sharing class WitAiAPICalloutMockImpl implements HttpCalloutMock {

   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        if(req.getEndpoint().contains('/message')){
            body = '{'+
                        '"_text": "i want to schedule an appointment for my tesla tomorrow at 9 am",'+
                        '"entities": {'+
                            '"Appointment_Date": [{"confidence":0.85160447853199,"values":[{"value":"2019-07-05T09:00:00.000-07:00","grain":"hour","type":"value"}],"value":"2019-07-05T09:00:00.000-07:00","grain":"hour","type":"value"}],'+
                            '"Car_Make": [{"confidence":0.88855520066342,"value":"Tesla","type":"value"}],'+
                            '"intent": [{"confidence":0.64313723530264,"value":"Make_Appointment"}],'+
                            '"sentiment": [{"confidence":0.89855520066342,"value":"positive"}]'+
                        '},'+
                        '"msg_id": "1eKXdlNi5RUIuPGyY"'+
                    '}';
        }
        res.setBody(body);

        return res;
    }

}
