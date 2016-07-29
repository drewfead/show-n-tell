from __future__ import print_function

import json
import urllib
import boto3
import datetime
import sys
import os
from botocore.client import Config

def lambda_handler(event, context):
    jobId = event["CodePipeline.job"]["id"]
    codePipeline = boto3.client('codepipeline')
    s3Client = boto3.resource('s3', config=Config(signature_version='s3v4'))
    try:
        readyFileJson = {
          "project": "TODO:lead-intake",
          "branch": "TODO:master",
          "version": jobId,
          "artifacts": {}
        }
        for artifact in event["CodePipeline.job"]["data"]["inputArtifacts"]:
            readyFileJson["artifacts"][artifact["name"]] = {
                "bucket": artifact["location"]["s3Location"]["bucketName"],
                "key": artifact["location"]["s3Location"]["objectKey"]
            }
        print(json.dumps(readyFileJson))
        localFile = "/tmp/deploy.json"
        with open(localFile, "w") as file:
            json.dump(readyFileJson, file)
        
        params = event["CodePipeline.job"]["data"]["actionConfiguration"]["configuration"]["UserParameters"].split(":", 1)
        bucketName = params[0]
        key = params[1]
        bucket = s3Client.Bucket(bucketName)
        bucket.upload_file(localFile, key)
        print("Uploaded to: " + bucketName + " / " + key)
        
        codePipeline.put_job_success_result(jobId=jobId)
        return { "result": "success" }
    except Exception as e:
        print("!!! FAILED")
        print(e)
        codePipeline.put_job_failure_result(
            jobId=jobId,
            failureDetails={"message": str(e), "type": "JobFailed"}
        )
        raise
