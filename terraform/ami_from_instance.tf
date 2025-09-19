resource "aws_ami_from_instance" "from_instance" {
  name               = "${var.project}-ami-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  source_instance_id = var.source_instance_id
  snapshot_without_reboot = true

  tags = {
    Name = "${var.project}-ami"
  }
}
