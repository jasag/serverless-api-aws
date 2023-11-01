# serverless-api-aws

This is a serverless solution that leverages Amazon Web Services (AWS) to build a sample scalable and cost-effective API in order to get/create/delete products. It uses AWS API Gateway, AWS Lambda, and AWS DynamoDB to mange the API calls, execute the previously mentioned actions, and store the data.

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

![Lambda](images/dynamoDB.png)

## Steps to deploy the solution

1. Create Lambda function. Code is included under the "serverless-api" folder.
2. Create API Gateway. Please, see sample method configuration below.

![API Gateway](images/api-gateway-product-get-method.png)

3. Create DynamoDB table.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE) file for more details.