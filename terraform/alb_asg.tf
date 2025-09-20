# -----------------------------
# ALB
# -----------------------------
resource "aws_lb" "alb" {
  name               = substr("${var.project}-alb", 0, 32)
  internal           = false
  load_balancer_type = "application"
  subnets            = [for s in aws_subnet.public : s.id]
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = substr("${var.project}-alb", 0, 32)
  }
}

# -----------------------------
# Target Group
# -----------------------------
resource "aws_lb_target_group" "tg" {
  name        = substr("${var.project}-tg", 0, 32)
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = substr("${var.project}-tg", 0, 32)
  }
}

# -----------------------------
# Listener HTTP
# -----------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# -----------------------------
# Listener HTTPS (Optional)
# -----------------------------
resource "aws_lb_listener" "https" {
  count             = var.acm_cert_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# -----------------------------
# Auto Scaling Group
# -----------------------------
resource "aws_autoscaling_group" "asg" {
  name                       = substr("${var.project}-asg", 0, 255)
  desired_capacity           = var.desired_capacity
  min_size                   = var.min_size
  max_size                   = var.max_size
  vpc_zone_identifier        = [for s in aws_subnet.private : s.id]
  health_check_type          = "ELB"
  health_check_grace_period  = 180

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = aws_launch_template.app_lt.latest_version
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project}-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------
# Target Tracking Policy
# -----------------------------
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = substr("${var.project}-target", 0, 255)
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
