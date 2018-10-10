output "lambda_backup_create_script" {
    value = "${aws_lambda_function.ebs-backup-create.filename}"
}
output "lambda_backup_delete_script" {
    value = "${aws_lambda_function.ebs-backup-delete.filename}"
}
output "scheduler" {
    value = "${aws_cloudwatch_event_rule.backup_every_day.schedule_expression}"
}
