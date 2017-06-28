
resource "aws_iam_instance_profile" "shiny_profile" {
  name = "shiny-profile"
  role = "${aws_iam_role.shiny-proxy-role.name}"
}

resource "aws_iam_role" "shiny-proxy-role" {
  name = "shiny_proxy_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
       "Service": "ec2.amazonaws.com"
       },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role = "${aws_iam_role.shiny-proxy-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
