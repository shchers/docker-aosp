#!/bin/bash
#
# Test script file that maps itself into a docker container and runs
#
# Example invocation:
#
# $ AOSP_VOL=$PWD/build ./build.sh
#
set -ex

if [ "$1" = "docker" ]; then
    TEST_BRANCH=${TEST_BRANCH:-nanopi-k2-lollipop}
    TEST_URL=${TEST_URL:-https://github.com/friendlyarm/android_manifest}

    repo init --depth 1 -u "$TEST_URL" -b "$TEST_BRANCH"
    #rm -rf .repo/local_manifests
    #git clone https://github.com/ayufan-rock64/android-manifests -b nougat-7.1 .repo/local_manifests

    # Use default sync '-j' value embedded in manifest file to be polite
    repo sync -j $(($(nproc)*2)) -c --force-sync

    export CCACHE_DIR=$PWD/ccache
    export USE_CCACHE=true
    prebuilts/misc/linux-x86/ccache/ccache -M 50G

    # Remove output folder
    rm -rf rockdev

    # Trics for Android build system
    export ANDROID_JACK_VM_ARGS="-Xmx6g -Dfile.encoding=UTF-8 -XX:+TieredCompilation"
    export ANDROID_NO_TEST_CHECK="true"

    source build/envsetup.sh
    lunch ${VARIANT:-nanopi_k2-userdebug}
    make -j $(nproc)

else
    aosp_url="https://raw.githubusercontent.com/kylemanna/docker-aosp/master/utils/aosp"
    args="bash run.sh docker"
    export AOSP_EXTRA_ARGS="-v $(cd $(dirname $0) && pwd -P)/$(basename $0):/usr/local/bin/run.sh:ro"
    #export AOSP_IMAGE="kylemanna/aosp:7.0-nougat"
    export AOSP_IMAGE="shchers/docker-aosp:rock64-nougat-7.1"

    # Fetch latest image
    docker pull $AOSP_IMAGE

    #
    # Try to invoke the aosp wrapper with the following priority:
    #
    # 1. If AOSP_BIN is set, use that
    # 2. If aosp is found in the shell $PATH
    # 3. Grab it from the web
    #
    if [ -n "$AOSP_BIN" ]; then
        $AOSP_BIN $args
    elif [ -x "../utils/aosp" ]; then
        ../utils/aosp $args
    elif [ -n "$(type -P aosp)" ]; then
        aosp $args
    else
        if [ -n "$(type -P curl)" ]; then
            bash <(curl -s $aosp_url) $args
        elif [ -n "$(type -P wget)" ]; then
            bash <(wget -q $aosp_url -O -) $args
        else
            echo "Unable to run the aosp binary"
        fi
    fi
fi
