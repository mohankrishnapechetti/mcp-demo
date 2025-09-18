import json
import boto3
import os
from datetime import datetime

def handler(event, context):
    """
    Push Lambda function that processes messages from push queue
    and handles notification delivery
    """
    
    # Initialize AWS clients
    dynamodb = boto3.resource('dynamodb')
    
    # Get environment variables
    notifications_table_name = os.environ.get('NOTIFICATIONS_TABLE')
    environment = os.environ.get('ENVIRONMENT', 'dev')
    
    try:
        # Process SQS records
        processed_count = 0
        failed_count = 0
        
        for record in event['Records']:
            try:
                # Parse message body
                message_body = json.loads(record['body'])
                notification_id = message_body['notification_id']
                notification_data = message_body['notification_data']
                
                print(f"Processing notification: {notification_id}")
                
                # Simulate notification delivery
                delivery_result = simulate_notification_delivery(notification_data)
                
                # Update notification status in DynamoDB
                table = dynamodb.Table(notifications_table_name)
                
                update_expression = "SET #status = :status, delivery_timestamp = :delivery_timestamp"
                expression_attribute_names = {'#status': 'status'}
                expression_attribute_values = {
                    ':status': delivery_result['status'],
                    ':delivery_timestamp': datetime.now().isoformat()
                }
                
                if delivery_result['status'] == 'failed':
                    update_expression += ", error_message = :error_message"
                    expression_attribute_values[':error_message'] = delivery_result.get('error', 'Unknown error')
                elif delivery_result['status'] == 'delivered':
                    update_expression += ", delivery_provider = :provider, delivery_id = :delivery_id"
                    expression_attribute_values[':provider'] = delivery_result.get('provider', 'email')
                    expression_attribute_values[':delivery_id'] = delivery_result.get('delivery_id', 'unknown')
                
                table.update_item(
                    Key={
                        'notification_id': notification_id,
                        'timestamp': notification_data['timestamp']
                    },
                    UpdateExpression=update_expression,
                    ExpressionAttributeNames=expression_attribute_names,
                    ExpressionAttributeValues=expression_attribute_values
                )
                
                processed_count += 1
                print(f"Successfully processed notification {notification_id}: {delivery_result['status']}")
                
            except Exception as e:
                print(f"Error processing record: {str(e)}")
                failed_count += 1
                
                # Update DynamoDB with failure status if notification_id is available
                if 'notification_id' in locals():
                    try:
                        table = dynamodb.Table(notifications_table_name)
                        table.update_item(
                            Key={
                                'notification_id': notification_id,
                                'timestamp': notification_data['timestamp']
                            },
                            UpdateExpression="SET #status = :status, error_message = :error_message, delivery_timestamp = :delivery_timestamp",
                            ExpressionAttributeNames={'#status': 'status'},
                            ExpressionAttributeValues={
                                ':status': 'failed',
                                ':error_message': str(e),
                                ':delivery_timestamp': datetime.now().isoformat()
                            }
                        )
                    except Exception as update_error:
                        print(f"Error updating DynamoDB with failure status: {str(update_error)}")
        
        # Return processing summary
        result = {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Batch processing completed',
                'processed_count': processed_count,
                'failed_count': failed_count,
                'total_records': len(event['Records'])
            })
        }
        
        print(f"Batch processing completed: {processed_count} processed, {failed_count} failed")
        return result
        
    except Exception as e:
        print(f"Error in push lambda handler: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }

def simulate_notification_delivery(notification_data):
    """
    Simulate notification delivery based on notification type
    """
    notification_type = notification_data.get('notification_type', 'info')
    recipient = notification_data.get('recipient', 'default@example.com')
    message = notification_data.get('message', 'Default message')
    
    try:
        # Simulate different delivery methods based on notification type
        if notification_type == 'email':
            # Simulate email delivery
            delivery_id = f"email_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            print(f"Simulating email delivery to {recipient}: {message}")
            return {
                'status': 'delivered',
                'provider': 'email',
                'delivery_id': delivery_id,
                'delivery_method': 'smtp'
            }
        
        elif notification_type == 'sms':
            # Simulate SMS delivery
            delivery_id = f"sms_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            print(f"Simulating SMS delivery to {recipient}: {message}")
            return {
                'status': 'delivered',
                'provider': 'sms',
                'delivery_id': delivery_id,
                'delivery_method': 'twilio'
            }
        
        elif notification_type == 'push':
            # Simulate push notification delivery
            delivery_id = f"push_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            print(f"Simulating push notification to {recipient}: {message}")
            return {
                'status': 'delivered',
                'provider': 'push',
                'delivery_id': delivery_id,
                'delivery_method': 'fcm'
            }
        
        else:
            # Default info notification
            delivery_id = f"info_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            print(f"Simulating info notification delivery to {recipient}: {message}")
            return {
                'status': 'delivered',
                'provider': 'internal',
                'delivery_id': delivery_id,
                'delivery_method': 'log'
            }
    
    except Exception as e:
        return {
            'status': 'failed',
            'error': str(e)
        }