# meta-recovery

This layer represents a software module used for recovery & debugging via USB drive developed for Raspberry Pi 3 using Yocto Project and Mender. 

meta-recovery layer depends on following layers: meta-raspberrypi, meta-mender, poky and meta-openembedded;
Release branches used are: dunfell;

## Building
To build an image, use following command: 
`bitbake raspberry-recovery-image`

## Usage
Recovery USB can be used to force the update of the system, as well as copy required info from the system to the drive. The label of the drive has to be "RECOVERY" for it to work. On the drive, there should be a direcotry "system" with a file "recovery-settings.json". This file will be parsed in order to do the required operations.  After defining necessary operations on the drive, user should plug in the drive to the running Raspberry Pi, and wait for them to be performed. There won't be a definite way of knowing if all required operations have been executed before plugging out the drive. For operations such as copying the logs, only few seconds are necessary to finish; but for the update it will take around 5 minutes. When performing the update, it's advised to use the flag "autoReboot", which will reboot the Raspberry Pi as soon as the update is done (that way user can be sure update has been completed, and it is safe to remove the drive).
Once the drive is removed, it should contain a file system/usb-mount.log which will include output of all operations that have been performed via the drive. This way user can now if those operations were successful or failed.

Implemented operations are: <br />
"getLogs" - copies kernel logs to the drive (yes/no) <br />
"listServices" - copies status of all systemd services running on the system (yes/no) <br />
"performUpdate" - decides wether updated should be performed (yes/no) <br />
"updateFile" - path to the update file (Mender artifact) (path) <br />
"autoReboot" - decides wether system should be automatically rebooted after update (yes/no) <br />
"enableSSH" - Enables dropbear SSH (true/false) <br />


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
## Security
To make the system more secure, instead of using plain json file for recovery-settings.json, system will expect signed file - recovery-settings.json.signed. To sign the file, use the private key (private.pem) from this folder, and sign it via following command: <br />
`openssl rsautl -sign -inkey /path/to/private.pem -out recovery-settings.json.signed -in recovery-settings.json`

OpenSSL will now require to type in the key password.
After signing the file, copy recovery-settings.json.signed to the USB drive, in the system/ direcotry.

#### NOTE! Recovery won't work if recovery-settings.json is present at the time of inserting the drive. Please make sure to remove recovery-settings.json if it was generated during previous usage. 
