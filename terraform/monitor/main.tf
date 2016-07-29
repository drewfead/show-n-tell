provider "aws" {
  # access_key = "${var.awsAccessKey}"
  # secret_key = "${var.awsSecretKey}"
  region = "${var.region}"
}

resource "terraform_remote_state" "universe" {
  backend     = "s3"
  config {
    bucket    = "${var.universeStateBucket}"
    key       = "u${var.universeSuffix}"
    region    = "${var.region}"
  }
}

# dispatched by runtime

resource "terraform_remote_state" "persistent" {
  backend     = "s3"
  config {
    bucket    = "${var.universeStateBucket}"
    key       = "p-${var.runtime}"
    region    = "${var.region}"
  }
}

# dispatched by git branch

resource "terraform_remote_state" "build" {
  backend     = "s3"
  config {
    bucket    = "${var.universeStateBucket}"
    key       = "b-${var.branch}"
    region    = "${var.region}"
  }
}

# dispatched by runtime, branch, and color

resource "terraform_remote_state" "deployment" {
  backend     = "s3"
  config {
    bucket    = "${var.universeStateBucket}"
    key       = "d-${var.runtime}-${var.branch}-${var.deploymentColor}"
    region    = "${var.region}"
  }
}

# pagerduty integration

resource "aws_sns_topic" "alarmTopic" {
  name = "${var.alarmTopicName}-${var.deploymentColor}-${var.runtime}${terraform_remote_state.universe.output.suffix}"
}

resource "aws_sns_topic_subscription" "alarmToPagerduty" {
  topic_arn               = "${aws_sns_topic.alarmTopic.arn}"
  protocol                = "https"
  endpoint                = "${var.pagerdutyIntegration}"
  endpoint_auto_confirms  = true
}

resource "aws_cloudwatch_metric_alarm" "tellBackPressureAlarm" {
  threshold = "${var.tellQueueBackpressureThreshold}"
  period = "${var.alarmHeartbeat}"
  evaluation_periods = "2"

  alarm_name = "${terraform_remote_state.deployment.output.processorQueueName}-backpressure"
  alarm_description = "The backpressure for ${terraform_remote_state.deployment.output.tellQueueName} has exceeded the threshold"

  alarm_actions = ["${aws_sns_topic.alarmTopic.arn}"]
  ok_actions    = ["${aws_sns_topic.alarmTopic.arn}"]
  insufficient_data_actions = []

  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible" // messages in flight
  dimensions {
    QueueName = "${terraform_remote_state.deployment.output.processorQueueName}"
  }

  statistic = "Average"
}

