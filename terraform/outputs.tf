output "alb_dns" { value = aws_lb.alb.dns_name }
output "asg_name" { value = aws_autoscaling_group.asg.name }
output "ami_id" { value = aws_ami_from_instance.from_instance.id }
output "vpc_id" { value = aws_vpc.this.id }
