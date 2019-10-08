public with sharing class EinsteinAiKeysAPICalloutMockImpl implements HttpCalloutMock {

   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;

        String requestMethod = req.getMethod();

        if (requestMethod == 'DELETE') {
            res.setStatusCode(204);
        } else {
            res.setStatusCode(200);
        }
        
        if(req.getEndpoint().contains('/v2/keys')){
            if (requestMethod == 'GET') {
                body = '{'+
                            '"data": ['+
                                '{'+
                                    '"id": "1",'+
                                    '"name": "default",'+
                                    '"createdAt": "2017-05-31T18:28:52Z",'+
                                    '"organizationId": "1000001",'+
                                    '"active": true,'+
                                    '"updatedAt": "2017-06-23T11:58:08Z",'+
                                    '"object": "key"'+
                                '},'+
                                '{'+
                                    '"id": "2",'+
                                    '"name": "My Key",'+
                                    '"createdAt": "2017-07-07T18:28:52Z",'+
                                    '"organizationId": "1000001",'+
                                    '"active": false,'+
                                    '"updatedAt": "2017-07-07T11:58:08Z",'+
                                    '"object": "key"'+
                                '}'+
                            '],'+
                            '"object": "list"'+
                        '}';
            } else if (requestMethod == 'PUT' || requestMethod == 'POST') {
                body = '{'+
                            '"id": "2",'+
                            '"name": "My Key",'+
                            '"createdAt": "2017-07-07T18:28:52Z",'+
                            '"organizationId": "1000001",'+
                            '"active": true,'+
                            '"updatedAt": "2017-07-07T11:58:08Z",'+
                            '"object": "key"'+
                        '}';
            }
        } else if(req.getEndpoint().contains('/v2/oauth2/token')){
                body = '{'+
                            '"access_token": "some_token",'+
                            '"token_type": "Bearer",'+
                            '"expires_in": "120"'+
                        '}';
        }

        if (requestMethod != 'DELETE') {
            res.setBody(body);
        }

        return res;
    }

}
