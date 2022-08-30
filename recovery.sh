#!/bin/sh

if [[ $(blkid | grep KINGSTON | wc -c) -ne 0 ]]; then
        usb=$(blkid | grep KINGSTON)
        usb=${usb%%\:*}
        echo "Recovery USB detected at $usb location."
        if [ ! -d "/media/RECOVERY" ]; then
                echo "Creating /media/RECOVERY dir"
                mkdir /media/RECOVERY
        fi
        mount $usb /media/RECOVERY
        echo "Recovery USB mounted."
else
        echo "Recovery USB not detected."
fi