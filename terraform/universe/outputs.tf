# OUTPUTS

#name of the universe
output "suffix" {
  value       = "${var.suffix}"
}

#s3 bucket name for codepipeline
output "s3DeployBucketName" {
  value       = "${aws_s3_bucket.s3CodePipelineBucket.bucket}"
}

#name of the gateway
output "gwAppName" {
  value       = "${var.universeGWAppName}${var.suffix}"
}

#super role arn
output "superRoleARN" {
  value       = "arn:aws:iam::555163251479:role/SuperRole"
  sensitive   = true
}

#super role instance profile
output "superRoleInstanceProfileARN" {
  value       = "arn:aws:iam::555163251479:instance-profile/SuperRole"
  sensitive   = true
}

