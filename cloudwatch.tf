resource "aws_cloudwatch_event_rule" "backup_every_day" {
    name                = "backup-every-day"
    description         = "Fires every day"
    schedule_expression = "${var.event_schedule}"
}

resource "aws_cloudwatch_event_target" "snapshot_every_day" {
    rule      = "${aws_cloudwatch_event_rule.backup_every_day.name}"
    target_id = "takeSnapshot"
    arn       = "${aws_lambda_function.ebs-backup-create.arn}"
}
resource "aws_cloudwatch_event_target" "cleanup_every_day" {
    rule      = "${aws_cloudwatch_event_rule.backup_every_day.name}"
    target_id = "cleanSnapshot"
    arn       = "${aws_lambda_function.ebs-backup-delete.arn}"
}

resource "aws_cloudwatch_log_group" "createSnapshot" {
    name = "${var.awslog_base_path}/${aws_lambda_function.ebs-backup-create.function_name}"

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
resource "aws_cloudwatch_log_group" "deleteSnapshot" {
    name = "${var.awslog_base_path}/${aws_lambda_function.ebs-backup-delete.function_name}"

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
