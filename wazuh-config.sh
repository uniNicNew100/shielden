#!/usr/bin/env bash
# Description: This script is used to configure the Wazuh agent on the EC2 instance. It should be called by ec2-Connect.ps1.
set -euo pipefail 

OSSEC=/var/ossec/etc/ossec.conf
SNORT_LOG=/var/log/snort/snort.alert.fast

mkdir -p /var/log/snort
touch "$SNORT_LOG"



if grep -q "$SNORT_LOG" "$OSSEC"; then
    echo "Snort log already configured in Wazuh. Skipping configuration."
    exit 0
    fi


    cp "$OSSEC" "$OSSEC.bak"


    
    cat >> "$OSSEC" <<EOF

    <ossec_config>
        <localfile>
            <log_format>snort-fast</log_format>
            <location>$SNORT_LOG</location>
        </localfile>
    </ossec_config>
EOF


if systemctl restart wazuh-manager ; then
    echo "Wazuh logs configured successfully."
else
    echo "Failed to restart Wazuh agent. Please check the logs for more details." >&2
    cp "$OSSEC.bak" "$OSSEC"
    systemctl restart wazuh-manager
    exit 1
fi
