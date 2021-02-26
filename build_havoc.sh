#!/usr/bin/env bash

# clone device trees and needed things to build havoc

function clone(){
    git clone https://github.com/$1 $2 $3
}

# initiate the manifest
repo init -u https://github.com/Havoc-OS/android_manifest.git -b ten

# sync
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags


# device trees and vendor
clone "Blacksuan19/android_device_xiaomi_phoenix" "device/xiaomi/phoenix"
clone "Blacksuan19/android_device_xiaomi_sm6150-common" "device/xiaomi/sm6150-common"
clone "Blacksuan19/vendor_xiaomi" "vendor/xiaomi"

# kernel
clone "crdroidandroid/android_kernel_xiaomi_sm6150" "kernel/xiaomi/sm6150"

# xiaomi hardware
clone "crdroidandroid/android_hardware_xiaomi" "hardware/xiaomi"
rm -rf hardware/xiaomi/org.ifaa.android.manager

# ANX camera
clone "sarveshrulz/android_vendor_aeonax_anxcamera" "vendor/aeonax/ANXCamera"

# face unlock
clone "Havoc-OS/android_external_motorola_faceunlock" "external/motorola/faceunlock"
bash external/motorola/faceunlock/regenerate/regenerate.sh

# custom havoc settings (for 120hz strings)
cd packages/apps/Settings
git fetch https://github.com/Blacksuan19/android_packages_apps_Settings
git cherry-pick 1a4f15ea4f4ceef8a44af99282589e12b8576705

# always build with gapps first
export WITH_GAPPS=true && export TARGET_GAPPS_ARCH=arm64

# build rom
cd -
. build/envsetup.sh
brunch phoenix
