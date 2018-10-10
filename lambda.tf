data "archive_file" "createSnapshot_zip" {
    type        = "zip"
    source_file = "${path.module}/lambda-go/createSnapshot/main"
    output_path = "${path.module}/lambda-go/createSnapshot/main.zip"
}
data "archive_file" "deleteSnapshot_zip" {
    type        = "zip"
    source_file = "${path.module}/lambda-go/deleteSnapshot/main"
    output_path = "${path.module}/lambda-go/deleteSnapshot/main.zip"
}

resource "aws_lambda_function" "ebs-backup-create" {
    filename         = "${path.module}/lambda-go/createSnapshot/main.zip"
    function_name    = "createSnapshotEbs"
    role             = "${aws_iam_role.ebs_backup.arn}"
    handler          = "main"
    source_code_hash = "${data.archive_file.createSnapshot_zip.output_base64sha256}"
    runtime          = "go1.x"

    environment {
        variables = {
            Source  = "${terraform.workspace}"
            Project = "${var.project}"
        }
    }

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
resource "aws_lambda_function" "ebs-backup-delete" {
    filename         = "${path.module}/lambda-go/deleteSnapshot/main.zip"
    function_name    = "deleteSnapshotEbs"
    role             = "${aws_iam_role.ebs_backup.arn}"
    handler          = "main"
    source_code_hash = "${data.archive_file.deleteSnapshot_zip.output_base64sha256}"
    runtime          = "go1.x"

    environment {
        variables = {
            Source  = "${terraform.workspace}"
            Project = "${var.project}"
        }
    }

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
resource "aws_lambda_permission" "cloudwatch_to_CreateSnapshot" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.ebs-backup-create.function_name}"
    principal     = "events.amazonaws.com"
    source_arn    = "${aws_cloudwatch_event_rule.backup_every_day.arn}"
}
resource "aws_lambda_permission" "cloudwatch_to_DeleteSnapshot" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.ebs-backup-delete.function_name}"
    principal     = "events.amazonaws.com"
    source_arn    = "${aws_cloudwatch_event_rule.backup_every_day.arn}"
}

