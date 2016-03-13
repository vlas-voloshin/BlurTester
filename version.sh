#!/bin/bash

set -o errexit
set -o nounset

export LC_ALL="en_US.UTF-8"

appBuild=$(command git rev-list HEAD --count)

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $appBuild" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
