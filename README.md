![CI](https://github.com/forcedotcom/nlp-gauntlet/workflows/CI/badge.svg)

# Nlp Gauntlet

The Nlp Gauntlet was designed to hold any number of external Natural Language Processing services, better known as NLP services. When used in combination, their already impressive powers make the wearer able to do anything they want.

The goal of this project is to make integration and testing of external NLP services in Apex as easy as snapping your fingers. We achieve this by providing a common interface to invoke and consume results for different NLP service implementations. Having a common output across providers allows swapping NLP services without having to re-write any of the applications that consume the prediction results.

## Installation instructions

### Method 1 : Un-managed package installation

To install using a pre-built package, use the installation links provided [here](https://github.com/forcedotcom/nlp-gauntlet/releases)


### Method 2 : Non-Scratch Org quick deploy

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

### Method 3 : Scratch Org quick deploy

[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com/)


### Method 4 : Scratch Org sfdx CLI deploy

1. Install Salesforce DX. Enable the Dev Hub in your org or sign up for a Dev Hub trial org and install the Salesforce DX CLI. Follow the instructions in the [Salesforce DX Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm?search_text=trial%20hub%20org) or in the [App Development with Salesforce DX](https://trailhead.salesforce.com/modules/sfdx_app_dev) Trailhead module.

1. Clone the **nlp-gauntlet** repository:

   ```bash
   git clone https://github.com/forcedotcom/nlp-gauntlet
   cd nlp-gauntlet
   ```

1. Create a scratch org and provide it with an alias (nlp-gauntlet):

   ```bash
   sfdx force:org:create -s -f config/project-scratch-def.json -a nlp-gauntlet
   ```

1. Push the app to your scratch org:

   ```bash
   sfdx force:source:push
   ```

1. Assign the **External Nlp Admin** permission set to the default user:

   ```bash
   sfdx force:user:permset:assign -n External_Nlp_Admin
   ```

1. Open the scratch org:

   ```bash
   sfdx force:org:open
   ```

## Setup instructions

Once you have deployed the source code to your org, you can begin the authorization setup for your corresponding NLP service provider.

The provided service implementations rely on [Named Credentials](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_callouts_named_credentials.htm) to generate the authorization tokens.

This project will create some Sample Named Credentials in your org but you will need to edit/clone these with the right credentials/certificates.

1. Go to *Setup > Security > Named Credentials* and edit the corresponding Named Credential.

    Below you'll find instructions on how to setup and test each specific Nlp Service:

    - [Salesforce Einstein Ai](/docs/guides/EinsteinAi.md)
    - [Google Dialogflow](docs/guides/DialogFlow.md)
    - [Facebook Wit.ai](docs/guides/WitAi.md)
    - [IBM Watson](docs/guides/Watson.md)
    - [Microsoft Luis](docs/guides/Luis.md)
    - [Mock Model Service](docs/guides/MockModel.md)
    - [Ultimate.ai](docs/guides/UltimateAi.md)

2. Next, go to `/apex/ExternalNlpWorkbench` in your browser to verify connectivity and run some tests.

    The Nlp Gauntlet Workbench tool allows you to test out different model configurations. You can also load saved configurations from [Custom Metadata Types](docs/guides/CustomMd.md) in your org.

    ![Nlp Gauntlet Workbench](/docs/images/gauntlet-workbench/gauntlet-workbench.gif?raw=true)

3. Once you've verified the connection and confirmed your models are working correctly. You can consume these predictions from your apex code :

    ```java

        // Instantiate external nlp service
        // Replace with your provider type (e.g. WitAi, Watson, DialogFlow, Luis)
        ExternalNlpService extNlpService = ExternalNlpServiceFactory.makeNlpService(EinsteinAiService.class);

        // Un-comment line below if instantiating from a Custom Metadata Definition
        //ExternalNlpService extNlpService = ExternalNlpServiceFactory.makeNlpService('Einstein_ai');

        // Set model parameters
        List<ExternalNlpModelParameters> modelParams = new List<ExternalNlpModelParameters>{
            new ExternalNlpModelParameters.Builder()
                .setModelId('Your Model/App/Skill/etc Id')
                .setNamedCredentialKey('Your Named Credential Key') // Case-sensitive name
                .build()
        };

        // Set thresholds and additional parameters (if needed)
        ExternalNlpServiceParameters serviceParams = new ExternalNlpServiceParameters.Builder()
            .setModelParams(modelParams)
            .setIntentThreshold((Double)0.7)
            .setNerThreshold((Double)0.7)
            .setSentimentThreshold((Double)0.7)
            .setAdditionalParams(new Map<String, String>())
            .build();

        // Get predictions
        ExternalNlpPredictionResult results = extNlpService.predict(serviceParams, 'Your text to be analyzed', 'en_US');

        // Consume predictions
        System.debug(results.getIntentResults().getPredictedIntents());
        System.debug(results.getIntentResults().getHighestConfidenceIntentName());
        System.debug(results.getEntityResults().getPredictedEntities());
        System.debug(results.getSentimentResults().getDocumentSentiment());

    ```

4. Profit!

    You can now retire on a quiet farm and stare at the universe you just created.

## Adding a new service

To add a new service to the nlp gauntlet follow the steps provided in this [guide](/docs/guides/NewServiceGuide.md)

