# Watson Setup

0 - Create an account with Ibm Cloud (https://cloud.ibm.com/registration)

---

## Using Watson Assistant API

1 - Create a new Watson Assistant service.

2 - Create a new skill and configure with your intents/entities.

[This](https://cloud.ibm.com/docs/services/assistant?topic=assistant-getting-started) is a good place to start with Watson Assistant

3 - Go to your "View API Details" of your skill and copy the Skill Id and the Password.

![Watson Assistant Setup](/docs/guides/images/watson/watson1.png?raw=true)
![Watson Assistant Setup](/docs/guides/images/watson/watson2.png?raw=true)

4 - Next, create a Named Credential for Watson API that uses your API Key

    Go to Setup > Administer > Security Controls > Named Credentials

![Watson Assistant Setup](/docs/guides/images/watson/watson3.png?raw=true)

- URL : https://gateway.watsonplatform.net
- Identity Type : Named Principal
- Authentication Protocol : Password Authentication
- Username : apikey
- Password: < Password that was copied from step 3 >
- Generate Authorization Header : Checked
- Allow Merge Fields in HTTP Header : Un-Checked
- Allow Merge Fields in HTTP Body : Un-Checked

5 - Next, we can try out the service integration by running the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

    Set the following parameters in the workbench and click the `Test` button :

- Type :  `Watson`
- Additional Parameters : < empty >
- Intent Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- NER Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7

- Named Credential : The Name of the Named Credential you created for this integration
- Model Id : This is the Skill Id that was copied from step 4

- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on. 

---

## Using Watson Tone Analyzer API

1 - Create a new Watson Tone Analyzer service.

![Watson Tone Setup](/docs/guides/images/watson/watsontone1.png?raw=true)

2 - Go to the resource management section and copy the API Key

![Watson Tone Setup](/docs/guides/images/watson/watsontone2.png?raw=true)

3 - Next, create a Named Credential for Watson API that uses your API Key

    Go to Setup > Administer > Security Controls > Named Credentials

![Watson Assistant Setup](/docs/guides/images/watson/watson3.png?raw=true)

- URL : https://gateway.watsonplatform.net
- Identity Type : Named Principal
- Authentication Protocol : Password Authentication
- Username : apikey
- Password: < Password that was copied from step 2 >
- Generate Authorization Header : Checked
- Allow Merge Fields in HTTP Header : Un-Checked
- Allow Merge Fields in HTTP Body : Un-Checked

4 - Next, we can try out the service integration by launching the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

    Set the following parameters in the workbench and click the `Test` button :

- Type : `WATSON`
- Named Credential Key : the Named Credential you created for this integration
- Model Id : `Tone`
- Additional Parameters : < empty >

- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on. 

--

## Using Watson NLU API for Emotion / Sentiment Analysis

1 - Create a new Watson NLU service.

![Watson NLU Setup](/docs/guides/images/watson/watsonnlu1.png?raw=true)

2 - Go to the resource management section and copy the API Key

![Watson NLU Setup](/docs/guides/images/watson/watsonnlu2.png?raw=true)

3 - Next, create a Named Credential for Watson API that uses your API Key

    Go to Setup > Administer > Security Controls > Named Credentials

![Watson NLU Setup](/docs/guides/images/watson/watson3.png?raw=true)

- URL : https://gateway.watsonplatform.net
- Identity Type : Named Principal
- Authentication Protocol : Password Authentication
- Username : apikey
- Password: < Password that was copied from step 2 >
- Generate Authorization Header : Checked
- Allow Merge Fields in HTTP Header : Un-Checked
- Allow Merge Fields in HTTP Body : Un-Checked

4 - Next, we can try out the service integration by launching the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

    Set the following parameters in the workbench and click the `Test` button :

- Type : `WATSON`
- Named Credential Key : the Named Credential you created for this integration
- Model Id : `Emotion` OR `Sentiment` OR `Emotion,Sentiment`
- Additional Parameters : < empty >

- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on.