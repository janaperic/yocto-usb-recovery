#!/bin/sh

# Check if USB drive labeled "RECOVERY" is present
if [[ ! $(blkid | grep RECOVERY | wc -c) -ne 0 ]]; then
        echo "Recovery USB not detected."
        exit 0;
fi

# Find the location of the drive
locate_usb=$(blkid | grep RECOVERY)
locate_usb=${locate_usb%%\:*}
echo "Recovery USB detected at $locate_usb location."

# Mount the drive at /media/RECOVERY
if [ ! -d "/media/RECOVERY" ]; then
        echo "Creating /media/RECOVERY dir"
        mkdir /media/RECOVERY
fi
mount $locate_usb /media/RECOVERY
echo "Recovery USB mounted at /media/RECOVERY."

# Check if recovery-settings.json is present
if [ ! -f "/media/RECOVERY/system/recovery-settings.json" ]; then
	exit 0;
fi

# Parse the recovery-settings.json
if [ $(jq -r .getLogs /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
	dmesg >> /media/RECOVERY/system/logs
fi

if [ $(jq -r .listServices /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
	systemctl --type=service >> /media/RECOVERY/system/services
fi

if [ $(jq -r .performUpdate /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
        if [ ! -f "$(jq -r .updateFile /media/RECOVERY/system/recovery-settings.json)" ]; then
                mender install $(jq -r .updateFile /media/RECOVERY/system/recovery-settings.json)
                mender commit
        fi
fi