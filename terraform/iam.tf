# -----------------------------
# Managed Policies (AWS provided)
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
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# -----------------------------
# EC2 Role
# -----------------------------
resource "aws_iam_role" "ec2_role" {
  name               = "${var.project}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.project}-ec2-role"
  }
}

# -----------------------------
# Custom S3 Read Access (inline policy)
# -----------------------------
resource "aws_iam_role_policy" "ec2_s3_read" {
  name = "${var.project}-ec2-s3-read"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::cloudwatch-script-bkt/*"
      }
    ]
  })
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
# Instance Profile
# -----------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-instance-profile"
  role = aws_iam_role.ec2_role.name
}
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
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# -----------------------------
# EC2 Role
# -----------------------------
resource "aws_iam_role" "ec2_role" {
  name               = "${var.project}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.project}-role"
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
# Custom S3 Read Access Policy
# -----------------------------
resource "aws_iam_policy" "s3_read" {
  name = "${var.project}-s3-read"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::cloudwatch-script-bkt/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read.arn
}

# -----------------------------
# Instance Profile
# -----------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-ip"   # keep short to avoid 255 char bug
  role = aws_iam_role.ec2_role.name
}
