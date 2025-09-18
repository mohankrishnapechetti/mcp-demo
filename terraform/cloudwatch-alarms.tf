# SNS Topic for Alarm Notifications
resource "aws_sns_topic" "alarm_topic" {
  name = "${var.environment}-alarm-notifications"

  tags = {
    Name        = "${var.environment}-alarm-notifications"
    Environment = var.environment
  }
}

# SNS Topic Subscription for Alarm Notifications
resource "aws_sns_topic_subscription" "alarm_email_notification" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# Lambda Function Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
  alarm_name          = "${var.environment}-lambda-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors lambda error rate"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    FunctionName = aws_lambda_function.main_function.function_name
  }

  tags = {
    Name        = "${var.environment}-lambda-error-rate"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.environment}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000"
  alarm_description   = "This metric monitors lambda execution duration"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    FunctionName = aws_lambda_function.main_function.function_name
  }

  tags = {
    Name        = "${var.environment}-lambda-duration"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "notification_lambda_error_rate" {
  alarm_name          = "${var.environment}-notification-lambda-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "3"
  alarm_description   = "This metric monitors notification lambda error rate"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    FunctionName = aws_lambda_function.notification_lambda.function_name
  }

  tags = {
    Name        = "${var.environment}-notification-lambda-error-rate"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "push_lambda_error_rate" {
  alarm_name          = "${var.environment}-push-lambda-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "3"
  alarm_description   = "This metric monitors push lambda error rate"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    FunctionName = aws_lambda_function.push_lambda.function_name
  }

  tags = {
    Name        = "${var.environment}-push-lambda-error-rate"
    Environment = var.environment
  }
}

# SQS Queue Alarms
resource "aws_cloudwatch_metric_alarm" "sqs_dead_letter_queue_messages" {
  alarm_name          = "${var.environment}-sqs-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessages"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "This metric monitors messages in dead letter queue"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    QueueName = aws_sqs_queue.dead_letter_queue.name
  }

  tags = {
    Name        = "${var.environment}-sqs-dlq-messages"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "push_queue_dead_letter_messages" {
  alarm_name          = "${var.environment}-push-queue-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessages"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "This metric monitors messages in push queue dead letter queue"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    QueueName = aws_sqs_queue.push_queue_dlq.name
  }

  tags = {
    Name        = "${var.environment}-push-queue-dlq-messages"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_message_age" {
  alarm_name          = "${var.environment}-sqs-message-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1800"
  alarm_description   = "This metric monitors age of oldest message in SQS queue"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    QueueName = aws_sqs_queue.main_queue.name
  }

  tags = {
    Name        = "${var.environment}-sqs-message-age"
    Environment = var.environment
  }
}

# DynamoDB Table Alarms
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttled_requests" {
  alarm_name          = "${var.environment}-dynamodb-throttled-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB throttled requests"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    TableName = aws_dynamodb_table.main_table.name
  }

  tags = {
    Name        = "${var.environment}-dynamodb-throttled-requests"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "notifications_table_throttled_requests" {
  alarm_name          = "${var.environment}-notifications-table-throttled-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors notifications table throttled requests"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    TableName = aws_dynamodb_table.notifications_table.name
  }

  tags = {
    Name        = "${var.environment}-notifications-table-throttled-requests"
    Environment = var.environment
  }
}

# API Gateway Alarms
resource "aws_cloudwatch_metric_alarm" "api_gateway_4xx_errors" {
  alarm_name          = "${var.environment}-api-gateway-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors API Gateway 4XX errors"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    ApiName = aws_api_gateway_rest_api.notification_api.name
  }

  tags = {
    Name        = "${var.environment}-api-gateway-4xx-errors"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  alarm_name          = "${var.environment}-api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors API Gateway 5XX errors"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    ApiName = aws_api_gateway_rest_api.notification_api.name
  }

  tags = {
    Name        = "${var.environment}-api-gateway-5xx-errors"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_latency" {
  alarm_name          = "${var.environment}-api-gateway-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Average"
  threshold           = "5000"
  alarm_description   = "This metric monitors API Gateway latency"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    ApiName = aws_api_gateway_rest_api.notification_api.name
  }

  tags = {
    Name        = "${var.environment}-api-gateway-latency"
    Environment = var.environment
  }
}

# EC2 Instance Alarms
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_utilization" {
  alarm_name          = "${var.environment}-ec2-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    InstanceId = aws_instance.main_instance.id
  }

  tags = {
    Name        = "${var.environment}-ec2-cpu-utilization"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name          = "${var.environment}-ec2-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors EC2 status check"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    InstanceId = aws_instance.main_instance.id
  }

  tags = {
    Name        = "${var.environment}-ec2-status-check"
    Environment = var.environment
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main_dashboard" {
  dashboard_name = "${var.environment}-infrastructure-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.main_function.function_name],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessages", "QueueName", aws_sqs_queue.main_queue.name],
            [".", "ApproximateNumberOfMessages", "QueueName", aws_sqs_queue.push_queue.name],
            [".", "ApproximateNumberOfMessages", "QueueName", aws_sqs_queue.dead_letter_queue.name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "SQS Queue Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", aws_api_gateway_rest_api.notification_api.name],
            [".", "4XXError", ".", "."],
            [".", "5XXError", ".", "."],
            [".", "Latency", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "API Gateway Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.main_instance.id],
            [".", "StatusCheckFailed", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 Metrics"
          period  = 300
        }
      }
    ]
  })
}