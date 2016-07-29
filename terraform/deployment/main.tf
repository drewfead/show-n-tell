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

# deploy pipeline

resource "aws_lambda_function" "parseDeployReadyFile" {
  description = "push to shared s3 bucket"
  source_code_hash = "${base64sha256(file(var.pipelineLambdaZip))}"
  filename = "${var.pipelineLambdaZip}"
  function_name = "show-n-tell-parse-deploy-readyfile-${var.runtime}-${var.deploymentColor}${terraform_remote_state.universe.output.suffix}"
  handler = "parse-deploy-readyfile.lambda_handler"
  role = "${terraform_remote_state.universe.output.superRoleARN}"
  runtime = "python2.7"
  memory_size = 128
  timeout = 20
}

resource "aws_cloudformation_stack" "deployPipeline" {
  name = "show-n-tell-deploy-pipeline-${var.runtime}-${var.deploymentColor}${terraform_remote_state.universe.output.suffix}"
  template_body = "${file("../codepipeline/deploy-pipeline.json")}"
  parameters {
    "ReadyFileKey" = "${terraform_remote_state.build.output.readyFileKey}"
    "ReadyFileBucket" = "${terraform_remote_state.build.output.readyFileBucket}"
    "Color" = "${var.deploymentColor}"
    "PipelineName" = "${var.stackName}-${replace(var.branch,"/", "-" )}-${var.runtime}-${var.deploymentColor}${terraform_remote_state.universe.output.suffix}"
    "SuperRoleARN" = "${terraform_remote_state.universe.output.superRoleARN}"

    "ParseDeployReadyFileLambda" = "${aws_lambda_function.parseDeployReadyFile.function_name}"
    "DeploymentConfig" = "${var.runtime}:${var.branch}:${var.deploymentColor}:${terraform_remote_state.universe.output.suffix}"
    "Depends" = "${aws_lambda_function.parseDeployReadyFile.arn}"
  }
}
