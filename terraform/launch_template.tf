 resource "aws_launch_template" "app_lt" {
  name   = "${var.project}-lt"
  image_id      = aws_ami_from_instance.from_instance.id
  instance_type = "t2.micro"
  key_name      = var.key_name  
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data = base64encode(<<-EOT
    #!/bin/bash
    # Update and install required packages
    apt-get update -y
    apt-get install -y wget unzip curl

    # Download and install CloudWatch agent
    wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    dpkg -i amazon-cloudwatch-agent.deb

    # Create CloudWatch Agent config
    cat <<'EOF' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
    {
      "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
      },
      "metrics": {
        "append_dimensions": {
          "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
          "InstanceId": "$${aws:InstanceId}"
        },
        "metrics_collected": {
          "cpu": {
            "measurement": [
              "cpu_usage_idle",
              "cpu_usage_user",
              "cpu_usage_system"
            ],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          },
          "mem": {
            "measurement": [
              "mem_used_percent"
            ],
            "metrics_collection_interval": 60
          },
          "disk": {
            "measurement": [
              "disk_used_percent"
            ],
            "metrics_collection_interval": 60,
            "resources": ["/"]
          }
        }
      }
    }
    EOF

    # Start CloudWatch agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
  EOT
  )
}



  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_profile.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-instance"
    }
  }
}
