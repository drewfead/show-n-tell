# name of this stack
output "stackName" {
  value = "${var.stackName}-${var.deploymentColor}-${var.runtime}-${var.branch}${terraform_remote_state.universe.output.suffix}"
}

output "processorQueueName" {
  value = "${aws_cloudformation_stack.processorQueue.outputs.Name}"
}

output "processorQueueEndpoint" {
  value = "${aws_cloudformation_stack.processorQueue.outputs.Endpoint}"
}

output "processorQueueArn" {
  value = "${aws_cloudformation_stack.processorQueue.outputs.Arn}"
}

output "thriftServerPort" {
  value = "${var.thriftServerPort}"
}

output "auditPort" {
  value = "${var.auditPort}"
}

output "auditWebsocketStreamPrefix" {
  value = "${var.auditWebsocketStreamPrefix}"
}

output "auditMonitorThriftPath" {
  value = "${var.auditMonitorThriftPath}"
}
