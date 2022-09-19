FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " file://99-recovery-usb.rules"


do_install_append () {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/99-recovery-usb.rules ${D}${sysconfdir}/udev/rules.d/99-recovery-usb.rules
}