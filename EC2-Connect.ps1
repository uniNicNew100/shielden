aws s3 cp .\scripts\configure-snort.sh s3://cf-templates-pv3yd0upcced-eu-north-1/scripts/ --profile $Profile

aws ssm send-command --instance-ids $id --profile $Profile `
  --document-name AWS-RunRemoteScript `
  --parameters file://snort-params.json