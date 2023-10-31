import json
import boto3
import logging
from custom_encoder import DecimalEncoder

print('Loading function')

# Create logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Define DynamoDB
dynamodb_table_name = "ProductInventory"
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(dynamodb_table_name)

# Define Methods
GET_METHOD = "GET"
POST_METHOD = "POST"
PATCH_METHOD = "PATCH"
DELETE_METHOD = "DELETE"

# Define PATHS
PRODUCT_PATH = "/product"


# Main function that handles the 
def lambda_handler(event, context):
    # Logging event
    logger.info(event)
    
    # Get method and path of the request
    http_method = event["httpMethod"]
    path = event["path"]
    
    # Process the request based on the type of request and its path
    if http_method == GET_METHOD and path == PRODUCT_PATH:
        response = get_product(event["queryStringParameters"]["productID"])
    elif http_method == POST_METHOD and path == PRODUCT_PATH:
        response = post_product(json.loads(event["body"]))
    elif http_method == DELETE_METHOD and path == PRODUCT_PATH:
        request_body = json.loads(event["body"])
        response = delete_product(request_body["productID"])    
    else:
        response = build_response(404, "Not Found")
    return response

# Function that builds the request's response
def build_response(status_code, body=None):
    # Response definition
    response = {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json"
        }
    }
    
    # Complete response accordingly
    if body is not None:
        response["body"] = json.dumps(body, cls=DecimalEncoder)
    
    return response
    

# Get product ID
def get_product(product_id):
    try:
        response = table.get_item(
            Key={
                "ProductID": product_id
            }
        )
        if "Item" in response:
            return build_response(200, response["Item"])
        else:
            return build_response(404, f"Message: Product ID: {product_id} not found")
    except Exception as e:
        logger.exception(f"Error getting product details: {str(e)}")
    
# Create a product   
def post_product(product_item):
    try:
        # Use the 'put_item' method to add the new product to the table
        table.put_item(Item=product_item)
        
        # Generate response
        response_body = {
            "Method": "POST",
            "Message": "SUCCESS",
            "Item": product_item
        }
        
        return build_response(200, response_body)
    except Exception as e:
       logger.exception(f"Error creating product: {str(e)}")

# Delete a product 
def delete_product(product_id):

    try:
        # Use the 'delete_item' method to delete the product based on its product ID
        response = table.delete_item(
            Key={
                "ProductID": product_id
            }
        )
        
        # Generate response
        response_body = {
            "Method": "DELETE",
            "Message": "SUCCESS",
            "ProductID": product_id
        }

        return build_response(200, response_body)
    except Exception as e:
        logger.exception(f"Error deleting product: {str(e)}")
