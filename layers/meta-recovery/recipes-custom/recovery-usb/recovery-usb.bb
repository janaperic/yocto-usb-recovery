DESCRIPTION = "Recovery USB module"
LICENSE="GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://recover.sh \
           file://usb-mount.service"

PR = "r2"

do_install() {
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/usb-mount.service ${D}${systemd_unitdir}/system/
    install -d ${D}${bindir}
    install -m 0750 ${WORKDIR}/recover.sh  ${D}${bindir}/recover
}

FILES_{PN} += "\
    ${bindir}/recover \
    ${systemd_unitdir}/system/usb-mount.service \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "usb-mount.service"
