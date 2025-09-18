output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main_bucket.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main_table.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main_function.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main_function.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.main_function.invoke_arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.main_topic.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.main_topic.arn
}

output "sqs_queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.main_queue.name
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.main_queue.arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.main_queue.url
}

output "sqs_dead_letter_queue_arn" {
  description = "ARN of the SQS dead letter queue"
  value       = aws_sqs_queue.dead_letter_queue.arn
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main_instance.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main_instance.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.main_instance.public_dns
}

output "website_url" {
  description = "URL to access the website on EC2"
  value       = "http://${aws_instance.main_instance.public_dns}"
}

# Backend Services Outputs
output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "https://${aws_api_gateway_rest_api.notification_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.api_gateway_stage_name}"
}

output "notification_lambda_arn" {
  description = "ARN of the notification Lambda function"
  value       = aws_lambda_function.notification_lambda.arn
}

output "push_lambda_arn" {
  description = "ARN of the push Lambda function"
  value       = aws_lambda_function.push_lambda.arn
}

output "push_queue_url" {
  description = "URL of the push SQS queue"
  value       = aws_sqs_queue.push_queue.url
}

output "notifications_table_name" {
  description = "Name of the notifications DynamoDB table"
  value       = aws_dynamodb_table.notifications_table.name
}

output "api_gateway_endpoint" {
  description = "API Gateway notification endpoint"
  value       = "https://${aws_api_gateway_rest_api.notification_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.api_gateway_stage_name}/notification"
}

# CloudWatch Alarms Outputs
output "alarm_topic_arn" {
  description = "ARN of the alarm SNS topic"
  value       = aws_sns_topic.alarm_topic.arn
}

output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.environment}-infrastructure-dashboard"
}