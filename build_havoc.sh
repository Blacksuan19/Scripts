#!/usr/bin/env bash

# clone device trees and needed things to build havoc

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
clone "crdroidandroid/android_hardware_xiaomi" "hardware/xiaomi"
rm -rf hardware/xiaomi/org.ifaa.android.manager

# ANX camera
clone "sarveshrulz/android_vendor_aeonax_anxcamera" "vendor/aeonax/ANXCamera" "-b mmaster"

# face unlock
clone "Havoc-OS/android_external_motorola_faceunlock" "external/motorola/faceunlock"
bash external/motorola/faceunlock/regenerate/regenerate.sh

# build rom
. build/envsetup.sh
brunch phoenix
