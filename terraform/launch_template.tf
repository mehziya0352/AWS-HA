resource "aws_launch_template" "app_lt" {
  name   = "${var.project}-lt"
  image_id      = aws_ami_from_instance.from_instance.id
  instance_type = "t2.micro"
  key_name      = var.key_name  
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-instance"
    }
  }
}
