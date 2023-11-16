# LIFI WEB APPLICATION

This is a simple node app using the express framework and mysql library. The entrypoint to this application is the index.js.

This project has 3 endpoints;
- /status GET ; This endpoint lets you know that the application is alive.
- /data POST ; This endpoint takes in 3 parameters namely username, email, age and stores the data in an RDS database we have deployed with Terraform and configured in db.js file
- /users GET ; this endpoint connects to the database and fetches all data

This Simple Web Aplication is containerized with Docker and deployed into Kubernetes. The Dockerfile can be found in the root modul ewhile the Kubernets mnanifests can be found in the /K8s directory in the root module.

Deploying this application to Kubernetes is managed with Github Actions, found in `.github/workflows/.deploy-webapp.yaml`

## SETTING UP THE PROJECT - WEB APPLICATION 


## SETTING UP THE PROJECT - INFRASTRUCTURE AS CODE


# LIFI INFRASTRUCTURE AS CODE
The IaC choice for this infrastructure is Terraform 

The entrypoint to terraform is the main.tf file. Within this file, I deployed AWS Virtual Private Cloud (VPC), AWS Elastic Kubernetes Service (EKS), and AWS Elastic Container Registry (ECR), AWS Relational Database Service (RDS), Remote State with S3, Prometheus and Fluentbit with Cloudwatch amongst many other resources. 

All of these services work together in ensuring a fully functional kubernetes cluster. 
Some of these modules were deployed out of the bnox with aws manages modules on terraform registry, while some others were created in the /modules directory with specific configurations.

This module utilizes Remote State to store our terraform state as a key in an s3 bucket. This is found in /modules/remote-state
Monitoring was also setup with prometheus through the kube-prometheu-stack hekm template. This is found in /modules/kube-prometheus-stack
Logging to Cloudwatch was setup with Fluentbot as a lightweight logshipper and an output of cloudwatch log group. This is found in /modules/fluentbit




## IMPROVEMENTS
As this is a simple solution, a couple of improvements neeed to be factored in when implementing this in production. Few of which I would highlight below:
- Implement Gitops with a tool of choice e.g ArgoCD to manage Kubernetes resources like Prometheus, FluentBit etc
- Configure tighter security for RDS Module and implement Deletion Protection 
- Manage User Authentication to EKS as a separate Module, hence keeping the EKS module lean
- Manage ingress with reverse proxy / loadbalancer
- Configure RBAC
- Tight Security group and vpc access instead of making RDS public



# CICD WITH GITHUB ACTIONS
There are two workflows files deploying the terraform infrastructure as well as the web application respectiely.
To configure the Variables for the Github Actions, some secrets have been reference that need to be populated withinGithub settings
- AWS_ACCESS_KEY_ID; this is used to authenticate the AWS account 
- AWS_SECRET_ACCESS_KEY :this is used to authenticate into the aws account
- RDS_HOSTNAME; this is used to deploy the webapp
- RDS_USERNAME
- RDS_PASSWORD


## SETTING UP THE PROJECT
Seeing as the entirety of this project is divided into the web application and theinfrastructure, so is the deployment.
### To Deploy Terraform
The secrets mentioned above need to be configured, and once they are the workflow .deply-terraform can be triggered to provision our infrastructure on AWS
Similarly, to deploy the web app, the workflow .deploy-web-app must be triggered to build, push and deploy our node app into kubernetes.

Once the web app is deployed into kubernetes, we can test our endpoints by accessing the loadbalancer endpoint. The Kubernetes manifest deploys a service of type loadbalancer that provisions a classic loadbalancer on AWS for the sake of testing


#### References
https://stackabuse.com/using-aws-rds-with-node-js-and-express-js/
https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-nodejs.rds.html
