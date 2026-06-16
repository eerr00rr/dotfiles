#!/bin/bash

# Get the last result of the systemd service
STATUS=$(systemctl --user show -p ExecMainStatus --value restic-backup.service)
STATE=$(systemctl --user is-active restic-backup.service)

if [ "$STATE" == "active" ]; then
    echo '{"text": "󱑒", "tooltip": "Backup in progress...", "class": "running"}'
elif [ "$STATUS" == "0" ]; then
    echo '{"text": "󰄬", "tooltip": "Last backup successful", "class": "success"}'
else
    echo '{"text": "󰅙", "tooltip": "Last backup FAILED", "class": "failed"}'
fi
