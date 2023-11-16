# LIFI: Infrastructure and Web Application

## Overview

Welcome to LIFI Infrastructure and Web Application Project, a simple project structure combining a Node.js application and Terraform infrastructure. This repository is designed to showcase the principles of efficient infrastructure as code (IaC) and modern web application development.

## Project Structure

### 1. Terraform Infrastructure (Terraform)

The `Terraform` directory holds the IaC scripts to deploy and manage the project's infrastructure.

```
Terraform/
|-- modules/
|-- main.tf
|-- variables.tf
|-- providers.tf
|-- ... (other Terraform scripts)
```
#### Setting Up Remote State Locally
To manage remote state, navigate to the modules/remote-state directory. This directory is responsible for configuring the Terraform backend and automates the population of the backend.tf file with details from the S3 bucket.
- Initialize the Terraform workspace for the remote state : `terraform init`
- Apply the infrastructure changes specifically for remote state by running: `terraform apply -target=module.remote-state`
- This command not only instantiates the remote state but also generates and populates the `backend.tf` file.
- After the backend.tf file is populated, reinitialize Terraform to use the newly configured state: `terraform init`
##### Configuring Remote State Deletion Protection
Now that remote state is configured, let's take steps to prevent accidental deletion.
- Remove Module State from Terraform Knowledge : `terraform state list` and then `terraform state rm module.remote-state`
- In the main.tf file, comment out the instance of the Terraform remote-state module. This step ensures that the module won't be processed in future Terraform operations

#### Setting Up Terraform Infrastructure Locally
- Navigate to the Terraform directory.
- Initialize the Terraform workspace: `terraform init` using remote backend generated above.
- Run a `terraform plan` to look through proposed changes
- Apply the infrastructure changes: `terraform apply`
- Destroy the infrastructure (if needed): `terraform destroy` & then manually delete the remote state bucket once terraform destroy is complete and successful.


### 2. Web Application (`Web-Application`)

The `Web-Application` directory contains the source code for the Node.js application.

```
Web-Application/
|-- k8s/
|-- index.js
|-- db.js
|-- ... (other application files)
```

#### Setting Up Locally
- Navigate to the Web-Application directory
- Install dependencies: npm install
- Setup the local .env file and put in the RDS credentials generated from Terraform and stored in AWS Secret Manager
- Start the application: npm start
- Access the application at http://localhost:3001 and access the respective endpoints


### 3. GitHub Actions Pipeline (`.github/workflows`) 

This project utilizes GitHub Actions to automate the CI/CD pipeline.

```
.github/workflows/
|-- .deploy-terraform.yaml
|-- .deploy-webapp.yaml
```

#### Pipeline Workflow
On Push (main branch), both pipelines are triggered, 
- The terraform workflow initializes, plans and applies the terraform infrastructure
- The webapp workflow, builds the docker image, pushes it to ECR and deploys the web application to Kubernetes.

#### Configuring Pipeline Secrets
For optimal functionality, specific secrets are necessary for each pipeline and are securely stored in the GitHub repository settings. Ensure the following secrets are configured:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
Note: These secrets below are populated after Terraform creates the required resources. They are crucial for the web application deployment, not the Terraform workflow.
- ECR_REGISTRY
- RDS_HOSTNAME
- RDS_USERNAME
- RDS_PASSWORD
- RDS_PORT

These secrets enable secure authentication and communication with various services, empowering the pipelines to execute seamlessly. Please take care to manage and update these secrets responsibly.


## Deployed Terraform Modules
1. Amazon EKS (Elastic Kubernetes Service): This provides a managed Kubernetes service for deploying, managing, and scaling containerized applications.
2. Amazon VPC (Virtual Private Cloud): This creates a logically isolated section of the AWS Cloud where you can launch AWS resources.
3. Amazon RDS (Relational Database Service): This manages the MySQL relational database that the Node App writes to.
4. Amazon ECR (Elastic Container Registry): This provides a fully managed Docker container registry for storing, managing, and deploying Docker container images within AWS.
5. Fluent Bit and Amazon CloudWatch for Logging: This collects logs from various sources and forwards them to Amazon CloudWatch for centralized logging and analysis.Details on this are in the Terraform/modules/fluentbit/ directory
6. Prometheus for Monitoring: This monitors and alerts on infrastructure and application performance metrics in a Kubernetes environment.

These carefully chosen modules cater to various aspects of the infrastructure, ensuring a well-rounded and scalable solution


## Proposed Enhancements
While the current solution provides a solid foundation, several improvements should be considered for a production-grade implementation. Key enhancements include:
- Implement GitOps Workflow: This streamlines the kubnernetes resource management, by integrating a GitOps tool like ArgoCD to automate and synchronize deployments for Kubernetes resources such as Prometheus and FluentBit etc
- Strengthen Security for RDS Module: Configure Deletion Protection for RDS instances, Implement more granular security controls and encryption measures for data at rest and in transit.
- Modularize User Authentication for EKS: Manage user authentication as a separate module, allowing for better scalability and maintainability of the EKS module, Also Configure RBAC policies to restrict access based on user roles and responsibilities.
- Implement Ingress with Reverse Proxy / Load Balancer: Implement a reverse proxy or load balancer to manage ingress, improving routing and load distribution.
- Tighten Security Group and VPC Access for RDS: Avoid making RDS public and configure security groups and VPC access rules to allow only necessary communication
- Security: Enhance security by implementing network policies, encryption at rest, and ensuring IAM roles have the principle of least privilege.
- Implement Image Scanning: Integrate an image scanning tool into the CI/CD pipeline to identify and mitigate vulnerabilities in container images.

These proposed enhancements collectively aim to bolster the security, scalability, and maintainability of the infrastructure when transitioning to a production environment.

## Testing the Deployed Web Application
The deployed web application exposes three endpoints for testing purposes:
- Status Endpoint (/status - GET): Use this endpoint to verify the operational status of the application.
Example: GET http://`<external-ip>`/status
- Data Endpoint (/data - POST): This endpoint accepts three parameters - username, email, and age.
It stores the provided data in the RDS database deployed using Terraform above and configured in the db.js file.
Example: POST http://`<external-ip>`/data with parameters passed in as query parameters.
- Users Endpoint (/users - GET): Retrieve all data from the connected database using this endpoint.
Example: GET http://`<external-ip>`/users

> Note: Since deployment was done using a Kubernetes service of type LoadBalancer, utilize the external IP assigned to the service.

> Testing can be conducted using Postman or any preferred testing tool

#### References
https://stackabuse.com/using-aws-rds-with-node-js-and-express-js/
https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-nodejs.rds.html

