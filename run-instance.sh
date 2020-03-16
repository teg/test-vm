#!/bin/bash

set -e

CLOUD_IMAGE=$1

if [ -z "$CLOUD_IMAGE" ]; then
	echo "Usage:"
	echo "	$./run-instance.sh image.img"
	exit 1
fi

genisoimage \
        -quiet \
	-input-charset utf-8 \
	-output cloudinit.iso \
	-volid cidata \
	-joliet \
	-rock \
	ci-snapshot

qemu-kvm \
  -nographic \
	-m 2048 -snapshot \
	-cdrom cloudinit.iso \
	-net nic,model=virtio \
	-net user,hostfwd=tcp::2222-:22 \
	$CLOUD_IMAGE
