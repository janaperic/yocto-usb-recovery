DESCRIPTION = "hello world  example"
LICENSE="GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PR = "r0"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI = "file://hello-world.c"

do_compile() {
	${CC} ${CFLAGS} ${LDFLAGS} ${WORKDIR}/hello-world.c -o hello-world
}

do_install() {
	install -m 0755 -d ${D}${bindir}
	install -m 0755 ${S}/hello-world ${D}${bindir}
}

