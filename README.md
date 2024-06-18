# Serverless API AWS Sample

This is a serverless solution that leverages Amazon Web Services (AWS) to build a sample scalable and cost-effective API in order to get/create/delete products. It uses AWS **API Gateway, AWS Lambda, and AWS DynamoDB** to manage the API calls, execute the previously mentioned actions, and store the data. **This solution can be deployed manually, using Terraform or CDK**. See each of the sections for more details.

## Table of Contents

- [Diagram](#diagram)
- [Components](#components)
- [Prerequisites](#prerequisites)
- [Deployment](#deployment)
   - [Deployment using Terraform](#Deployment-using-Terraform)
   - [Deployment using CDK](#Deployment-using-CDK)
   - [Deployment manually](#Deployment-manually)
- [Testing the API](#testing-the-api)
- [License](#license)

## Diagram

![Serverless Architecture Diagram](images/serverless-api-aws-diagram.png)

## Components

### AWS API Gateway

The API Gateway serves as the entry point to the serverless API. As per mentioned above, this is a sample API and authorization/authentication are currently not used for simplication purposes.

![API Gateway](images/api-gateway.png)

### AWS Lambda

Lambda functions are the core of your serverless application. They execute the logic in response to the API Gateway requests. In this solution, the lambda function handle create, get and delete operations.

![Lambda](images/lambda.png)

### AWS DynamoDB

DynamoDB is a fully managed NoSQL database service by AWS. It is used to store and retrieve data related to your serverless application. In this solution, DynamoDB is used to store the products data.

![DynamoDB](images/dynamoDB.png)

## Prerequisites

Before you begin, if you would like to use this repository, ensure you have the following prerequisites in place:

- **AWS Account**: You must have an AWS account. If you don't have one, you can create one [here](https://aws.amazon.com/).
- **AWS CLI**: Install and configure the AWS Command Line Interface (CLI) with your AWS access and secret keys. You can install the AWS CLI by following the instructions [here](https://aws.amazon.com/cli/).
- **(Optional) Terraform**: If you would like to use Terraform to deploy this solution, make sure you have Terraform installed on your local machine. You can download it from [here](https://www.terraform.io/downloads.html).
- **(Optional) CDK**: If you would like to use CDK to deploy this solution, make sure you have Node.js and CDK installed locally, see below more details. You can also refer to the [Getting started with the AWS CDK
](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html#getting_started_background) AWS Documentation on this for a more detailed overview.
   - **Intalled Node.js**: You can see more details steps [here](https://cdkworkshop.com/15-prerequisites/300-nodejs.html).
   - **Intalled CDK**: You can see more details steps [here](https://cdkworkshop.com/15-prerequisites/500-toolkit.html).
- **Git**: If you want to clone this repository, you need Git installed. You can download it from [here](https://git-scm.com/downloads).

Finally, note that the Terraform template is by default configured to deploy the resources in the ```eu-west-1``` region, you can easily change this on the second line of the ```main.tf``` file to your preferred AWS region.

## Deployment

### Deployment using Terraform

To deploy this serverless solution using Terraform, follow the steps below:

1. **Clone the Repository**: Clone this repository to your local environment:

   ```bash
   git clone https://github.com/jasag/serverless-api-aws.git
   ```

2. **Move into the repository folder.**

   ```bash
   cd serverless-api-aws
   ```

3. **Initialize Terraform**: Run the following command to initialize Terraform in your project directory:

   ```bash
   terraform init
   ```

4. **Plan and Apply**: Run the following commands to plan and apply the configuration using Terraform.

   ```bash
   terraform plan
   terraform apply
   ```

5. **Destroy Resources**: Optionally, run the following command to remove all the resources deployed by this Terraform configuration.

   ```bash
   terraform destroy
   ```

### Deployment using CDK

To deploy this serverless solution using AWS CDK, follow the steps below. Kindly note that the DynamoDB table has been created with the ```RemovalPolicy.DESTROY```, this will result in the deletion of the DynamoDB table. Kindly remove this property prior creation if you would like to keep the table and its data when you delete the stack.

1. **Clone the Repository**: Clone this repository to your local environment:

   ```bash
   git clone https://github.com/jasag/serverless-api-aws.git
   ```

2. **Move into the repository folder.**

   ```bash
   cd serverless-api-aws/cdk
   ```

3. **Activate the app's Python virtual environment and install the AWS CDK core dependencies**

   ```bash
   source .venv/bin/activate
   python3 -m pip install -r requirements.txt
   ```

4. **Bootstrap the environment**: Run the below command to bootstrap the environment. See more details about this step [here](https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html).

   ```bash
   cdk bootstrap
   ```

5. **Deploy the CDK Stack**: Run the below command to deploy the solution.

   ```bash
   cdk deploy
   ```

6. **Destroy the CDK Stack**: Run the below command to deploy the solution.

   ```bash
   cdk destroy
   ```

### Deployment manually

Alternatively, you can choose to deploy this manually to familiarize further with the services/steps required.

1. Create Lambda function. Code is included under the "serverless-api" folder. Kindly see the screenshots previously provided for mode details.

2. Create API Gateway. Please, see sample method configuration below.

![API Gateway](images/api-gateway-product-get-method.png)

3. Create DynamoDB table.

## Testing the API

### Testing - Get Product

![Get Product](images/postman-product-get-test.png)

### Testing - Post Product

![Post Product](images/postman-product-post-test.png)

### Testing - Delete Product

![Delete Product](images/postman-product-delete-test.png)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for more details.

### Infrastructure model
![jasag_serverless-api-aws](https://github.com/jasag/serverless-api-aws/assets/173192552/8afc884b-066a-435a-b41e-3d1140ee3ec9)
