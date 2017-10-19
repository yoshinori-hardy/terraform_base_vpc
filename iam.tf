
## IAM

resource "aws_iam_role" "app_server_role" {
    name = "app_server_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "elb-attach" {
    role = "${aws_iam_role.app_server_role.name}"
    policy_arn = "${aws_iam_policy.elb_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "s3-attach" {
    role = "${aws_iam_role.app_server_role.name}"
    policy_arn = "${aws_iam_policy.s3_policy.arn}"
}

resource "aws_iam_instance_profile" "app_server_profile" {
    name = "app_server_profile"
    roles = ["${aws_iam_role.app_server_role.name}"]
}

resource "aws_iam_policy" "elb_policy" {
    name = "elb_policy"
    path = "/"
    description = "register/deregister fom alb"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:*"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "s3_policy" {
    name = "s3_policy"
    path = "/"
    description = "s3 permissions"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketACL",
                "s3:ListBucket",
                "s3:GetObjectACL",
                "s3:PutObjectACL",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
EOF
}
