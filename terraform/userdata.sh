#!/bin/bash
apt-get update -y
apt-get install -y wget unzip curl

# Download & install CloudWatch Agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Download CloudWatch config from S3
aws s3 cp s3://my-json-bkt123/cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/config.json

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/config.json -s
