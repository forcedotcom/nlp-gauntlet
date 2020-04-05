# Mock Model Service

Included with this project there is a Rest Apex service that functions as a Mock Model service that can be used to quickly test a service.

The mock service is configured to understand the following intents & entities for a Car Dealership domain:

Intent : 

- Make Appointment
- Lookup Appointment


Entities :

- Car Make (e.g. Tesla, Honda, ..)
- Appointment Type (e.g. Repair, Maintenance)

This mock service works by doing a direct match on both intents and entities, to see the list of supported utterances and values you can take a look the code [here](/sfdx-source/services/mock/classes/ExternalNlpMockModelAPI.cls).

# Configuring the Mock Model Service

Even though this is a mock service that runs in your Salesforce Org, we still need to configure our org in order to be able to make http calls to itself. The following steps will guide through the setup steps needed to achieve this:


## 1 - Create a Self-Signed Certificate

This project includes a test certificate (external_nlp_smaple_cert), you can use this but it's recommended you create your own by doing the following :

1. Click Setup, then enter Certificate and Key Management into the Quick find box. Click on Certificate and Key Management.
2. Click Create Self-Signed Certificate. In the Label field, give it a recognizable name and keep all other defaults. Click Save.
3. Click Download Certificate.

![Mock Model Setup](/docs/guides/images/mock/mock1.png?raw=true)

## 2 - Create a New Connected App

1. Click Setup, then enter App Manager into the Quick find box. Click on App Manager.
2. Click the New Connected App button.

![Mock Model Setup](/docs/guides/images/mock/mock2.png?raw=true)

3. Create a Connected App with the following parameters 


    - Connected App Name: The name of the app
    - Contact Email: The email address attached to your Salesforce account
        - Select `Enable OAuth Settings` and enter the following information:
    - Callback URL: `https://localhost`
    - Use Digital Signature: Enabled
        - Once enabled, a Choose File button will appear. Click on it and attach the certificate downloaded in Step 1-3.
    - Move the following OAuth Scopes from Available to Selected:
        - Access and manage your data (api)
        - Access your basic information (id, profile, email, address, phone)
        - Perform requests on your behalf at any time (refresh_token, offline_access)


![Mock Model Setup](/docs/guides/images/mock/mock3.png?raw=true)

Click Save. You may receive a message that the Connected App is being created in thebackground, if so click Continue.

4. The connected app screen will now include a Consumer Key, which should be copied for future use.


![Mock Model Setup](/docs/guides/images/mock/mock4.png?raw=true)

5. Click the Manage button on your connected app, and then Edit Policies.
6. Set the Permitted Users drop-down to “Admin approved users are pre-authorized” and click Save.
7. In the Profiles section, click on Manage Profiles and then add the profile attached to the user you plan to use in the Named Credential. Click Save.


## 3 - Create a Named Credential

This projectd also includes a test named credential for the mock service (Samples_ExternalNlpMockModelNamedCredential). You can use this as a reference but it's recommended you create your own :


1. Click Setup, then enter Named Credentials into the Quick find box. Click on Named Credentials and then click New.

2. Create a Named Credential called “MockNlpServiceNamedCredential” with the following parameters:

![Mock Model Setup](/docs/guides/images/mock/mock5.png?raw=true)

- Label:  `MockNLPServiceNamedCredential`
- URL: `https://<instance>.salesforce.com`
- Identity Type: `Named Principal`
- Authentication Protocol: `JWT Token Exchange`
- Token Endpoint URL: `https://<instance>.salesforce.com/services/oauth2/token`
- Issuer: Consumer Key from the Connected App
- Named Principal Subject: Your Salesforce Username
- Audiences: `https://login.salesforce.com` (or `https://test.salesforce.com` for sandboxes)
- Token Valid for: `5 minutes`
- JWT Signing Certificate: pick your previously created certificate from the dropdown.

3. Click Save.

# Testing the Mock Model Service

Next, we can try out the service integration by launching the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

Set the following parameters in the workbench and click the `Test` button :

- Type :  `External Nlp Mock Model`
- Additional Parameters :<empty>
- Intent Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- NER Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7

- Named Credential : The Name of the Named Credential you created for this integration
- Model Id : This should be set to `ExternalNlpMockModelAPI`

- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on. 

![Mock Model Setup](/docs/guides/images/mock/mock6.png?raw=true)