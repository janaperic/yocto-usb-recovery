#!/bin/sh

# Check if USB drive labeled "RECOVERY" is present
if [[ ! $(blkid | grep RECOVERY | wc -c) -ne 0 ]]; then
        echo "Recovery USB not detected."
        umount /media/RECOVERY
        exit 0;
fi

# Find the location of the drive
locate_usb=$(blkid | grep RECOVERY)
locate_usb=${locate_usb%%\:*}
echo "Recovery USB detected at $locate_usb location."

# Mount the drive at /media/RECOVERY with read-write persmissions
if [ ! -d "/media/RECOVERY" ]; then
        echo "Creating /media/RECOVERY dir"
        mkdir /media/RECOVERY
fi
mount -o rw $locate_usb /media/RECOVERY
if [ ! $(echo $?) -eq 0 ]; then
        echo "USB not mounted properly. Aborting."
        umount /media/RECOVERY
	exit 0;
else
        echo "Recovery USB mounted at /media/RECOVERY."
fi

# Check if recovery-settings.json is present
if [ ! -f "/media/RECOVERY/system/recovery-settings.json" ]; then
        echo "recovery-setting.json not found. Aborting."
        umount /media/RECOVERY
	exit 0;
fi

# Parse the recovery-settings.json
if [ $(jq -r .getLogs /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
	dmesg >> /media/RECOVERY/system/logs
        echo "Copied kernel logs to /media/RECOVERY/system/logs"
fi

if [ $(jq -r .listServices /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
	systemctl --type=service >> /media/RECOVERY/system/services
        echo "Listed systemd services at /media/RECOVERY/system/services"
fi

if [ $(jq -r .performUpdate /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
        if [ -f "$(jq -r .updateFile /media/RECOVERY/system/recovery-settings.json)" ]; then
                echo "Update available. Updating..."

                #Do the actual update and check if it was successful
                mender install $(jq -r .updateFile /media/RECOVERY/system/recovery-settings.json)
                if [ ! $(echo $?) -eq 0 ]; then
                        echo "Update failed. Aborting."
                        umount /media/RECOVERY
	                exit 0;
                fi
                mender commit
                if [ ! $(echo $?) -eq 0 ]; then
                        echo "Commiting update failed. Aborting."
                        umount /media/RECOVERY
	                exit 0;
                fi
                echo "Update done."

                # Disable update on next boot
                tmp=$(mktemp)
                jq '."performUpdate" = "no"' /media/RECOVERY/system/recovery-settings.json > "$tmp" && mv "$tmp" /media/RECOVERY/system/recovery-settings.json

                #Change active and passive partitions 
                if [ $(cat /boot/efi/cmdline.txt | grep -c "root=/dev/mmcblk0p3") -eq 1 ]; then
                        sed -i "s/mmcblk0p3/mmcblk0p2/g" /boot/efi/cmdline.txt
                elif [ $(cat /boot/efi/cmdline.txt | grep -c "root=/dev/mmcblk0p2") -eq 1 ]; then
                        sed -i "s/mmcblk0p2/mmcblk0p3/g" /boot/efi/cmdline.txt
                fi
                echo "Reversed active and passive partitions"

                # Reboot, if required 
                if [ $(jq -r .autoReboot /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
                        echo "Rebooting..."
                        umount /media/RECOVERY
                        reboot
                else
                        echo "Please reboot for changes to take place."
                fi
        else
                echo "Update file not found."
        fi
else
        echo "Update unnecessary."
fi


echo "End of recovery."
umount /media/RECOVERY
exit 0
