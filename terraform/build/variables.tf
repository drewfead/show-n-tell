# identifiers

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

variable "branch" {
  description = "git branch to build from"
  type        = "string"
}

variable "stackName" {
  description = "name of this stack"
  default     = "build"
  type        = "string"
}

# shared state

variable "universeStateBucket" {
  description = "the remote-state bucket used by the universe stack"
  default = "show-n-tell-state"
}

variable "universeSuffix" {
  description = "suffix identifying the universe we are in"
  default = ""
}

# build pipeline config

variable "gitProject" {
  description = "git project to build from"
  default     = "show-n-tell"
  type        = "string"
}

variable "pipelineLambdaZip" {
  description = "zipped lambda file"
  default     = "../lambda/create-deploy-readyfile.zip"
  type        = "string"
}