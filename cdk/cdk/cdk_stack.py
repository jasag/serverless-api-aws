import aws_cdk as cdk
from aws_cdk import Stack
from aws_cdk import aws_dynamodb as dynamodb
from aws_cdk import aws_lambda as lambda_
from aws_cdk import aws_iam as iam
from aws_cdk import aws_apigateway as apigateway
from constructs import Construct

class CdkStack(Stack):

    def __init__(self, scope: cdk.App, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # DynamoDB table
        # https://docs.aws.amazon.com/cdk/api/v2/python/aws_cdk.aws_dynamodb/Table.html
        product_inventory_table = dynamodb.Table(
            self, "ProductInventory",
            table_name="ProductInventory",
            billing_mode=dynamodb.BillingMode.PROVISIONED,
            read_capacity=1,
            write_capacity=1,
            partition_key=dynamodb.Attribute(
                name="ProductID",
                type=dynamodb.AttributeType.STRING
            ),
            removal_policy=  cdk.RemovalPolicy.DESTROY
        )

        # Lambda execution role
        lambda_execution_role = iam.Role(
            self, "LambdaExecutionRole",
            assumed_by=iam.ServicePrincipal("lambda.amazonaws.com")
        )

        # Attach policies to the Lambda execution role
        lambda_execution_role.add_to_policy(
            statement=iam.PolicyStatement(
                actions=["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:UpdateItem", "dynamodb:DeleteItem"],
                resources=[product_inventory_table.table_arn]
            )
        )

        lambda_execution_role.add_managed_policy(iam.ManagedPolicy.from_aws_managed_policy_name("AmazonDynamoDBFullAccess"))
        lambda_execution_role.add_managed_policy(iam.ManagedPolicy.from_aws_managed_policy_name("CloudWatchFullAccessV2"))

        # Lambda function
        lambda_function = lambda_.Function(
            self, "LambdaFunction",
            function_name="serverless-api",
            runtime=lambda_.Runtime.PYTHON_3_10,
            handler="lambda_function.lambda_handler",
            code=lambda_.Code.from_asset("../serverless-api"),
            role=lambda_execution_role
        )

        # API Gateway
        # https://docs.aws.amazon.com/cdk/api/v2/python/aws_cdk.aws_apigateway/LambdaRestApi.html
        api = apigateway.LambdaRestApi(
            self, "ServerlessApi",
            handler=lambda_function,
            rest_api_name="serverless-api",
            description="Serverless API",
            deploy = False,
            default_method_options = None,
            endpoint_types = [apigateway.EndpointType.REGIONAL]
        )

        # API Gateway resource
        resource = api.root.add_resource("product")

        # API Gateway methods
        # https://docs.aws.amazon.com/cdk/api/v2/python/aws_cdk.aws_apigateway/LambdaIntegration.html
        post_method = resource.add_method("POST")
        get_method = resource.add_method("GET")
        delete_method = resource.add_method("DELETE")

        # Deploy API Gateway
        deployment = apigateway.Deployment(
            self, "APIDeployment",
            api=api
        )

        deployment.node.add_dependency(post_method)
        deployment.node.add_dependency(get_method)
        deployment.node.add_dependency(delete_method)

        # Create API Gateway stage
        stage = apigateway.Stage(
            self, "APIStage",
            deployment=deployment,
            stage_name="Development"
        )

        # Grant API Gateway permissions to invoke the Lambda function
        lambda_function.add_permission(
            "APIGatewayPermission",
            principal=iam.ServicePrincipal("apigateway.amazonaws.com")
        )