# ultimate.ai setup

1 - ultimate.ai for now does not have a self service account creation. If you don't have an account through having been in contact with ultimate.ai, contact ultimate.ai with email at support@ultimate.ai

2 - Setup intents and entities using ultimate.ai dashboard at https://dashboard.ultimate.ai

3 - Go to settings page and copy the API token. Also copy the bot's id that can be found in the url: https://dashboard.ultimate.ai/bot/{botId}/settings

4 - Create a Named Credential for ultimate.ai with the aforementioned token

- URL : https://chat.ultimate.ai
- Identity Type : Named Principal
- Authentication Protocol : Password Authentication
- Username : apiToken
- Password: < your api token>
- Generate Authorization Header : Un-Checked
- Allow Merge Fields in HTTP Header : Checked
- Allow Merge Fields in HTTP Body : Un-Checked

5 - Next, we can try out the service integration by running the Nlp Gauntlet Workbench in `/apex/ExternalNlpWorkbench`

Set the following parameters in the workbench and click the `Test` button :

- Type :  `Ultimate.ai`
- Additional Parameters : < empty >
- Intent Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- NER Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7
- Sentiment Confidence Threshold : Set to a value between 0 and 1, if empty it defaults to 0.7

- Named Credential : The Name of the Named Credential you created for this integration
- Model Id : This is the botId from step 3

- Language : Your desired language
- Time Zone : Your desired timezone
- Input Text : The text you would like to get predictions on. 
