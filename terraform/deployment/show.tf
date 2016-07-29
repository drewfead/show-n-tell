resource "aws_elastic_beanstalk_environment" "showGateway" {
  application = "${terraform_remote_state.universe.output.gwAppName}"
  name = "${terraform_remote_state.universe.output.gwAppName}-${var.deploymentColor}-${var.runtime}${terraform_remote_state.universe.output.suffix}"
  cname_prefix = "${var.cnamePrefix}"
  solution_stack_name = "${var.solutionStack}"
  wait_for_ready_timeout = "20m"


  ## AWS Launch Configurations

  # Instance Profile
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "${terraform_remote_state.universe.output.superRoleInstanceProfileARN}"
  }

  # EC2KeyName
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "${terraform_remote_state.universe.output.sshKeyPair}"
  }

  # Instance type to use
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "${var.keymetricGWAppInstanceType}"
  }


  ## AWS Autoscaling

  # Min Size
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }

  # Max Size
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "1"
  }


  ## Environment Variables

  # Deployment Color
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "deploymentColor"
    value = "${var.deploymentColor}"
  }

  # Runtime Enviornment
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "runtimeEnvironment"
    value = "${var.runtime}"
  }

  # App Name
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "appName"
    value = "${terraform_remote_state.universe.output.gwAppName}"
  }

  # PROCESSOR_QUEUE_IDENTIFIER
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "TELL_QUEUE_IDENTIFIER"
    value = "${aws_sqs_queue.tellQueue.id}"
  }

  # PORT
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "PORT"
    value = "${var.gwPort}"
  }

  # MONITOR_HEARTBEAT
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "MONITOR_HEARTBEAT"
    value = "${var.monitorHeartbeat}"
  }

  # MONITOR_BEATS_PER_WINDOW
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "MONITOR_BEATS_PER_WINDOW"
    value = "${var.monitorBeatsPerWindow}"
  }
}
