# EC2 Connect Script

param(
  [string] $StackName = "shielden-stack",
  [string] $prof= "default",
  [string] $s3Bucket = "cf-templates-pv3yd0upcced-eu-north-1",
  [switch] $Config 
)

$ErrorActionPreference = "Stop"

#Gets the current instance ID from stack and logical resource ID eliminating the issue if two instances were running
$instanceId = aws cloudformation describe-stack-resources --stack-name $StackName --profile $prof `
 --logical-resource-id ShieldenSuiteInstance --query "StackResources[0].PhysicalResourceId" --output text
 
if ($Config) {
    Write-Host "Uploading configuration scripts"
    aws s3 cp "$PSScriptRoot\scripts\snort-config.sh" "s3://$s3Bucket/scripts/" --profile $prof

    Write-Host "Running config on instance"
    $cmdID = aws ssm send-command --instance-ids $instanceId --profile $Profile --document-name "AWS-RunRemoteScript" `
    --parameters "file://$PSScriptRoot\params.json" `
    --query "Command.CommandId" --output text
}

Write-Host "Opening DCV session"
aws ssm start-session --target $instanceId --profile $Profile `
  --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8443"],"localPortNumber":["8443"]}'
