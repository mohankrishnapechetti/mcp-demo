# API Gateway REST API
resource "aws_api_gateway_rest_api" "notification_api" {
  name        = "${var.environment}-notification-api"
  description = "API Gateway for notification service"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.environment}-notification-api"
    Environment = var.environment
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "notification_resource" {
  rest_api_id = aws_api_gateway_rest_api.notification_api.id
  parent_id   = aws_api_gateway_rest_api.notification_api.root_resource_id
  path_part   = "notification"
}

# API Gateway Method
resource "aws_api_gateway_method" "notification_post" {
  rest_api_id   = aws_api_gateway_rest_api.notification_api.id
  resource_id   = aws_api_gateway_resource.notification_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "notification_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.notification_api.id
  resource_id = aws_api_gateway_resource.notification_resource.id
  http_method = aws_api_gateway_method.notification_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notification_lambda.invoke_arn
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "notification_api_deployment" {
  depends_on = [
    aws_api_gateway_method.notification_post,
    aws_api_gateway_integration.notification_lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.notification_api.id

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "notification_api_stage" {
  deployment_id = aws_api_gateway_deployment.notification_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.notification_api.id
  stage_name    = var.api_gateway_stage_name

  tags = {
    Name        = "${var.environment}-api-stage"
    Environment = var.environment
  }
}

# Push Queue (SQS)
resource "aws_sqs_queue" "push_queue" {
  name                      = "${var.environment}-push-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.push_queue_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${var.environment}-push-queue"
    Environment = var.environment
  }
}

# Push Queue Dead Letter Queue
resource "aws_sqs_queue" "push_queue_dlq" {
  name = "${var.environment}-push-queue-dlq"

  tags = {
    Name        = "${var.environment}-push-queue-dlq"
    Environment = var.environment
  }
}

# DynamoDB Table for Notifications
resource "aws_dynamodb_table" "notifications_table" {
  name           = "${var.environment}-notifications"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "notification_id"
  range_key      = "timestamp"

  attribute {
    name = "notification_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name     = "StatusIndex"
    hash_key = "status"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.environment}-notifications"
    Environment = var.environment
  }
}

# CloudWatch Log Group for Notification Lambda
resource "aws_cloudwatch_log_group" "notification_lambda_logs" {
  name              = "/aws/lambda/${var.environment}-notification-lambda"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.environment}-notification-lambda-logs"
    Environment = var.environment
  }
}

# CloudWatch Log Group for Push Lambda
resource "aws_cloudwatch_log_group" "push_lambda_logs" {
  name              = "/aws/lambda/${var.environment}-push-lambda"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.environment}-push-lambda-logs"
    Environment = var.environment
  }
}

# IAM Role for Notification Lambda
resource "aws_iam_role" "notification_lambda_role" {
  name = "${var.environment}-notification-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Notification Lambda
resource "aws_iam_role_policy" "notification_lambda_policy" {
  name = "${var.environment}-notification-lambda-policy"
  role = aws_iam_role.notification_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.notification_lambda_logs.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.push_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.notifications_table.arn,
          "${aws_dynamodb_table.notifications_table.arn}/*"
        ]
      }
    ]
  })
}

# IAM Role for Push Lambda
resource "aws_iam_role" "push_lambda_role" {
  name = "${var.environment}-push-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Push Lambda
resource "aws_iam_role_policy" "push_lambda_policy" {
  name = "${var.environment}-push-lambda-policy"
  role = aws_iam_role.push_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.push_lambda_logs.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.push_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.notifications_table.arn,
          "${aws_dynamodb_table.notifications_table.arn}/*"
        ]
      }
    ]
  })
}

# Notification Lambda Function
resource "aws_lambda_function" "notification_lambda" {
  filename         = "notification_lambda.zip"
  function_name    = "${var.environment}-notification-lambda"
  role            = aws_iam_role.notification_lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      PUSH_QUEUE_URL = aws_sqs_queue.push_queue.url
      NOTIFICATIONS_TABLE = aws_dynamodb_table.notifications_table.name
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name        = "${var.environment}-notification-lambda"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy.notification_lambda_policy,
    aws_cloudwatch_log_group.notification_lambda_logs,
  ]
}

# Push Lambda Function
resource "aws_lambda_function" "push_lambda" {
  filename         = "push_lambda.zip"
  function_name    = "${var.environment}-push-lambda"
  role            = aws_iam_role.push_lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      NOTIFICATIONS_TABLE = aws_dynamodb_table.notifications_table.name
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name        = "${var.environment}-push-lambda"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy.push_lambda_policy,
    aws_cloudwatch_log_group.push_lambda_logs,
  ]
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_notification_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.notification_api.execution_arn}/*/*"
}

# SQS Event Source Mapping for Push Lambda
resource "aws_lambda_event_source_mapping" "sqs_push_lambda_trigger" {
  event_source_arn = aws_sqs_queue.push_queue.arn
  function_name    = aws_lambda_function.push_lambda.arn
  batch_size       = 10
  enabled          = true
}