variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-terraform-demo-bucket"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "my-demo-table"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "my-demo-function"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "my-demo-notifications"
}

variable "notification_email" {
  description = "Email address for SNS notifications (leave empty to skip email subscription)"
  type        = string
  default     = ""
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "my-demo-queue"
}


variable "api_gateway_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "dev"
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "create_key_pair" {
  description = "Whether to create a new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for EC2 key pair (required if create_key_pair is true)"
  type        = string
  default     = ""
}

variable "existing_key_name" {
  description = "Name of existing key pair to use (used if create_key_pair is false)"
  type        = string
  default     = ""
}