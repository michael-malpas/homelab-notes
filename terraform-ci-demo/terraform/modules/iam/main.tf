data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ec2_role" {

  name = "${var.environment}-ec2-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.environment}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

resource "aws_iam_role_policy_attachment" "cloudwatch" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name = "${var.environment}-ec2-profile"
  }
}
