# identifying info

variable "region" {
  description = "AWS region to create resources in"
  default = "us-east-1"
  type = "string"
}

variable "availabilityZones" {
  description = "availability zones"
  default = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
  type = "string"
}

variable "stackName" {
  default = "monitor"
  description = "name of this stack"
  type = "string"
}

variable "deploymentColor" {
  description = "color of this application stack deployment (blue, green, purple, orange)"
  type = "string"
}

variable "runtime" {
  type = "string"
}

variable "branch" {
  default = "master"
  type = "string"
}

# shared state

variable "universeStateBucket" {
  description = "the remote-state bucket used by the universe stack"
  default = "show-n-tell-state"
  type = "string"
}

variable "universeSuffix" {
  description = "suffix describing the universe"
  default = ""
  type = "string"
}

# alarm config

variable "alarmHeartbeat" {
  description = "heartbeat to alert on, in seconds"
  default = "120"
}

variable "alarmTopicName" {
  description = "name of the sns topic for alarms"
  default = "AlertPublishing"
}

variable "pagerdutyIntegration" {
  description = "https endpoint for cloudwatch/pagerduty integration"
  default = "https://events.pagerduty.com/integration/14fc68ede37546c7b412954a00e6e382/enqueue"
}

# thresholds

#processor specific
variable "tellQueueBackpressureThreshold" {
  description = "number of messages considered unhealthy backpressure on the processor queue"
  default = "1"
}