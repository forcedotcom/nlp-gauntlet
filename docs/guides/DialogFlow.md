1- Create an account with Google

2- Sign in to Dialog Flow using your Google Account (https://dialogflow.com (https://dialogflow.com/))

3- Create a new Agent and configure with intents

- [This tutorial](https://dialogflow.com/docs/tutorial-build-an-agent/create-customize-agent) is a good place to start with dialogflow.

- *NOTE: Since we only care about the NLP part of Dialogflow, there’s no need to create responses under each intent.*

![Dialogflow Setup](/docs/guides/images/dialogFlow/df1.png?raw=true)

4- Go to the google cloud project attached to the service account for this project

![Dialogflow Setup](/docs/guides/images/dialogFlow/df2.png?raw=true)

5- Create a new service account with the following parameters

![Dialogflow Setup](/docs/guides/images/dialogFlow/df3.png?raw=true)

6- Give it a name

![Dialogflow Setup](/docs/guides/images/dialogFlow/df4.png?raw=true)

7- Select the Dialogflow API Admin role

![Dialogflow Setup](/docs/guides/images/dialogFlow/df5.png?raw=true)

8- Create a private key in P12 format

![Dialogflow Setup](/docs/guides/images/dialogFlow/df6.png?raw=true)

![Dialogflow Setup](/docs/guides/images/dialogFlow/df7.png?raw=true)

9- Note the secret and save the key in your local file system

![Dialogflow Setup](/docs/guides/images/dialogFlow/df8.png?raw=true)

10- Create a java key store file to import the key provided by google into your salesforce org.

Open a terminal and type the following command:

`keytool -importkeystore -srckeystore <private-key-from-google.p12> -destkeystore keystorefile.jks -srcstoretype pkcs12 -srcstorepass notasecret -deststorepass notasecret -deststoretype jks -destalias google_cloud -srcalias privatekey`

This will create a java keystore file with name keystorefile.jks with a certificate named google_cloud, and password notasecret (what Google exports)

![Dialogflow Setup](/docs/guides/images/dialogFlow/df9.png?raw=true)

11- Next, go to Setup > Security > Certificate and Key Management and click "Import from Keystore“

![Dialogflow Setup](/docs/guides/images/dialogFlow/df10.png?raw=true)

12- Select the keystorefile you just created and enter the password (notasecret)

![Dialogflow Setup](/docs/guides/images/dialogFlow/df11.png?raw=true)

13- You should see a new self-signed cert called “google_cloud” after you save

![Dialogflow Setup](/docs/guides/images/dialogFlow/df12.png?raw=true)

14- Next, create a Named Credential for Google Dialog Flow API that uses the certificate that you just uploaded

Go to Setup > Administer > Security Controls > Named Credentials

![Dialogflow Setup](/docs/guides/images/dialogFlow/df13.png?raw=true)

![Dialogflow Setup](/docs/guides/images/dialogFlow/df14.png?raw=true)

- URL : https://dialogflow.googleapis.com
- Identity Type : Named Principal
- Authentication Protocol : JWT
- Issuer & Named Principal Subject : < your google cloud service account >
- Audiences: https://dialogflow.googleapis.com/google.cloud.dialogflow.v2.Sessions
- JWT Signing Certificate : < select the cert you previously created for this integration >
- Generate Authorization Header : Checked
- Allow Merge Fields in HTTP Header : Un-Checked
- Allow Merge Fields in HTTP Body : Un-Checked


15 - Next, we can try out the service integration by launching the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

Set the following parameters in the workbench and click the `Test` button :

- Type :  `Dialog Flow`
- Additional Parameters : Dialog flow requires a sessionId, by default this sessionID is set to the current timestamp, to override set this field to `sessionId=12345`
- Intent Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- NER Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7

- Named Credential : The Name of the Named Credential you created for this integration
- Model Id : The Project id for your dialog flow agent

- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on. 