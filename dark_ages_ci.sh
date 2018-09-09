#!/usr/bin/env bash
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
#               2018 Rama Bondan Prakoso (rama982)
#               2018 Abubakar Yagoub (Blacksuan19)
# SPDX-License-Identifier: GPL-3.0-or-later


KERN_IMG=$PWD/out/arch/arm64/boot/Image.gz
DTB=$PWD/out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-e7-non-treble.dtb
DTB_T=$PWD/out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-e7-treble.dtb
ZIP_DIR=$PWD/Zipper
BOT_API_KEY=517042878:AAEOC6q3ZYcwQr8p8Z-dsd7tE-SyAx0OdbY


# Push to Channel
function push() {
    JIP=$ZIP_DIR/$ZIP
    curl -F document=@"$JIP"  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
     -F chat_id="-1001348786090"
}

# Send the info up
function tg_sendinfo() {
    curl -s "https://api.telegram.org/bot$BOT_API_KEY/sendMessage" \
         -d "parse_mode=markdown" \
         -d text="${1}" \
         -d chat_id="@da_ci" \
         -d "disable_web_page_preview=true"
}

# Failed
function Errored() {
    tg_sendinfo "$(echo -e "Reep Build Failed, So Sad, Alexa Play Despacito...")"
    exit 1
}

# Send Starting sticker
function tg_sendstick_start() {
    curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
         -d sticker="CAADBAADBwEAAmuuXgm32BqzJKDKhwI" \
         -d chat_id="-1001348786090" >> /dev/null
}


# announce completion
function fin() {
    tg_sendinfo "$(echo "YUS!! IT COMPILES!!")"
    tg_sendinfo "$(echo "Compiled Successfully, took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.")"
}


git clone https://github.com/Blacksuan19/Toolchains -b opt-gnu-8.x toolchains/Toolchains
sudo apt install bc
Branch="$(git rev-parse --abbrev-ref HEAD)"
Commit="$(git log --pretty=format:'%h : %s' -1)"

# First-post works
DATE=`date`
BUILD_START=$(date +"%s")
tg_sendinfo "Lets Get This Party started!!"
tg_sendstick_start
tg_sendinfo "I'll now Compile with Dark Engine at $Commit in $Branch"

export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Blacksuan19"
export KBUILD_BUILD_HOST="Dark-Castle"
CONFIG=vince_defconfig
THREAD="-j8"
export CROSS_COMPILE="$PWD/toolchains/Toolchains/bin/aarch64-opt-linux-android-"
make  O=out $CONFIG $THREAD
make  O=out $THREAD

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))

if ! [ -a $KERN_IMG ]; then
    Errored
    exit 1
else
    cd $ZIP_DIR
    make clean &>/dev/null
    cp $KERN_IMG $ZIP_DIR/kernel/Image.gz
    cp $DTB_T $ZIP_DIR/kernel/treble/msm8953-qrd-sku3-e7-treble.dtb
    cp $DTB $ZIP_DIR/kernel/normal/msm8953-qrd-sku3-e7-non-treble.dtb
    NAME=Dark-Ages
    DATE=$(date "+%d%m%Y-%I%M")
    CODE=Tercero-Mix
    if [[ "$Branch" == "darky-oc" ]]; then
        make oc &>/dev/null
        ZIP=${NAME}-${CODE}-OC-${DATE}.zip
    fi
    if [[ "$Branch" != "darky-oc" ]]; then
        make normal &>/dev/null
        ZIP=${NAME}-${CODE}-${DATE}.zip
    fi
    cd ..
    push
    fin
fi


