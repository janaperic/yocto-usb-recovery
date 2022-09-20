# meta-recovery

This layer represents a software module used for recovery & debugging via USB drive developed for Raspberry Pi 3 using Yocto Project and Mender. 

meta-recovery layer depends on following layers: meta-raspberrypi, meta-mender, poky and meta-openembedded;
Release branches used are: dunfell;

## Building
To build an image, use following command: 
`bitbake raspberry-recovery-image`
