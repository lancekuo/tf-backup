resource "aws_iam_role" "ebs_backup" {
    name               = "ServiceRoleForBackup"
    description        = "Allow Lambda backup and cleanup snapshot periodically"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_policy" "ebs_backup" {
    name        = "EbsBackupServiceRolePolicy"
    description = "Provide access to create and delete snapshot from any EC2 instance"
    policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": [
                "arn:aws:logs:${var.aws_region}:*:log-group:${var.awslog_base_path}/*:*:*",
                "arn:aws:logs:${var.aws_region}:*:log-group:${var.awslog_base_path}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:DeleteSnapshot",
                "ec2:Describe*",
                "ec2:ModifySnapshotAttribute",
                "ec2:ResetSnapshotAttribute",
                "sns:Publish"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "backup_role" {
    role       = "${aws_iam_role.ebs_backup.name}"
    policy_arn = "${aws_iam_policy.ebs_backup.arn}"
}
