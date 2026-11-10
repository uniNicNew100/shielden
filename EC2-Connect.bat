//need to create script to setup the EC2 instance for the user. 

//only excecute once user has downloaded the Shielden-ENC.pem file from the email and placed it in the Downloads folder.

//moves the Shielden-ENC.pem file from the Downloads folder to the .ssh folder in the user's profile directory.
move "%USERPROFILE%\Downloads\Shielden-ENC.pem" "%USERPROFILE%\.ssh\" 


//need else statement to check if the file exists in the Downloads folder before moving it. If it doesn't exist, prompt the user to download it first.

//removes inheritance https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/icacls 
icacls "%USERPROFILE%\.ssh\Shielden-ENC.pem" /inheritance:r

//Grants read-only access to the user for the Shielden-ENC.pem file.
icacls "%USERPROFILE%\.ssh\Shielden-ENC.pem" /grant:r "%USERNAME%:R"

//This PowerShell script retrieves the public IP address of the machine running the script and authorizes inbound traffic on ports 22, 443, and 8443 for the specified security group in AWS EC2.
 $ip = (Invoke-RestMethod https://checkip.amazonaws.com).Trim()
$sg = aws ec2 describe-security-groups --region eu-north-1 --filters Name=group-name,Values=Shielden-Security --query "SecurityGroups[0].GroupId" --output text
$rules = @(@("tcp",22), @("tcp",443), @("tcp",8443), @("udp",8443))
foreach ($r in $rules) {
  aws ec2 authorize-security-group-ingress --region eu-north-1 --group-id $sg --ip-permissions "IpProtocol=$($r[0]),FromPort=$($r[1]),ToPort=$($r[1]),IpRanges=[{CidrIp=$ip/32,Description=auto-$(Get-Date -Format yyyy-MM-dd)}]"
}
Write-Host "Allowed $ip on $sg"

//launches an SSH connection to the specified EC2 instance using the Shielden-ENC.pem key for authentication.
ssh -i "%USERPROFILE%\.ssh\Shielden-ENC.pem" ubuntu@ec2-13-60-206-177.eu-north-1.compute.amazonaws.com 

//need to add a check here to see if the SSH connection was successful.


//then need to figure out how to run this command automatically without user input.
//sets a new password for the ubuntu user on the remote EC2 instance. The user will be prompted to enter and confirm the new password.
sudo passwd ubuntu