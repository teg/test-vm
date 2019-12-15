#!/bin/bash

CLOUD_IMAGE=$1

if [ -z "$CLOUD_IMAGE" ]; then
	echo "Usage:"
	echo "	$./vm.sh image.img"
	exit 1
fi

genisoimage \
        -quiet \
	-input-charset utf-8 \
	-output cloudinit.iso \
	-volid cidata \
	-joliet \
	-rock \
	user-data meta-data

qemu-kvm \
	-m 1024 -snapshot \
	-cdrom cloudinit.iso \
	-net nic,model=virtio \
	-net user,hostfwd=tcp::2222-:22,hostfwd=tcp::9091-:9090 \
	-drive file=fat:mnt/,index=1 \
	$CLOUD_IMAGE
