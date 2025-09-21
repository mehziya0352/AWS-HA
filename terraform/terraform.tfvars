# AWS settings
aws_region = "us-east-1"

# Project metadata (used for tagging)
project = "app"


# Existing instance (to create AMI from)
source_instance_id = "i-04281b2b0c7157b46"

# Networking
vpc_cidr             = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.101.0/24", "10.10.102.0/24"]

# If you want to pin specific AZs, override here
availability_zones = ["us-east-1a", "us-east-1b"]

# EC2 instance settings
instance_type = "t2.micro"

# Auto Scaling Group
min_size         = 1
desired_capacity = 2
max_size         = 5

# Monitoring / Notifications
alert_email  = "mehziya0352@gmail.com" # leave empty "" if not using SNS
acm_cert_arn = "" # optional, only if you want HTTPS on ALB
