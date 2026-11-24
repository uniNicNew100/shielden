

param(
  [string] $StackName = "shielden-stack",
  [string] $prof= "default",
  [string] $s3Bucket = "cf-templates-pv3yd0upcced-eu-north-1",
  [switch] $Config 
)

$ErrorActionPreference = "Stop"

#Converts Json param file to plain text so that it can be passed to the AWS CLI command. The AWS CLI command does not accept JSON files as parameters, so we need to convert the JSON to a string and pass it as a parameter.
$AllParams = Get-Content "$PSScriptRoot\params.json" -Raw | ConvertFrom-Json
function Get-ParamFile([string]$Name) {
    $section = $AllParams.$Name
    $path = Join-Path $env:TEMP "shielden-$Name.json"
    $json = $section | ConvertTo-Json -Depth 5 -Compress
    [IO.File]::WriteAllText($path, $json, [Text.UTF8Encoding]::new($false))
    return "file://$path"
}

#Gets the current instance ID from stack and logical resource ID eliminating the issue if two instances were running
$instanceId = aws cloudformation describe-stack-resources --stack-name $StackName --profile $prof `
 --logical-resource-id ShieldenSuiteInstance --query "StackResources[0].PhysicalResourceId" --output text
 
if ($Config) {
    Write-Host "Uploading configuration scripts"
    aws s3 cp "$PSScriptRoot\snort-config.sh" "s3://$s3Bucket/scripts/" --profile $prof
    aws s3 cp "$PSScriptRoot\user-create.sh" "s3://$s3Bucket/scripts/" --profile $prof
    aws s3 cp "$PSScriptRoot\wazuh-config.sh" "s3://$s3Bucket/scripts/" --profile $prof

    Write-Host "Running config on instance"
    $snortCmdID = aws ssm send-command --instance-ids $instanceId --profile $prof --document-name "AWS-RunRemoteScript" `
    --parameters (Get-ParamFile "Snort") `
    --query "Command.CommandId" --output text

    Write-Host "Running Wazuh Config"
    $wazuhCmdID = aws ssm send-command --instance-ids $instanceId --profile $prof --document-name "AWS-RunRemoteScript" `
    --parameters (Get-ParamFile "Wazuh") `
    --query "Command.CommandId" --output text

    Write-Host "Copying user-create script"
    $fetchCmdId = aws ssm send-command --instance-ids $instanceId --profile $prof `
    --document-name "AWS-RunShellScript" `
    --parameters (Get-ParamFile "FetchUserCreate") `
    --query "Command.CommandId" --output text

    foreach ($c in @($snortCmdID, $wazuhCmdID, $fetchCmdId)) {
        aws ssm wait command-executed --command-id $c --instance-id $instanceId --profile $prof
        aws ssm get-command-invocation --command-id $c --instance-id $instanceId --profile $prof `
        --query "{Status:Status,Output:StandardOutputContent,Errors:StandardErrorContent}"
    }
   
    Write-Host "Create your user name and password"
     Write-Host "Create your Shielden login:"
    aws ssm start-session --target $instanceId --profile $prof `
      --document-name "AWS-StartInteractiveCommand" --parameters (Get-ParamFile "UserCreate")
}

Write-Host "Opening DCV session"
aws ssm start-session --target $instanceId --profile $prof `
  --document-name AWS-StartPortForwardingSession --parameters (Get-ParamFile "PortForward")
