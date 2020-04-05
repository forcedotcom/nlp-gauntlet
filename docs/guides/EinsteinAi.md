1- Create an Einstein.ai account (https://api.einstein.ai/signup) 

- Proceed to step 4 if you already have an Einstein.ai account provisioned for your org
- Take note of the private key provided as part of the sign-up process will be used later

![Einstein.ai Setup](/docs/guides/images/einsteinAi/eai1.png?raw=true)

2- Create a Remote Site Setting for Einstein.Ai 

- From Setup, enter Remote Site in the Quick Find box, then select Remote Site Settings
- Click New Remote Site
- Enter a name for the remote site
- In the Remote Site URL field, enter https://api.einstein.ai
- Click Save

3- Upload a new data set and train a new model

- [This trail](https://trailhead.salesforce.com/en/content/learn/modules/einstein_intent_basics/einstein_intent_basics_prep) is a good place to start with Einstein.ai.

4- If you already have a certificate in your organization for Einstein Platform services proceed to step 5, otherwise perform the following steps :

4a- Obtain your private key 

- Right after signing up for an Einstein.ai account, you should'be been presented with a private key.
- Store the contents of this private key in a temporary location as we will needed it later since we will rotate this key with a new key that is stored in a new certificate in Salesforce.

4b- Create a new certificate in your organization

- Go to Setup > Security > Certificate and Key Management and click "Create Self-Signed Certificate"
- Set a label and a unique namef or your cert
- Key Size : 2048
- Exportable Private Key : Checked
- Save

4c- Extract the public key from your certificate

- Back in the Certificate and Key Management list, click on the Certificate name you created in step 4a
- Click the "Download Certificate" button and store the .crt file in a known location
- Open a terminal window and type the following command

`openssl x509 -pubkey -noout -in YOUR_CERT_NAME.crt`

- You should see the publick key for your cert between `-----BEGIN PUBLIC KEY-----` and `-----END PUBLIC KEY-----`
- Copy the contents of the public key between these two tags and store in a temporary location, this will be the new public key we will upload to Einstein.ai in the next step

![Einstein.ai Setup](/docs/guides/images/einsteinAi/eai2.png?raw=true)

4d- Rotate your key

- Go to `/apex/EinsteinAiKeyMgmt`
- In the `Key Information` section, enter the following:

- Einstein.ai Email : < the email associated your Einstein.ai account >
- Private Key : The contents for your Einstein Account private key without the `-----BEGIN` or `-----END` tags (obtained in step 4a)
- Certificate Name : < leave empty for now >
- Use Staging endpoint : < leave un-checked unless you are testing beta features >
- Einstein.AI Public Key : < leave empty for now >

- Click the `Get Keys` button and you should see the `Einstein.AI Public Key` drop-down populate with a Default (Active) key.

- In the `Add a new key` section, enter the following:

- Public Key Name : <a name for your new einstien key (e.g. EinsteinAI)>
- Public Key : The contents for your Salesforce Certificate public key without the `-----BEGIN` or `-----END` tags (obtained in step 4c)
- Set as active : Checked

- Click the `Add Key` button

4e - Validate rotation

- Go to `/apex/EinsteinAiKeyMgmt`

- In the `Key Information` section, enter the following:
- Einstein.ai Email : < the email associated your Einstein.ai account >
- Private Key : < leave empty >
- Certificate Name : The developer name of the certificate created in step 4b
- Use Staging endpoint : < leave un-checked unless you are testing beta features >
- Einstein.AI Public Key : < leave empty for now >

- Click the `Get Keys` button and you should see the `Einstein.AI Public Key` drop-down populate with 2 options now, and your new public key should be the Active one.


5 - Create a Named Credential for Einstein Ai API that uses that uses the certificate that you just uploaded

Go to Setup > Administer > Security Controls > Named Credentials

![Einstein.ai Setup](/docs/guides/images/einsteinAi/einstein1.png?raw=true)

- URL : https://api.einstein.ai
- Identity Type : Named Principal
- Authentication Protocol : JWT Token Exchange
- Token Endpoint Url : https://api.einstein.ai/v2/oauth2/token
- Scope : offline
- Issuer : developer.force.com
- Named Principal Subject : < your einstein ai account email >
- Audiences: https://api.einstein.ai/v2/oauth2/token
- JWT Signing Certificate : < select the Einstein Platform Services certificate >
- Generate Authorization Header : Checked
- Allow Merge Fields in HTTP Header : Un-Checked
- Allow Merge Fields in HTTP Body : Un-Checked


6 - Next, we can try out the service integration by launching the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

Set the following parameters in the workbench and click the `Test` button :

- Type :  `Einstein.ai`
- Additional Parameters : < empty >
- Intent Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- NER Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- Sentiment Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7

- Named Credential : The Name of the Named Credential you created for this integration
- Model Id : The model id for the model you trained in Einstein.ai (use `CommunitySentiment` as Model Id for Sentiment Analysis)


- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on.
