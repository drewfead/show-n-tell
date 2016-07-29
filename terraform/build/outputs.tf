# key of the ready file
output "readyFileKey" {
  value = "${aws_cloudformation_stack.buildPipeline.outputs.ReadyFileKey}"
}

# bucket that holds the ready file
output "readyFileBucket" {
  value = "${aws_cloudformation_stack.buildPipeline.outputs.ReadyFileBucket}"
}

# name of this stack
output "stackName" {
  value = "${var.stackName}-${var.branch}${terraform_remote_state.universe.output.suffix}"
}