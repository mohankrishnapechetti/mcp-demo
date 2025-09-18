#!/bin/bash
yum update -y
yum install -y httpd aws-cli

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple HTML page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Demo EC2 Instance</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 600px; margin: 0 auto; }
        .info { background: #f4f4f4; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Demo EC2 Instance</h1>
        <div class="info">
            <h3>Instance Information</h3>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
            <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Instance Type:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-type)</p>
            <p><strong>S3 Bucket:</strong> ${bucket_name}</p>
        </div>
        <h3>Services Available</h3>
        <ul>
            <li>S3 Bucket: ${bucket_name}</li>
            <li>Lambda Function</li>
            <li>DynamoDB Table</li>
            <li>SNS Topic</li>
            <li>SQS Queue</li>
            <li>CloudWatch Logs</li>
        </ul>
    </div>
</body>
</html>
EOF

# Set proper permissions
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html