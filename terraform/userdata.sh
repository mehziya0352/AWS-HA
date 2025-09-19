user_data = base64encode(<<-EOT
  #!/bin/bash
  apt-get update -y
  apt-get install -y wget unzip curl

  # Download & install CloudWatch Agent
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
        },
        "netstat": {
          "measurement": [
            "tcp_established",
            "tcp_time_wait"
          ],
          "metrics_collection_interval": 60
        },
        "swap": {
          "measurement": [
            "swap_used_percent"
          ],
          "metrics_collection_interval": 60
        }
      }
    }
  }
  EOF

  # Start CloudWatch Agent
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
EOT
)
