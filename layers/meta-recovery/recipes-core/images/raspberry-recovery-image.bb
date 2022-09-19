# Base this image on core-image-minimal
include recipes-core/images/core-image-minimal.bb

DESCRIPTION = "Recovery image for Raspberry Pi"
IMAGE_FEATURES += " \
    ssh-server-dropbear \
    splash \
"

# Include modules in rootfs
IMAGE_INSTALL += " \
    kernel-modules \
    sudo \
    avahi-daemon \
    jq \
"