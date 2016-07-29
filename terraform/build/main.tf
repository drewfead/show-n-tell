provider "aws" {
  # access_key = "${var.awsAccessKey}"
  # secret_key = "${var.awsSecretKey}"
  # token      = "${var.awsSessionToken}"
  region     = "${var.region}"
}

# RESOURCES

resource "terraform_remote_state" "universe" {
  backend     = "s3"
  config {
    bucket    = "${var.universeStateBucket}"
    key       = "u${var.universeSuffix}"
    region    = "${var.region}"
  }
}

resource "aws_lambda_function" "createDeployReadyFile" {
  description       = "push to shared s3 bucket"
  source_code_hash  = "${base64sha256(file(var.pipelineLambdaZip))}"
  filename          = "${var.pipelineLambdaZip}"
  function_name     = "show-n-tell-deploy-readyfile-${replace(var.branch,"/", "-" )}-${var.stackName}${terraform_remote_state.universe.output.suffix}"
  handler           = "create-deploy-readyfile.lambda_handler"
  role              = "${terraform_remote_state.universe.output.superRoleARN}"
  runtime           = "python2.7"
  memory_size       = 128
  timeout           = 20
}

resource "aws_cloudformation_stack" "buildPipeline" {
  name = "show-n-tell-build-pipeline-${replace(var.branch,"/", "-" )}-${var.stackName}${terraform_remote_state.universe.output.suffix}"
//  depends_on = [ "${aws_lambda_function.createDeployReadyFile.arn}" ]
  template_body = "${file("../codepipeline/build-pipeline.json")}"
  parameters = {
    "Project"                 = "${var.gitProject}"
    "Branch"                  = "${var.branch}"
    "UniverseName"            = "${terraform_remote_state.universe.output.suffix}"
    "PipelineName"            = "${var.stackName}-${replace(var.branch,"/", "-" )}${terraform_remote_state.universe.output.suffix}"
    "S3BucketName"            = "${terraform_remote_state.universe.output.s3DeployBucketName}"
    "S3FileKey"               = "${var.stackName}-${replace(var.branch,"/", "-" )}/deploy.json"
    "ReadyFileKey"            = "${terraform_remote_state.universe.output.s3DeployBucketName}:${var.stackName}-${replace(var.branch,"/", "-" )}/deploy.json"
    "GWAppName"               = "${terraform_remote_state.universe.output.gwAppName}"
    "SuperRoleARN"            = "${terraform_remote_state.universe.output.superRoleARN}"
    "CreateDeployReadyFileLambda" = "${aws_lambda_function.createDeployReadyFile.function_name}"
    "Depends"                 = "${aws_lambda_function.createDeployReadyFile.arn}"
  }
}

