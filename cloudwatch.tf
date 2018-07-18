resource "aws_cloudwatch_event_rule" "every_day" {
    name                = "every-day"
    description         = "Fires every day"
    schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "snapshot_every_day" {
    rule      = "${aws_cloudwatch_event_rule.every_day.name}"
    target_id = "takeSnapshot"
    arn       = "${aws_lambda_function.ebs-backup-create.arn}"
}
resource "aws_cloudwatch_event_target" "cleanup_every_day" {
    rule      = "${aws_cloudwatch_event_rule.every_day.name}"
    target_id = "cleanSnapshot"
    arn       = "${aws_lambda_function.ebs-backup-delete.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_EBSToSnapshotBackup" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.ebs-backup-create.function_name}"
    principal     = "events.amazonaws.com"
    source_arn    = "${aws_cloudwatch_event_rule.every_day.arn}"
}
resource "aws_lambda_permission" "allow_cloudwatch_to_call_EBSToSnapshotCleanup" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.ebs-backup-delete.function_name}"
    principal     = "events.amazonaws.com"
    source_arn    = "${aws_cloudwatch_event_rule.every_day.arn}"
}

resource "aws_cloudwatch_log_group" "createSnapshot" {
    name = "/aws/lambda/createSnapshot"

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
resource "aws_cloudwatch_log_group" "deleteSnapshot" {
    name = "/aws/lambda/deleteSnapshot"

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
