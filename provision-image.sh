#!/bin/bash

set -e

OUTPUTDIR=$1
RELEASE=$2

if [ -z "$OUTPUTDIR" ] || [ -z "$RELEASE" ]; then
        echo "Usage:"
        echo "  $./provision-image.sh <output dir> <release>"
	echo
	echo "Example:"
        echo "  $./provision-image.sh images/ f31"
        exit 1
fi

OUTPUTDIR=$(realpath "${OUTPUTDIR}")
IMAGE="${RELEASE}.qcow2"

if [ "${RELEASE}" == "f31" ]; then
	URL="https://download.fedoraproject.org/pub/fedora/linux/releases/31/Cloud/x86_64/images/Fedora-Cloud-Base-31-1.9.x86_64.qcow2"
elif [ "${RELEASE}" == "f32" ]; then
	URL="https://download.fedoraproject.org/pub/fedora/linux/releases/32/Cloud/x86_64/images/Fedora-Cloud-Base-32-1.6.x86_64.qcow2"
else
	echo "Invalid release ${RELEASE}"
	exit 1
fi

mkdir -p "${OUTPUTDIR}"

curl -L "${URL}" -o "${OUTPUTDIR}/${IMAGE}.partial"
qemu-img resize "${OUTPUTDIR}/${IMAGE}.partial" 10G
genisoimage \
        -quiet \
	-input-charset utf-8 \
	-output cloudinit.iso \
	-volid cidata \
	-joliet \
	-rock \
	ci-provision
qemu-kvm \
	-m 2048 \
	-cpu host \
	-nographic \
	-cdrom cloudinit.iso \
	"${OUTPUTDIR}/${IMAGE}.partial"
mv "${OUTPUTDIR}/${IMAGE}.partial" "${OUTPUTDIR}/${IMAGE}"
