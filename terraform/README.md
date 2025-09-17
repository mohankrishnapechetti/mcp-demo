# Terraform AWS Demo

This Terraform configuration creates a simple AWS infrastructure with:
- S3 bucket with versioning and encryption
- DynamoDB table with pay-per-request billing
- Lambda function with proper IAM permissions

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed (>= 1.0)

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Create the Lambda deployment package:
```bash
zip lambda_function.zip lambda_function.py
```

3. Plan the deployment:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. Clean up resources:
```bash
terraform destroy
```

## Configuration

You can customize the deployment by modifying variables in `variables.tf` or creating a `terraform.tfvars` file:

```hcl
aws_region = "us-west-2"
environment = "prod"
bucket_name = "my-custom-bucket-name"
dynamodb_table_name = "my-custom-table"
lambda_function_name = "my-custom-function"
```

## Resources Created

- **S3 Bucket**: Stores files with versioning and server-side encryption
- **DynamoDB Table**: NoSQL database with on-demand billing
- **Lambda Function**: Serverless function that can interact with S3 and DynamoDB
- **IAM Role & Policy**: Proper permissions for Lambda to access S3 and DynamoDB

## Lambda Function

The included Lambda function demonstrates:
- Writing records to DynamoDB
- Uploading files to S3
- Error handling
- Environment variable usage