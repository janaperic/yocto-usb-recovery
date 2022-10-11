#!/bin/sh

# Check if USB drive labeled "RECOVERY" is present
if [[ ! $(blkid | grep RECOVERY | wc -c) -ne 0 ]]; then
        echo "Recovery USB not detected."
        exit 0
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
        exit 0
else
        echo "Recovery USB mounted at /media/RECOVERY."
fi

if [ -f "/media/RECOVERY/system/recovery-settings.json" ]; then
        echo "Please remove recovery-settings.json file and use recovery-setting.json.signed instead." >> /media/RECOVERY/system/usb-mount.log
        umount /media/RECOVERY
        exit 0
fi 

# Check if recovery-settings.json.signed is present
if [ ! -f "/media/RECOVERY/system/recovery-settings.json.signed" ]; then
        echo "recovery-setting.json.signed not found. Aborting."
        cp /var/log/usb-mount.log /media/RECOVERY/system/
        umount /media/RECOVERY
        exit 0
fi

# Decrypt recovery-settings.json.signed
openssl rsautl -verify -inkey /opt/keys/recovery-key.txt -in /media/RECOVERY/system/recovery-settings.json.signed -pubin > /media/RECOVERY/system/recovery-settings.json
if [ ! $(echo $?) -eq 0 ]; then
        echo "Decrypting file failed. Aborting."
        cp /var/log/usb-mount.log /media/RECOVERY/system/
        umount /media/RECOVERY
        exit 0
fi
echo "Decryption successful."

# Parse the recovery-settings.json
if [ $(jq -r .getLogs /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
	dmesg > /media/RECOVERY/system/logs
        echo "Copied kernel logs to /media/RECOVERY/system/logs"
fi

if [ $(jq -r .listServices /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
	systemctl --type=service > /media/RECOVERY/system/services
        echo "Listed systemd services at /media/RECOVERY/system/services"
fi

if [ $(jq -r .enableSSH /media/RECOVERY/system/recovery-settings.json) = "false" ]; then
        echo "DROPBEAR_EXTRA_ARGS=" -w -g"" > /etc/default/dropbear
        echo "Disabled SSH access."
elif [ $(jq -r .enableSSH /media/RECOVERY/system/recovery-settings.json) = "true" ]; then
        echo "DROPBEAR_EXTRA_ARGS=" -B"" > /etc/default/dropbear
        echo "Enabled SSH access."
fi

if [ $(jq -r .performUpdate /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
        if [ -f "$(jq -r .updateFile /media/RECOVERY/system/recovery-settings.json)" ]; then
                echo "Update available. Updating..."

                # Check if update file is empty
                if [ ! -s "$(jq -r .updateFile /media/RECOVERY/system/recovery-settings.json)" ]; then
                        echo "Update file empty. Aborting."
                        cp /var/log/usb-mount.log /media/RECOVERY/system/
                        umount /media/RECOVERY
                        exit 0
                fi

                # Do the actual update and check if it was successful
                mender install $(jq -r .updateFile /media/RECOVERY/system/recovery-settings.json)
                if [ ! $(echo $?) -eq 0 ]; then
                        echo "Update failed. Aborting."
                        cp /var/log/usb-mount.log /media/RECOVERY/system/
                        umount /media/RECOVERY
                        exit 0
                fi
                mender commit
                if [ ! $(echo $?) -eq 0 ]; then
                        echo "Commiting update failed. Aborting."
                        cp /var/log/usb-mount.log /media/RECOVERY/system/
                        umount /media/RECOVERY
                        exit 0
                fi
                echo "Update done."

                # Reboot, if required 
                if [ $(jq -r .autoReboot /media/RECOVERY/system/recovery-settings.json) = "yes" ]; then
                        echo "Rebooting..."
                        cp /var/log/usb-mount.log /media/RECOVERY/system/
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
cp /var/log/usb-mount.log /media/RECOVERY/system/
umount /media/RECOVERY
exit 0
