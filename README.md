# Integration Test Scripts

This project contains a collection of shell scripts to do a manual integration test suite run of the type used in the the [osbuild projects](https://www.osbuild.org/).

The integration tests are expected to be shipped in RPMs, and once installed the binaries in `/usr/libexec/tests/*/*` are executed in order. A return code of 0 means the test passed, anything else indicates failure.

## Provisioning

An OS image of the target operating system should be provisioned and reused between test runs. The image should only be reprovisioned once the new version has been verified to pass the test suite. The reason for this is to ensure that it is known whether the OS or the software caused a given test failure.

The `provision-image.sh` supports reprovisioning a set of supported operating systems.

## Instantiation

A snapshot is taken of the target OS image and booted for each test run. This should never be reused between test-runs, to avoid preserving state, and a fresh snapshot sholud be taken on every boot.

The `run-instance.sh` script boots a pristine instance, ready to be used for testing.

## Testing

The actual testing is performed by copying a set of RPMs into the running instance, installing them, and running all integration tests suites.

The `test.sh` script performs this task.
