# identifying info

variable "region" {
  description = "AWS region to create resources in"
  default = "us-east-1"
}

variable "availabilityZones" {
  description = "availability zones"
  default = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
}

variable "runtime" {
  type = "string"
}

variable "stackName" {
  default = "deploy"
  description = "name of this stack"
}

variable "deploymentColor" {
  description = "color of this application stack deployment (blue, green, purple, orange)"
}

variable "accountId" {
  description = "aws accountId to create resources in"
  type        = "string"
}

# shared state

variable "universeStateBucket" {
  description = "the remote-state bucket used by the universe stack"
  default = "show-n-tell-state"
}

variable "universeSuffix" {
  description = "suffix describing the universe"
  default = ""
}

# app configs

variable "solutionStack" {
  default = "64bit Amazon Linux 2016.03 v2.1.1 running Java 8"
}

# keymetric configs

variable "gwPort" {
  default = "8080"
  description = "port that gw should run listen for http on"
}

variable "gwAppInstanceType" {
  default = "t1.micro"
}

# cloudwatch configs

variable "monitorHeartbeat" {
  default = "5000"
  description = "time to wait between monitor polling"
}

variable "monitorBeatsPerWindow" {
  default = "3"
  description = "number of heartbeats to consider in a monitoring rate window"
}

# deploy pipeline configs

variable "branch" {
  description = "git branch to deploy from"
}

variable "pipelineLambdaZip" {
  description = "zipped lambda deploy file"
  default     = "../lambda/parse-deploy-readyfile.zip"
  type        = "string"
}
