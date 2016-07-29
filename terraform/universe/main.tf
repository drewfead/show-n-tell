provider "aws" {
  # access_key = "${var.awsAccessKey}"
  # secret_key = "${var.awsSecretKey}"
  # token      = "${var.awsSessionToken}"
  region     = "${var.region}"
}

# RESOURCES

resource "aws_s3_bucket" "s3CodePipelineBucket" {
  bucket      = "${var.s3CodePipelineBucketName}${var.suffix}"
  acl         = "private"

  force_destroy = true

  versioning {
    enabled   = true
  }
}

# deployment-switcher

resource "aws_elastic_beanstalk_application" "appGW" {
  description = "ingress point"
  name        = "${var.universeGWAppName}${var.suffix}"
}