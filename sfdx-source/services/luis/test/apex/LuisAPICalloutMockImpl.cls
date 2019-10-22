public with sharing class LuisAPICalloutMockImpl implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint().contains(EncodingUtil.urlEncode('i want to make an appointment to repair my car tomorrow at 8 pm', 'UTF-8'))){
            return respondSimple();
        }
        
        if(req.getEndpoint().contains(EncodingUtil.urlEncode('withRole: i want to make an appointment to repair my car tomorrow at 9 am', 'UTF-8'))){
            return respondWithRole();
        }

        if(req.getEndpoint().contains(EncodingUtil.urlEncode('I want to make a repair appointment for John Smith', 'UTF-8'))){
            return respondWithNoResolution();
        }
        
        if(req.getEndpoint().contains(EncodingUtil.urlEncode('noIntentMatch: I want to make a repair appointment for john smith', 'UTF-8'))){
            return respondWithNoIntentMatch();
        }
        
        if(req.getEndpoint().contains(EncodingUtil.urlEncode('search for items under $10.99.', 'UTF-8'))){
            return respondWithCurrencyEntity();
        }

        if(req.getEndpoint().contains(EncodingUtil.urlEncode('please send the information to patti.owens@microsoft.com', 'UTF-8'))){
            return respondWithEmailEntity();
        }
        
        if(req.getEndpoint().contains(EncodingUtil.urlEncode('Carol is visiting the sphinx in gizah egypt in africa before heading to texas', 'UTF-8'))){
            return respondWithGeographyV2Entity();
        }
        
        if(req.getEndpoint().contains(EncodingUtil.urlEncode('order two dozen eggs', 'UTF-8'))){
            return respondWithNumberEntity();
        }

        if(req.getEndpoint().contains(EncodingUtil.urlEncode('what is the second to last choice in the list', 'UTF-8'))){
            return respondWithOrdinalV2Entity();
        }

        if(req.getEndpoint().contains(EncodingUtil.urlEncode('set a trigger when my stock goes up 2%', 'UTF-8'))){
            return respondWithPercentageEntity();
        }

        if(req.getEndpoint().contains(EncodingUtil.urlEncode('Bob Jones wants 3 meatball pho', 'UTF-8'))){
            return respondWithSimpleEntity();
        }

        if(req.getEndpoint().contains(EncodingUtil.urlEncode('I want to lookup appointment for tesla and volvo', 'UTF-8'))){
            return respondWithEntityWithMultipleValues();
        }

        if(req.getEndpoint().contains(EncodingUtil.urlEncode('book 2 tickets to roissy', 'UTF-8'))){
            return respondWithEntityWithListEntities();
        }
        
        return null;
    }

   private HTTPResponse respondSimple() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{' +
                '"query": "\'i want to make an appointment to repair my car tomorrow at 8 pm\'",'+
                '"topScoringIntent": {"intent": "Make_Appointment", "score": 0.9703875 },'+
                '"intents": [{"intent": "Make_Appointment","score": 0.9703875},{"intent": "Lookup_Appointment","score": 0.06721009},{"intent": "None","score": 0.00111892086}],'+
                '"entities": ['+
                '{"entity": "repair","type": "Appointment_Type","startIndex": 34,"endIndex": 39,"resolution": {"values": ["Repair"]}},'+
                '{"entity": "tesla","type": "Car_Make","startIndex": 15,"endIndex": 19,"resolution": {"values": ["tesla"]}},' +
                '{"entity": "tomorrow at 8 pm","type": "builtin.datetimeV2.datetime","startIndex": 48,"endIndex": 63,"resolution": {"values": [{"timex": "2019-08-26T20","type": "datetime","value": "2019-08-26 20:00:00"}]}}'+
                ']'+
                '}';
        res.setBody(body);
        return res;
    }

    private HTTPResponse respondWithRole() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{' +
                    '"query": "\'withRole: i want to make an appointment to repair my car tomorrow at 9 am\'",'+
                    '"topScoringIntent": {"intent": "Make_Appointment", "score": 0.9703875 },'+
                    '"intents": [{"intent": "Make_Appointment","score": 0.9703875},{"intent": "Lookup_Appointment","score": 0.06721009},{"intent": "None","score": 0.00111892086}],'+
                    '"entities": ['+
                        '{"entity": "repair","type": "Appointment_Type","startIndex": 34,"endIndex": 39,"resolution": {"values": ["Repair"]}},'+
                        '{"entity": "tesla","type": "Car_Make","startIndex": 15,"endIndex": 19,"resolution": {"values": ["tesla"]}},' +
                        '{"entity": "friday 9am","type": "builtin.datetimeV2.datetime","startIndex": 24,"endIndex": 33,'+
                            '"resolution": {"values": '+
                                    '[{"timex": "XXXX-WXX-5T09","type": "datetime","value": "2019-08-23T09"},'+
                                     '{"timex": "XXXX-WXX-5T09","type": "datetime","value": "2019-08-30T09"}]},'+
                            '"role": "DateTime"}]'+
                '}';
        
        res.setBody(body);
        return res;
    }

    // Note: These are entities which do not get resolved to anything
    // PersonName, keyPhrase, url, Pattern.any, Regular Expression
    private HTTPResponse respondWithNoResolution() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{' +
                    '"query": "\'I want to make a repair appointment for John Smith\'",'+
                    '"topScoringIntent": {"intent": "Make_Appointment", "score": 0.9703875 },'+
                    '"intents": [{"intent": "Make_Appointment","score": 0.9703875},{"intent": "Lookup_Appointment","score": 0.06721009},{"intent": "None","score": 0.00111892086}],'+
                    '"entities": ['+
                    '{"entity": "repair","type": "Appointment_Type","startIndex": 34,"endIndex": 39,"resolution": {"values": ["Repair"]}},'+
                    '{"entity": "john smith","type": "builtin.personName","startIndex": 41,"endIndex": 53}'+
                    ']'+
                    '}';
        
        res.setBody(body);
        return res;
    }

    private HTTPResponse respondWithNoIntentMatch() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{' +
                    '"query": "\'noIntentMatch: I want to make a repair appointment for John Smith\'",'+
                    '"topScoringIntent": {"intent": "Make_Appointment", "score": 0.0970387 },'+
                    '"intents": [{"intent": "Make_Appointment","score": 0.0970387},{"intent": "Lookup_Appointment","score": 0.06721009},{"intent": "None","score": 0.00111892086}],'+
                    '"entities": ['+
                    '{"entity": "repair","type": "Appointment_Type","startIndex": 34,"endIndex": 39,"resolution": {"values": ["Repair"]}},'+
                    '{"entity": "john smith","type": "builtin.personName","startIndex": 41,"endIndex": 53}'+
                    ']'+
                    '}';
        
        res.setBody(body);
        return res;
    }

    //NOTE: Age, Currency, Dimension, Temperature 
    //are all similar where we will only read the value and not the other attribute of the 
    //resolution like unit
    private HTTPResponse respondWithCurrencyEntity() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "search for items under $10.99.",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": [{"entity": "$10.99","type": "builtin.currency","startIndex": 23,"endIndex": 28,"resolution": {"unit": "Dollar","value": "10.99"}}]'+
                '}';
        res.setBody(body);
        return res;
    }

    private HTTPResponse respondWithEmailEntity() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "please send the information to patti.owens@microsoft.com",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": [{"entity": "patti.owens@microsoft.com","type": "builtin.email","startIndex": 31,"endIndex": 55,"resolution": {"value": "patti.owens@microsoft.com"}}]'+
                '}';
        res.setBody(body);
        return res;
    }

    private HTTPResponse respondWithGeographyV2Entity() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "Carol is visiting the sphinx in gizah egypt in africa before heading to texas",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": ['+
                '{"entity": "the sphinx","type": "builtin.geographyV2.poi","startIndex": 18,"endIndex": 27},'+
                '{"entity": "gizah","type": "builtin.geographyV2.city","startIndex": 32,"endIndex": 36},'+
                '{"entity": "egypt","type": "builtin.geographyV2.countryRegion","startIndex": 38,"endIndex": 42},'+
                '{"entity": "africa","type": "builtin.geographyV2.continent","startIndex": 47,"endIndex": 52},'+
                '{"entity": "texas","type": "builtin.geographyV2.state","startIndex": 72,"endIndex": 76},'+
                '{"entity": "carol","type": "builtin.personName","startIndex": 0,"endIndex": 4}'+
                ']}';
        res.setBody(body);
        return res;
    }

    //For numbers we ignore the subtype and only take the value and return the type as builtin.number
    private HTTPResponse respondWithNumberEntity() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "order two dozen eggs",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": [{"entity": "two dozen","type": "builtin.number","startIndex": 6,"endIndex": 14,"resolution": {"subtype": "integer","value": "24"}}]'+
                '}';
        res.setBody(body);
        return res;
    }

    //NOTE: Ordinal V2 will be ignored, resolution does not have 
    // value attribute. You will get value as text and type as uiltin.ordinalV2.relative
    //However, Ordinal will work fine where value is numberic field. 
    private HTTPResponse respondWithOrdinalV2Entity() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "what is the second to last choice in the list",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": [{"entity": "the second to last","type": "builtin.ordinalV2.relative","startIndex": 8,"endIndex": 25,"resolution": {"offset": "-1","relativeTo": "end"}}]'+
                '}';
        res.setBody(body);
        return res;
    }

    //Percentage is returned as text
    //NOTE - There is difference between the response for version 2.0 and Preview API version 3.x. Code is implemented for version 2.0
    private HTTPResponse respondWithPercentageEntity() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "set a trigger when my stock goes up 2%",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": [{"entity": "2%","type": "builtin.percentage","startIndex": 36,"endIndex": 37,"resolution": {"value": "2%"}}]'+
                '}';
        res.setBody(body);
        return res;
    }

    //Simple entities return score
    private HTTPResponse respondWithSimpleEntity() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "Bob Jones wants 3 meatball pho",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": [{"entity": "bob jones","type": "Customer","startIndex": 0,"endIndex": 8,"score": 0.473899543}]'+
                '}';
        res.setBody(body);
        return res;
    }

    //Entities return same entity Name with multiple values
    private HTTPResponse respondWithEntityWithMultipleValues() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "I want to lookup appointment for tesla and volvo",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": [{"entity": "tesla","type": "Car_Make","startIndex": 34,"endIndex": 38,"resolution": {"values": ["tesla"]}},'+
                '             {"entity": "volvo","type": "Car_Make","startIndex": 44,"endIndex": 48,"resolution": {"values": ["volvo"]}}]'+
                '}';
        res.setBody(body);
        return res;
    }

    //Entities representing list values with synonyms
    // Entity [Cities]
    // Paris -> cdg, roissy, ory, 75001, 1, +33
    // book 2 tickets to roissy > should return EntityName = Cities, EntityValue = Paris, MatchedText = roissy
    private HTTPResponse respondWithEntityWithListEntities() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = null;
        res.setStatusCode(200);
        body = '{'+
                '"query": "book 2 tickets to roissy",'+
                '"topScoringIntent": {"intent": "None","score": 0.8236133},'+
                '"entities": [{"entity": "roissy","type": "Cities","startIndex": 18,"endIndex": 23,"resolution": {"values": ["Paris"]}}]'+
                '}';
        res.setBody(body);
        return res;
    }
}
