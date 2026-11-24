#!/usr/bin/env bash
# Description: This script is used to configure the snort rules on the EC2 instance.

#Finds default network of instance as in the ec2intialise.json script when setting user data it makes the cli non interactive this means that snort cannot ask the user which network to use resulting in it defaulting to eth0 https://notes.runtimeterror.dev/Linux/Get-local-IP-of-default-interface.html 
MyInterface=$(ip route show default | awk '{print $5}')
sed -i "s|^DEBIAN_SNORT_INTERFACE=.*|DEBIAN_SNORT_INTERFACE=\"$MyInterface\"|" /etc/snort/snort.debian.conf
sed -i "s|^DEBIAN_SNORT_HOME_NET=.*|DEBIAN_SNORT_HOME_NET=\"10.0.0.0/16\"|" /etc/snort/snort.debian.conf

#Allows snort to log to the fast alert file so wazuh can read it and output it to the dashboard
grep -q '^output alert_fast' /etc/snort/snort.conf || echo 'output alert_fast: snort.alert.fast' >> /etc/snort/snort.conf

# Overwrites so doesnt keep creating new rules, This rule alerts to any outbound traffic entering the network
cat > /etc/snort/rules/local.rules <<'EOF'
alert icmp any any -> $HOME_NET any (msg:"ICMP test"; sid:1000001; rev:1;)
EOF

systemctl restart snort