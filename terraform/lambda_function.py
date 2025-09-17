import json
import boto3
import os
from datetime import datetime

def handler(event, context):
    """
    Simple Lambda function that demonstrates interaction with S3, DynamoDB, and SNS
    """
    
    # Initialize AWS clients
    s3_client = boto3.client('s3')
    dynamodb = boto3.resource('dynamodb')
    sns_client = boto3.client('sns')
    
    # Get environment variables
    bucket_name = os.environ.get('BUCKET_NAME')
    table_name = os.environ.get('TABLE_NAME')
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    
    try:
        # Get DynamoDB table
        table = dynamodb.Table(table_name)
        
        # Create a sample record
        timestamp = datetime.now().isoformat()
        record_id = f"demo-{int(datetime.now().timestamp())}"
        
        # Put item in DynamoDB
        table.put_item(
            Item={
                'id': record_id,
                'timestamp': timestamp,
                'message': 'Hello from Lambda!',
                'event_data': json.dumps(event)
            }
        )
        
        # Create a sample file in S3
        file_content = {
            'timestamp': timestamp,
            'record_id': record_id,
            'message': 'Lambda execution successful'
        }
        
        s3_client.put_object(
            Bucket=bucket_name,
            Key=f'lambda-logs/{record_id}.json',
            Body=json.dumps(file_content),
            ContentType='application/json'
        )
        
        # Send SNS notification
        message = {
            'default': f'Lambda execution successful at {timestamp}',
            'record_id': record_id,
            'timestamp': timestamp,
            's3_key': f'lambda-logs/{record_id}.json'
        }
        
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(message),
            Subject='Lambda Function Execution Notification'
        )
        
        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Successfully processed request',
                'record_id': record_id,
                'timestamp': timestamp
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }