public with sharing class EinsteinAiKeyMgmtCtrl {

    private static final String EINSTEIN_AI_PROD_ENDPOINT = 'https://api.einstein.ai';
    private static final String EINSTEIN_AI_STG_ENDPOINT = 'https://api.stg.einstein.ai';

    public String userEmail{get;set;}
    public Boolean useStagingEndpoint{get;set;}
    public String publicKeyName{get;set;}
    public String publicKey{get;set;}
    public Boolean publicKeyActive{get;set;}
    public List<SelectOption> publicKeys{get;set;}
    public String selectedPublicKey{get;set;}
    public String certName{get;set;}

    public transient String privateKey{get;set;}

    public EinsteinAiKeyMgmtCtrl() {
        this.useStagingEndpoint = false;
        this.publicKeyActive = false;
        this.publicKeys = new List<SelectOption>{
            new SelectOption('-1', '-- None --', false)
        };
    }

    public PageReference activateKey() {
        try{
            if (String.isBlank(selectedPublicKey)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'A key must be selected for activation'));
                return null;
            }
            HTTPResponse res = makeRequest('/v2/keys/'+selectedPublicKey, 'PUT', null, null, true);
            if (res.getStatusCode() == 200) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Key successfully activated'));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to activate key '+res.getBody()));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference addKey() {
        try{
            if (String.isBlank(publicKey) || String.isBlank(publicKeyName)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'A public key value and name must be provided'));
                return null;
            }
            Map<String, Object> bodyMap = new Map<String, Object>{
                'publicKey' => publicKey,
                'name' => publicKeyName,
                'active' => String.valueOf(publicKeyActive)
            };
            HTTPResponse res = makeRequest('/v2/keys', 'POST', JSON.serialize(bodyMap), 'application/json', true);
            if (res.getStatusCode() == 200) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Key '+publicKeyName+' was successfully added'));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to add key '+res.getBody()));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference getKeys() {
        try{
            HTTPResponse res = makeRequest('/v2/keys', 'GET', null, null, true);
            if (res.getStatusCode() == 200) {
                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                List<Object> dataArr = (List<Object>)resMap.get('data');
                List<SelectOption> opts = new List<SelectOption>();
                for(Object dataObj : dataArr){
                    Map<String, Object> dataMap = (Map<String, Object>)dataObj;
                    String name = (String)dataMap.get('name');
                    Boolean isActive = (Boolean)dataMap.get('active');
                    name += isActive ? ' (Active)' : '';
                    opts.add(new SelectOption((String)dataMap.get('id'), name, false));
                }
                publicKeys = opts;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'List of keys has been updated.'));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference deleteKey() {
        try{
            if (String.isBlank(selectedPublicKey)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'A key must be selected for deletion'));
                return null;
            }
            HTTPResponse res = makeRequest('/v2/keys/'+selectedPublicKey, 'DELETE', null, null, true);
            if (res.getStatusCode() == 204) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Key successfully deleted'));
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to delete key '+res.getBody()));
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    private String getEinsteinAiEndpoint() {
        return useStagingEndpoint ? EINSTEIN_AI_STG_ENDPOINT : EINSTEIN_AI_PROD_ENDPOINT;
    }

    private String getAccessToken() {
        String jwtAssertion = getJWT();
        String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwtAssertion;            
        HTTPResponse res = makeRequest('/v2/oauth2/token', 'POST', body, 'application/x-www-form-urlencoded', false);
        
        String access_token = null;
        if (res.getStatusCode() == 200) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        return access_token;
    }

    private HttpResponse makeRequest(String path, String method, String body, String contentType, Boolean includeAccessToken) {
        HttpRequest req = new HttpRequest();                            
        req.setMethod(method);
        req.setEndpoint(getEinsteinAiEndpoint()+path);
        if (contentType != null) {
            req.setHeader('Content-type', contentType);
        }
        if (includeAccessToken) {
            req.setHeader('Authorization', 'Bearer '+getAccessToken());
        }
        if (body != null) {
            req.setBody(body);
        }
        Http http = new Http();               
        HTTPResponse res = http.send(req);
        return res;
    }

    private String getJWT() {

        Map<String,String> claims = new Map<String, String>();
        String jwt = '';
    
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', 'RS256');
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
            
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', 'developer.force.com');
        body.writeStringField('sub', userEmail != null ? userEmail : '');
        body.writeStringField('aud', getEinsteinAiEndpoint()+'/v2/oauth2/token');
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        body.writeNumberField('iat', rightNow);
        body.writeNumberField('exp', (rightNow + 300)); // Default valid for 5 mins
        if (claims != null) {
            for (String claim : claims.keySet()) {
                body.writeStringField(claim, claims.get(claim));
            }
        }
        body.writeEndObject();

        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));

        Blob signature = null;

        if (!String.isBlank(certName)) {
            signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwt), certName);
        } else {
            Blob privateKeyBlob = EncodingUtil.base64Decode(privateKey != null ? privateKey : '');
            signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), privateKeyBlob);
        }

        jwt += '.' + base64URLencode(signature);
        return jwt;
    }

    private String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')) {
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

}
