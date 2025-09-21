#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Update
apt-get update -y
apt-get upgrade -y
# Download and install CloudWatch Agent (Ubuntu)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
dpkg -i /tmp/amazon-cloudwatch-agent.deb || true
apt-get -f install -y || true

# CloudWatch Agent config
cat <<'JSON' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"},
          {"name": "cpu_usage_system", "rename": "CPU_SYS", "unit": "Percent"},
          {"name": "cpu_usage_user", "rename": "CPU_USER", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      }
    }
  }
}
JSON

# Start agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s || true
