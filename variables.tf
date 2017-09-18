variable "region"      {}
variable "project"     {}
variable "aws_profile" {}

provider "aws" {
    alias   = "${var.region}"
    region  = "${var.region}"
    profile = "${var.aws_profile}"
}
