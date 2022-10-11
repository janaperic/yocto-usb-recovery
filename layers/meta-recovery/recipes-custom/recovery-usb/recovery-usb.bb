DESCRIPTION = "Recovery USB module"
LICENSE="GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR = "r7"

SRC_URI = "file://recover.sh \
           file://usb-mount.service \
           file://recovery-key.txt \
           "

do_install() {
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/usb-mount.service ${D}${systemd_unitdir}/system/

    install -d ${D}${bindir}
    install -m 0750 ${WORKDIR}/recover.sh  ${D}${bindir}/recover

    install -d ${D}${base_prefix}/opt/keys/
    install -m 0644 ${WORKDIR}/recovery-key.txt ${D}${base_prefix}/opt/keys/
}

FILES_${PN} += "\
    ${bindir}/recover \
    ${systemd_unitdir}/system/usb-mount.service \
    /opt/keys/recovery-key.txt \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "usb-mount.service"
