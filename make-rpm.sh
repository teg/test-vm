#!/bin/bash

set -e

OUTPUTDIR=$1
ORG=$2
REPO=$3
COMMIT=$4
SPECFILE=$5
RELEASE=$6

OLDDIR=$PWD

if [ -z "$OUTPUTDIR" ] || [ -z "$ORG" ] || [ -z "$REPO" ] || [ -z "$COMMIT" ] || [ -z "$SPECFILE" ] || [ -z "$RELEASE" ]; then
        echo "Usage:"
        echo "  $./make-rpm.sh <output directory> <repo> <commit> <spec file> <release> <architecture>"
	echo
	echo "Example:"
        echo "  $./make-rpm.sh output/ ousbild osbuild-composer 0a4ce9dc6887ce9606b61d49127cbed4d076d966 golang-github-osbuild-composer.spec f31"
        exit 1
fi

OUTPUTDIR=$(realpath "${OUTPUTDIR}")

BUILDDIR=$(mktemp -d -t osbuild-rpm-XXXXXXXXXX)

#curl "https://codeload.github.com/osbuild/${REPO}/tar.gz/${COMMIT}" -o "${BUILDDIR}/${REPO}-${COMMIT}.tar.gz"
curl "https://raw.githubusercontent.com/${ORG}/${REPO}/${COMMIT}/${SPECFILE}" -o "${BUILDDIR}/${SPECFILE}.pre"
echo "%global commit ${COMMIT}" | cat - "${BUILDDIR}/${SPECFILE}.pre" > "${BUILDDIR}/${SPECFILE}"

cd "${BUILDDIR}"
spectool -g ${SPECFILE}
fedpkg --release "${RELEASE}" scratch-build --srpm | tee koji.log
TASKID=$(awk '/Created task:/ {print $3}' koji.log)

cd "${OUTPUTDIR}"
koji download-task "${TASKID}"

cd "${OLDDIR}"
rm -rf "${BUILDDIR}"
