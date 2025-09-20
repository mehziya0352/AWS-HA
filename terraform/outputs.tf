output "alb_dns" { value = aws_lb.alb.dns_name }
output "asg_name" { value = aws_autoscaling_group.asg.name }

data "aws_autoscaling_group" "asg_data" {
  name = aws_autoscaling_group.asg.name
}

output "asg_instance_ids" {
  value = data.aws_autoscaling_group.asg_data.instances[*].id
}

output "ami_id" { value = aws_ami_from_instance.from_instance.id }
output "vpc_id" { value = aws_vpc.this.id }
