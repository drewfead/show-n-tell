variable "region" {
  description = "aws region to create resources in"
  default     = "us-east-1"
  type        = "string"
}

variable "availabilityZones" {
  description = "availability zones"
  default     = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
  type        = "string"
}

variable "s3CodePipelineBucketName" {
  description = "label for codepipeline bucket"
  default     = "show-n-tell-deployment"
  type        = "string"
}

variable "universeGWAppName" {
  description = "label for keymetric gateway app"
  default     = "show-gw"
  type        = "string"
}

variable "suffix" {
  description = "name of this universe"
  default     = ""
  type        = "string"
}