# Microsoft LUIS Setup

0 - Create an account with Microsoft LUIS (https://www.luis.ai/)

---

## Using Microsoft LUIS API

1 - Create Azure resource. [This](https://docs.microsoft.com/en-us/azure/cognitive-services/luis/luis-get-started-create-app#sign-in-to-luis-portal) is a good place to start with LUIS.

2 - Create a new app. [Useful Resource](https://docs.microsoft.com/en-us/azure/cognitive-services/luis/luis-get-started-create-app#create-a-new-app)

3 - Configure your app by adding your intents/entities. [Useful Resource](https://docs.microsoft.com/en-us/azure/cognitive-services/luis/luis-get-started-create-app#intents-and-entities)

4 - Go to your "Manage" tab > Azure Resources and copy the primary key and endpoint URL.

![LUIS Setup](/docs/guides/images/luis/luis1.png?raw=true)

5 - Next, create a Named Credential for LUIS API that uses your primary key and endpoint URL

    Go to Setup > Administer > Security Controls > Named Credentials

![Watson Assistant Setup](/docs/guides/images/luis/luis2.png?raw=true)

- URL : < URL copied from Step 4 >
- Identity Type : Named Principal
- Authentication Protocol : Password Authentication
- Username : anonymous
- Password: < Primary Key that was copied from Step 4 >
- Generate Authorization Header : Un-Checked
- Allow Merge Fields in HTTP Header : Checked
- Allow Merge Fields in HTTP Body : Un-Checked

5 - Next, we can try out the service integration by running the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

    Set the following parameters in the workbench and click the `Test` button :

- Type :  `Luis`
- Additional Parameters : < empty >
- Intent Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- NER Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7

- Named Credential : The Name of the Named Credential you created for this integration
- Model Id : This is the Skill Id that was copied from step 4

- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on. 