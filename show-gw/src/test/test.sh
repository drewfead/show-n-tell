#! /bin/bash

    #https://oht7hz94a1.execute-api.us-east-1.amazonaws.com/prod/michaelLambdaFn << EOF
    #http://dev-env.snuir5z6ia.us-east-1.elasticbeanstalk.com << EOF

curl -X POST \
    -d @- \
    http://localhost:9080 << EOF
{
 "Events": [
 {
 "CustomerId": "b512a905-89d9-4950-a44a-77a3b67081e3",
 "EventId": 13961,
 "EventDateTime": "2015-10-05T18:46:47Z",
 "ConversionId": 31,
 "ConversionName": "Call-8774807337",
 "ConversionType": "Calls",
 "TrackingNumber": "8664808226",
 "TargetNumber": "12067929642",
 "Duration": 12,
 "SalesDisposition": "No Entry",
 "SalesValue": 0.00,
 "CustomCustomerId": "crmtestaudi"
 }
 ]
}

EOF

echo ""
