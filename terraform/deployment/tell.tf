resource "aws_sqs_queue" "tellQueue" {
  name = "tell-in-${var.deploymentColor}-${var.runtime}${var.universeSuffix}"
}