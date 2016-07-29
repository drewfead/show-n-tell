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
    codePipeline = boto3.client("codepipeline")
    s3Client = boto3.resource("s3", config=Config(signature_version="s3v4"))
    try:
        tempReadyFile = "/tmp/deploy.json"
        readyFileLocation = event["CodePipeline.job"]["data"]["inputArtifacts"][0]["location"]["s3Location"]
        s3Client = boto3.resource("s3", config=Config(signature_version="s3v4"))
        readyFileBucket = s3Client.Bucket(readyFileLocation["bucketName"])
        readyFileBucket.download_file(readyFileLocation["objectKey"], tempReadyFile)
        
        readyFileJson = {}
        with open(tempReadyFile, "r") as file:
             readyFileJson = json.load(file)
        
        print(json.dumps(readyFileJson))
        
        tempArtifact = "/tmp/artifact.zip"
        for artifact in event["CodePipeline.job"]["data"]["outputArtifacts"]:
            dlRef = readyFileJson["artifacts"][artifact["name"]]
            dlBucket = s3Client.Bucket(dlRef["bucket"])
            dlBucket.download_file(dlRef["key"], tempArtifact)
            ulRef = artifact["location"]["s3Location"]
            ulBucket = s3Client.Bucket(ulRef["bucketName"])
            ulBucket.upload_file(tempArtifact, ulRef["objectKey"])
        
        codePipeline.put_job_success_result(jobId=jobId)
        return readyFileJson
    except Exception as e:
        print("!!! FAILED")
        print(e)
        codePipeline.put_job_failure_result(
            jobId=jobId,
            failureDetails={"message": str(e), "type": "JobFailed"}
        )
        raise