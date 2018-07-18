resource "aws_lambda_function" "ebs-backup-create" {
    filename         = "${path.module}/lambda/createSnapshot/createSnapshot.zip"
    function_name    = "createSnapshot"
    role             = "${aws_iam_role.lambda-ebs-backup.arn}"
    handler          = "createSnapshot.lambda_handler"
    source_code_hash = "${base64sha256(file("${path.module}/lambda/createSnapshot/createSnapshot.zip"))}"
    runtime          = "python2.7"

    environment {
        variables = {
            Source  = "Terraform"
            Project = "${var.project}"
        }
    }

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
resource "aws_lambda_function" "ebs-backup-delete" {
    filename         = "${path.module}/lambda/deleteSnapshot/deleteSnapshot.zip"
    function_name    = "deleteSnapshot"
    role             = "${aws_iam_role.lambda-ebs-backup.arn}"
    handler          = "deleteSnapshot.lambda_handler"
    source_code_hash = "${base64sha256(file("${path.module}/lambda/deleteSnapshot/deleteSnapshot.zip"))}"
    runtime          = "python2.7"

    environment {
        variables = {
            Source = "Terraform"
        }
    }

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
