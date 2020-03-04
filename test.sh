#!/bin/bash

set -e

RPMDIR=$1

if [ -z "$RPMDIR" ]; then
        echo "Usage:"
        echo "  $./test.sh <rpm dir>"
	echo
	echo "Example:"
        echo "  $./test.sh rpms/"
        exit 1
fi

scp -F ssh/config ${RPMDIR}/*.rpm vm:~
ssh -F ssh/config vm sudo dnf --assumeyes localinstall "*.rpm"
ssh -F ssh/config vm sudo systemctl start osbuild-composer
ssh -F ssh/config vm 'cd /usr/libexec/osbuild-composer ; for test in /usr/libexec/tests/osbuild-composer/*; do sudo $test; done'
