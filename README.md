# meta-recovery

This layer represents a software module used for recovery & debugging via USB drive developed for Raspberry Pi 3 using Yocto Project and Mender. 

meta-recovery layer depends on following layers: meta-raspberrypi, meta-mender, poky and meta-openembedded;
Release branches used are: dunfell;

## Building
To build an image, use following command: 
`bitbake raspberry-recovery-image`

## Usage
Recovery USB can be used to force the update of the system, as well as copy required info from the system to the drive. The label of the drive has to be "RECOVERY" for it to work. On the drive, there should be a direcotry "system" with a file "recovery-settings.json". This file will be parsed in order to do the required operations. 

Implemented operations are: <br />
"getLogs" - copies kernel logs to the drive (yes/no) <br />
"listServices" - copies status of all systemd services running on the system (yes/no) <br />
"performUpdate" - decides wether updated should be performed (yes/no) <br />
"updateFile" - path to the update file (Mender artifact) (path) <br />
"autoReboot" - decides wether system should be automatically rebooted after update (yes/no) <br />
"disableSSH" - Disables dropbear SSH (yes/no) <br />
"enableSSH" - Enables dropbear SSH (yes/no) <br />


Example of recovery-settings.json
```
{
  "getLogs": "yes",
  "listServices": "yes",
  "performUpdate": "yes",
  "updateFile": "/media/RECOVERY/system/update.mender",
  "autoReboot": "yes",
  "disableSSH": "no",
  "enableSSH": "no"
}
```

