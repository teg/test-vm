#!/bin/bash

set -e

OUTPUTDIR=$(realpath "${1}")
REPO=$2
BRANCH=$3
SPECFILE=$4
RELEASE=$5
ARCH=$6

OLDDIR=$PWD

if [ -z "$OUTPUTDIR" ] || [ -z "$REPO" ] || [ -z "$BRANCH" ] || [ -z "$RELEASE" ] || [ -z "$ARCH" ]; then
        echo "Usage:"
        echo "  $./make-rpm.sh <output directory> <repo> <branch> <spec file> <release> <architecture>"
        exit 1
fi


BUILDDIR=$(mktemp -d -t osbuild-rpm-XXXXXXXXXX)

git clone --depth 1 --branch ${BRANCH} ${REPO} ${BUILDDIR}/checkout
cd ${BUILDDIR}/checkout
COMMIT=$(git rev-parse HEAD)

go mod vendor
git add vendor
git commit --all --message="go: add vendoring"
git archive --prefix="osbuild-composer-${COMMIT}/" --output="${BUILDDIR}/osbuild-composer-${COMMIT}.tar.gz" HEAD

# The (pre-)spec file must not contain the 'commit' variable, but may rely on us prepending it.
echo "%global commit ${COMMIT}
%global shortcommit     ${COMMIT:0:7}" | cat - "${BUILDDIR}/checkout/${SPECFILE}" > "${BUILDDIR}/${SPECFILE}"

cd "${BUILDDIR}"
rhpkg --release "${RELEASE}" scratch-build --srpm --arches "${ARCH}" | tee brew.log
TASKID=$(awk '/Created task:/ {print $3}' brew.log)

cd "${OUTPUTDIR}"
brew download-task "${TASKID}"

cd "${OLDDIR}"
rm -rf "${BUILDDIR}"
