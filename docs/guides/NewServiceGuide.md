# Adding a new service

The following guide describes the steps for adding a new service to the NLP Gauntlet.

### 1- Fork this repo

### 2- Create a named credential in your org to connect to your new service

You can create a new credential by going to : `Setup > Administer > Security Controls > Named Credentials`

For example, here's the named credential created for Wit.ai. Create one that contains the right credentials and authentication method for your service

![Wit.ai Setup](/docs/guides/images/witAi/wit2.png?raw=true)

- URL : https://api.wit.ai
- Identity Type : Named Principal
- Authentication Protocol : Password Authentication
- Username : anonymous
- Password: < your server access token>
- Generate Authorization Header : Un-Checked
- Allow Merge Fields in HTTP Header : Checked
- Allow Merge Fields in HTTP Body : Un-Checked


### 3- Create a new folder under `sfdx-source/services`

For example : `sfdx-source/services/my-new-service`

### 4- Update `sfdx-project.json` to include a new package directory

Add a new package directory entry that points to your service directory

```
{
    "path": "sfdx-source/services/my-new-service",
    "default": false,
    "package": "NLP Gauntlet - my-new-service",
    "versionName": "Spring 20",
    "versionDescription": "NLP Gauntlet My New Service integration",
    "versionNumber": "1.0.0.NEXT",
    "definitionFile": "config/project-scratch-def.json",
    "dependencies": [
        {
            "package": "NLP Gauntlet - core",
            "versionNumber": "1.0.0.LATEST"
        }
    ]
}
```

* NOTE: version AND dependencies properties will be used for creating second generation unlocked packages of your new service *

### 5- Create a new class that implements the `ExternalNlpService` interface and overrides the `getPredictionRequests` and `getPredictionResult` methods. 

For example :

```
public with sharing class MyNewService extends ExternalNlpService {

    public override List<HttpRequest> getPredictionRequests(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionRequestParameters params) {
        List<HttpRequest> reqs = new List<HttpRequest>();

        for(ExternalNlpModelParameters modelParams : serviceParams.getModelParams()) {
            String endpoint = 'callout:'+modelParams.getNamedCredentialKey();
            HttpRequest req = new HttpRequest();

            // ODO: Add the right endpoint path and parameters for your request

            req.setEndpoint(endpoint);
            reqs.add(req);
        }

        return reqs;
    }

    public override ExternalNlpPredictionResult getPredictionResult(ExternalNlpServiceParameters serviceParams, ExternalNlpPredictionResultParameters params) {

        Map<String, ExternalNlpIntent> intentsMap = new Map<String, ExternalNlpIntent>();
        ExternalNlpIntent highestScoringExtIntent = null;

        Map<String, List<ExternalNlpEntity>> entitiesMap = new Map<String, List<ExternalNlpEntity>>();

        Map<String, ExternalNlpSentiment> sentimentsMap = new Map<String, ExternalNlpSentiment>();
        ExternalNlpSentiment highestScoringExtSentiment = null;

        List<HttpResponse> responses = params.getHttpResponses();
        
        for (HttpResponse response : responses) {
            // TODO: Create ExternalNlp* objects from your http response 
            // and fill-in the corresponding maps with the extracted values
        }

        // Fill-in results with the corresponding maps and top values
        String highestConfidenceIntentName = null;
        if (highestScoringExtIntent != null && highestScoringExtIntent.getConfidenceScore() >= serviceParams.getIntentThreshold()) {
            highestConfidenceIntentName = highestScoringExtIntent.getName();
        }

        ExternalNlpPredictionIntentResult intentPredResult = new ExternalNlpPredictionIntentResult.Builder()
            .setHighestConfidenceIntentName(highestConfidenceIntentName)
            .setPredictedIntents(intentsMap)
            .build();

        ExternalNlpPredictionEntityResult entityPredResult = new ExternalNlpPredictionEntityResult.Builder()
            .setPredictedEntities(entitiesMap)
            .build();

        String highestConfidenceSentimentName = null;
        if (highestScoringExtSentiment != null && highestScoringExtSentiment.getConfidenceScore() >= serviceParams.getSentimentThreshold()) {
            highestConfidenceSentimentName = highestScoringExtSentiment.getName();
        }

        ExternalNlpPredictionSentimentResult sentimentPredResult = new ExternalNlpPredictionSentimentResult.Builder()
            .setDocumentSentiment(new ExternalNlpDocumentSentiment.Builder()
                .setHighestConfidenceSentimentName(highestConfidenceSentimentName)
                .setPredictedSentiments(sentimentsMap)
                .build())
            .build();

        // Return an ExternalNlpPredictionResult with all of the extracted data
        return new ExternalNlpPredictionResult.Builder()
            .setIntentResults(intentPredResult)
            .setEntityResults(entityPredResult)
            .setSentimentResults(sentimentPredResult)
            .build();
    }

}


```

### 6- Add a new External Nlp Service Definition Custom Metadata entry for your service

In order to test your service through `/apex/ExternalNlpWorkbench` or to instantiate using Custom Metadata, you must first create a definition entry to register your new service class.

- Go to `Setup > Custom Code > Custom Metadata` and click `Manage Records` next to `External Nlp Service Definition`
- Click the `New` button to add a new service definition
- Add a Label and Developer Name for your Service and enter the name of your new Apex Class in the `Apex Class` field then Save.

### 7- Try it out in the External Nlp Workbench

Go to `/apex/ExternalNlpWorkbench`, under the `Type` field you should see your new service definition listed. 
Select that option to make sure your Apex class is used, and set the additional parameters to test your integration.
Including the named credential you created in Step 1.

### 8- Add tests

Make sure you add tests for your service by adding a `test` directory under your service folder.

For example : `sfdx-source/main/services/my-new-service/test/apex/MyNewServiceTest.cls`

### 9- Add Documentation

Make sure you include documentation on how to setup an account with your service and how to configure a named credential to work with your service.

Please add a markdown file under `/docs/guides/MyNewService.md`, you can use other markdown files in this folder as reference.

### 10 - Submit your PR

Please submit a pull request from your fork with all of the changes described above

