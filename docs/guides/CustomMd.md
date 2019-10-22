You can leverage Custom Metadata Types to store your connection and model settings. This project provides a couple of metadata types that can be consumed by the ExternalNlpWorkbench page or by the `ExternalNlpServiceFactory` in your Apex code.

1- Go to Custom Metadata Types in Setup. Setup -> Custom Code > Custom Metadata Types

2- First, create a new `External Nlp Service Setting` metadata record by clicking on the `Manage Records` link next to this row.

![Custom Metadata Setup](/docs/guides/images/customMd/cmd1.png?raw=true)

3- Enter the corresponding parameters for your External Nlp Service configuration. This is where you will store information like :

- Service Definition (Select a registered service definition from the list)
- Intent Confidence Threshold
- NER Confidence Threshold
- Sentiment Confidence Threshold
- Additional parameters (comma separated values)


Below is a sample of the parameteres use by a Microsoft Luis configuration.

![Custom Metadata Setup](/docs/guides/images/customMd/cmd2.png?raw=true)

4- Once you've created your `External Nlp Service Setting`,  you can go back to the Custom Metadata Types setup page and click the `Manage Records` link next to the `External Nlp Model Setting` row.

Here is where you will store information for your model :

- Model Id
- Named Credential (Developer Name of the Named Credentials that will be used for this model)

Below is a sample of the parameters use by a model that references Microsoft Luis Service setting configuration created in a previous step.

![Custom Metadata Setup](/docs/guides/images/customMd/cmd3.png?raw=true)

5- To try it out, go to the External Nlp Workbench (`/apex/ExternalNlpWorkbench`) and select your configuratio in the section below. You should see the configuration and model parameters update to match the values you stored in your custom metadata settings.

![Custom Metadata Setup](/docs/guides/images/customMd/cmd4.png?raw=true)

