#!/usr/bin/env bash

# clone device trees and needed things to build

function clone(){
    git clone https://github.com/$1 $2 $3
}

# device trees and vendor
clone "Blacksuan19/android_device_xiaomi_phoenix" "device/xiaomi/phoenix"
clone "Blacksuan19/android_device_xiaomi_sm6150-common" "device/xiaomi/sm6150-common"
clone "Blacksuan19/vendor_xiaomi" "vendor/xiaomi"

# kernel
clone "crdroidandroid/android_kernel_xiaomi_sm6150" "kernel/xiaomi/sm6150"

# xiaomi hardware
clone "Blacksuan19/android_hardware_xiaomi" "hardware/xiaomi"

# ANX camera
clone "sarveshrulz/android_vendor_aeonax_anxcamera" "vendor/aeonax/ANXCamera"

# face unlock
clone "Havoc-OS/android_external_motorola_faceunlock" "external/motorola/faceunlock"
bash external/motorola/faceunlock/regenerate/regenerate.sh

# always build with gapps first
export WITH_GAPPS=true && export TARGET_GAPPS_ARCH=arm64

# build rom
cd -
. build/envsetup.sh
brunch phoenix
