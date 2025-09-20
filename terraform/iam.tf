# -----------------------------
# Managed Policies
# -----------------------------
data "aws_iam_policy" "cw_agent_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "ssm_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -----------------------------
# EC2 Assume Role Policy
# -----------------------------
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_policy" "passrole_policy" {
  name = "${var.project}-passrole-permission"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["iam:PassRole"]
      Resource = aws_iam_role.ec2_role.arn
    }]
  })
}
resource "aws_iam_policy_attachment" "passrole_attach" {
  name       = "${var.project}-passrole-attach"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.passrole_policy.arn
  }

# -----------------------------
# EC2 Role
# -----------------------------
resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name = "${var.project}-ec2-role"
  }
}

# -----------------------------
# Attach Managed Policies
# -----------------------------
resource "aws_iam_role_policy_attachment" "attach_cw" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.cw_agent_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.ssm_policy.arn
}

# -----------------------------
# S3 Read Access Policy for EC2
# -----------------------------
data "aws_iam_policy_document" "s3_read_access" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::cloudwatch-script-bkt/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy" "ec2_s3_read" {
  name   = "${var.project}-ec2-s3-read"
  role   = aws_iam_role.ec2_role.name
  policy = data.aws_iam_policy_document.s3_read_access.json
}

# -----------------------------
# Instance Profile
# -----------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-instance-profile"
  role = aws_iam_role.ec2_role.name
}
