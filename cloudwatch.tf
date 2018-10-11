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

# Those 2 lambda script are able to create log_stream on the fly, but delete the resource.
# The resaon that I put here is, it could be managed by terraform among apply and desctroy sub command
# Prefix /aws/lambda is default value
resource "aws_cloudwatch_log_group" "createSnapshot" {
    name = "/aws/lambda/${aws_lambda_function.ebs-backup-create.function_name}"

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
resource "aws_cloudwatch_log_group" "deleteSnapshot" {
    name = "/aws/lambda/${aws_lambda_function.ebs-backup-delete.function_name}"

    tags {
        Environment = "${terraform.workspace}"
        Project     = "${var.project}"
    }
}
