### Shiny Proxy 
This repository contains the deployment procedures for the Open Analytics Shiny Proxy Application. 

Shiny Proxy allows us to deploy shiny applications without using any of the R based technology on the server side. 

 
For a more in-depth introduction on Shiny Proxy check out: 
https://www.shinyproxy.io


### Deployment 
In order to deploy Shiny Proxy, we are using a combination of Terraform and CloudFormation to programmatically 
provision AWS resources based off the source code in the `infrastructure/` folder. 

### terraform 
* The terraform folder defines the AWS resources needed to run the Shiny Proxy application 
* At a high level the deployed infrastructure is represented in the folowing graph
![Shiny Server](../infrastructure/diagrams/shinyserver-arch.png)


### codebuild 
* These scripts are run as apart of of the AWS Code Pipeline deployment process
* They install the required software on the build server and then run the terraform deployment code 


## tf-stack
* These folders are used to keep separate environments for production and development. 
* This may not be necessary since I have specified that the state be tracked in a remote s3 bucket, 
but its better to be safe. 


## Continuous Integration
 This repository has been set up to be apart of a continuous integration pipeline defined here:
 https://github.com/CityOfBoston/cloudformation-templates/blob/master/codepipeline/pipeline-shinyproxy.yml
 
 * This means that any changes committed to the master branch on GitHub will be automatically deployed 
 * Also I have set up another CI pipeline tracking the deployed shiny app, so that any changes committed to the master branch 
 of the shiny app repo get propagated to the deployed application via this pipeline:
 
    https://github.com/CityOfBoston/cloudformation-templates/blob/master/codepipeline/pipeline-shiny-app.yml
 
 
 