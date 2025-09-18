import json
import boto3
import os
import uuid
from datetime import datetime

def handler(event, context):
    """
    Notification Lambda function that processes API Gateway requests
    and sends messages to push queue
    """
    
    # Initialize AWS clients
    sqs_client = boto3.client('sqs')
    dynamodb = boto3.resource('dynamodb')
    
    # Get environment variables
    push_queue_url = os.environ.get('PUSH_QUEUE_URL')
    notifications_table_name = os.environ.get('NOTIFICATIONS_TABLE')
    environment = os.environ.get('ENVIRONMENT', 'dev')
    
    try:
        # Parse request body
        if 'body' in event:
            if isinstance(event['body'], str):
                body = json.loads(event['body'])
            else:
                body = event['body']
        else:
            body = event
        
        # Generate notification ID and timestamp
        notification_id = str(uuid.uuid4())
        timestamp = datetime.now().isoformat()
        
        # Prepare notification data
        notification_data = {
            'notification_id': notification_id,
            'timestamp': timestamp,
            'message': body.get('message', 'Default notification message'),
            'recipient': body.get('recipient', 'default@example.com'),
            'notification_type': body.get('type', 'info'),
            'status': 'pending',
            'environment': environment,
            'source': 'api_gateway'
        }
        
        # Store notification in DynamoDB
        table = dynamodb.Table(notifications_table_name)
        table.put_item(Item=notification_data)
        
        # Send message to push queue
        queue_message = {
            'notification_id': notification_id,
            'action': 'send_notification',
            'notification_data': notification_data
        }
        
        sqs_response = sqs_client.send_message(
            QueueUrl=push_queue_url,
            MessageBody=json.dumps(queue_message),
            MessageAttributes={
                'notification_type': {
                    'StringValue': notification_data['notification_type'],
                    'DataType': 'String'
                },
                'recipient': {
                    'StringValue': notification_data['recipient'],
                    'DataType': 'String'
                }
            }
        )
        
        # Return success response
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Notification processed successfully',
                'notification_id': notification_id,
                'timestamp': timestamp,
                'queue_message_id': sqs_response['MessageId']
            })
        }
        
        return response
        
    except Exception as e:
        print(f"Error processing notification: {str(e)}")
        
        # Return error response
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }