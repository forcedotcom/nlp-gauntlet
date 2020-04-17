### Steps to create and publish new package versions for core package

#### Create Scratch org and do your development

`sfdx force:org:create -a nlpg-core-so --definitionfile config/project-scratch-def.json`

#### Once done, create the Core Package

`sfdx force:package:create -n "NLP Gauntlet - Core" -r sfdx-source/main -t Unlocked`

#### Create a Core Package Version

`sfdx force:package:version:create -p "NLP Gauntlet - Core" --installationkeybypass -w 25`

if you want to exclude certain metadata types, you can use the provided packave version create under scripts

`./package-version-create.sh -p "NLP Gauntlet - Core"`

#### Test Package Version installation

Create a subcriber org and then install the package using one of the following : 

`sfdx force:package:install --package "NLP Gauntlet - Core@1.0.0-1" --targetusername nlpg-subscriber  --wait 15 --publishwait 15`

OR use the installation link `https://login.salesforce.com/packaging/installPackage.apexp?p0=PACKAGE_VERSION_ID`

#### Release Package Version

`sfdx force:package:version:promote -p "NLP Gauntlet - Core@1.0.0-1"`



### Steps to create and publish new package versions for service packages


#### Create Scratch org and do your development

`sfdx force:org:create -a nlpg-service-so --definitionfile config/project-scratch-def.json`

#### Once done, create the Service Package

`sfdx force:package:create -n "NLP Gauntlet - Mock" -r sfdx-source/services/mock -t Unlocked`

#### Create Service Package Version

`sfdx force:package:version:create -p "NLP Gauntlet - Mock" --installationkeybypass -w 25`

if you want to exclude certain metadata types, you can use the provided packave version create under scripts

`./package-version-create.sh -p "NLP Gauntlet - Mock"`

#### Test Package Version installation

Create a subcriber org and then install the package using one of the following : 

`sfdx force:package:install --package "NLP Gauntlet - Mock@1.0.0-1" -u nlpg-subscriber  --wait 15 --publishwait 15`

OR use the installation link `https://login.salesforce.com/packaging/installPackage.apexp?p0=PACKAGE_VERSION_ID`

#### Release Package Version

`sfdx force:package:version:promote -p "NLP Gauntlet - Mock@1.0.0-1"`

### Check packaging limits

`sfdx force:limits:api:display`