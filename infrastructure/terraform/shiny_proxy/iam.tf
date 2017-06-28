
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
resource "aws_iam_role_policy" "ecr_access" {
  name = "shiny-proxy-policy"
  role = "${aws_iam_role.shiny-proxy-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   {
      "Effect":"Allow",
     "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage"
        ],
      "Resource":["*"]

  ]
}

EOF
}