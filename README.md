## Lambda + System Manager Parameter Store

Create a Lambda function zipped and stored in S3 to [System Manager Paramter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html). It includes management of IAM roles to interact with parameters (encrypted and non-encrypted values).

Quick demo few AWS services and concepts: 

- [AWS IAM](https://aws.amazon.com/iam/)
- [AWS System Manager Paramter Store](https://docs.aws.amazon.com/systems-manager)
- [AWS KMS](https://aws.amazon.com/kms/)
- [AWS lambda](https://aws.amazon.com/lambda/)
- Lambda CW logs setup 
- Lambda S3 store 
- Terraform

### Sections

1. [Quick Start](#quick-start)  
2. [Lambda Versioning](#lambda-versioning)  

### Quick Start

1. Setup the environment   
```sh

// setup-env.sh 
export AWS_ACCESS_KEY_ID="<secret>"
export AWS_SECRET_ACCESS_KEY="<secret>"
export AWS_DEFAULT_REGION=us-east-1
export TF_VAR_database_password="<secret>"
export TF_VAR_aws_account_id="<secret>"
. ./setup-env.sh
```

2. Create Infrastructure  

```sh
terraform init
terraform plan
terraform apply -auto-approve 
```

3. Visit Console and trigger lambda   


### Lambda Versioning (TODO)

Created custom versioning of lambda code changes via node.js scripts. The gist of it is when versioning is done through the npm (patch, minor, major) the terraform configuration will pick up changes and push changes based on the version in the `package.json`. 


**Publishing:**
```sh
// Patch
yarn run version:patch

// Minor 
yarn run version:minor

// Major 
yarn run version:major
```

**Deploying:**

```
terraform plan
terraform apply -auto-approve 
```
