public with sharing class WatsonAPICalloutMockImpl implements HttpCalloutMock {

   public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        if(req.getEndpoint().contains('/message')){
             body = '{' +
                        '"intents":[{"intent":"General_Greetings", "confidence":0.9728985071182251}, {"intent":"FooBar", "confidence":0.43}],'+
                        '"entities":[{"entity":"sys-person","location":[19,23],"value":"Mark","confidence":0.98885},{"entity":"sys-person","location":[20,24],"value":"Foo","confidence":0.99998885}],'+
                        '"input":{"text":"Hello I need help, Mark was helping me."},'+
                        '"output":{"generic":[{"response_type":"text","text":"Hello. Good afternoon"}],"text":["Hello. Good afternoon"],"nodes_visited":["node_13_1502484041694","node_1_1495022305143"],"log_messages":[]},'+
                        '"context":{"conversation_id":"f204b07a-592f-44cf-a8fe-85a98bbfc35f","system":{"initialized":true,"dialog_stack":[{"dialog_node":"root"}],"dialog_turn_counter":1,"dialog_request_counter":1,"_node_output_map":{"node_1_1495022305143":[0]},"branch_exited":true,"branch_exited_reason":"completed"}}'+
                        '}';
        } else if (req.getEndpoint().contains('/v3/tone')) {
             body = '{' +
                        '"document_tone": {'+
                            '"tones": ['+
                                '{'+
                                    '"score": 0.6165,'+
                                    '"tone_id": "sadness",'+
                                    '"tone_name": "Sadness"'+
                                '},'+
                                '{'+
                                    '"score": 0.829888,'+
                                    '"tone_id": "analytical",'+
                                    '"tone_name": "Analytical"'+
                                '}'+
                            ']'+
                        '}'+
                    '}';
        } else if (req.getEndpoint().contains('/natural-language-understanding/api/v1/analyze')) {
            Map<String, Object> reqMap = (Map<String, Object>)JSON.deserializeUntyped(req.getBody());
            Map<String, Object> featuresMap = (Map<String, Object>)reqMap.get('features');
            body ='{';
            body += '"usage": {' +
                    '"text_units": 1,' +
                    '"text_characters": 64,' +
                    '"features": 1' +
                '},' +
                '"language": "en",';

            List<String> featureResponses = new List<String>();
            if (featuresMap.containsKey('emotion')) {
                featureResponses.add('"emotion": {' +
                            '"document": {' +
                                '"emotion": {' +
                                    '"sadness": 0.765311,' +
                                    '"joy": 0.013818,' +
                                    '"fear": 0.223756,' +
                                    '"disgust": 0.13427,' +
                                    '"anger": 0.154534' +
                                '}' +
                            '}' +
                        '}');
            }

            if (featuresMap.containsKey('sentiment')) {
                featureResponses.add('"sentiment": {' +
                            '"document": {' +
                                '"score": 0.765311,' +
                                '"label": "positive"' +
                            '}' +
                        '}');
            }

            body += String.join(featureResponses, ',');
            body += '}';
        }
        res.setBody(body);

        return res;
    }

}
