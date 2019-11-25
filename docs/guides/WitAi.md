1- Create an account with Wit.ai (https://wit.ai/)

2- Create a new app and configure with intents

- [This](https://wit.ai/docs/quickstart) is a good place to start with wit.ai

- *NOTE: For entity detection, it's recommended to add [Roles](https://medium.com/wit-ai/entities-with-roles-f52fde683637) to your entities to better differentiate between entities*

3- Go to your App Settings and copy the Server Access Token 

![Wit.ai Setup](/docs/guides/images/witAi/wit1.png?raw=true)

4- Next, create a Named Credential for Wit Ai API that uses your applicaction access token

Go to Setup > Administer > Security Controls > Named Credentials

![Wit.ai Setup](/docs/guides/images/witAi/wit2.png?raw=true)

- URL : https://api.wit.ai
- Identity Type : Named Principal
- Authentication Protocol : Password Authentication
- Username : anonymous
- Password: < your server access token>
- Generate Authorization Header : Un-Checked
- Allow Merge Fields in HTTP Header : Checked
- Allow Merge Fields in HTTP Body : Un-Checked

5 - Next, we can try out the service integration by launching the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

Set the following parameters in the workbench and click the `Test` button :

- Type :  `Wit.ai`
- Additional Parameters : < empty >
- Intent Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- NER Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- Sentiment Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7

- Named Credential : The Name of the Named Credential you created for this integration
- Model Id : The Project id for your dialog flow agent 

- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on. 
