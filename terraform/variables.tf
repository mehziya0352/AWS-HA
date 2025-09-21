variable "aws_region" { 
  type = string
  default = "us-east-1" 
}
variable "project" {
  type = string
  default = "app" 
}



# Existing instance to create AMI from
variable "source_instance_id" { 
  type = string 
}

# AZs (optional override)
variable "availability_zones" { 
  type = list(string)
  default = []
}

# Subnet CIDRs
variable "vpc_cidr" { 
  type = string
  default = "10.10.0.0/16"
}
variable "public_subnet_cidrs" { 
  type = list(string)
  default = ["10.10.1.0/24","10.10.2.0/24"] 
}
variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.10.101.0/24","10.10.102.0/24"] 
}

variable "instance_type" { 
  type = string
  default = "t2.micro" 
}
variable "key_name" { 
  type = string
  default = ""
}

variable "min_size" { 
  type = number
  default = 1
}
variable "desired_capacity" { 
  type = number
  default = 1
}
variable "max_size" { 
  type = number
  default = 5
}

variable "alert_email" { 
  type = string
  default = ""
} # optional SNS email

variable "acm_cert_arn" {
  type = string
  default = "" 
} # optional for HTTPS
