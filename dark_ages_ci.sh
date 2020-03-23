#!/usr/bin/env bash
# Copyright (C) 2018 Abubakar Yagoub (Blacksuan19)


BOT_API_KEY=
KERN_IMG=$PWD/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$PWD/Zipper
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
CONFIG=vince_defconfig
THREAD="-j8"

# Push kernel installer to channel

function push() {
	JIP=$ZIP_DIR/$ZIP
	MD5=$ZIP_DIR/$ZIP.sha1
	curl -F document=@"$JIP"  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
			-F chat_id="-1001348786090"

	curl -F document=@"$MD5"  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
			-F chat_id="-1001348786090"
}

function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$BOT_API_KEY/sendMessage" \
		-d "parse_mode=html" \
		-d text="${1}" \
		-d chat_id="@da_ci" \
		-d "disable_web_page_preview=true"
}

# Errored prober
function finerr() {
	tg_sendinfo "$(echo -e "Reep build Failed, Check log for more Info")"
	exit 1
}

# Send sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
		-d sticker="CAADAQADRQADS3HZGKLNCg7b540CAg" \
		-d chat_id="-1001348786090" >> /dev/null
}

# Fin prober

function fin() {
	tg_sendinfo "$(echo "Build Finished in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.")"
}

# Export
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Blacksuan19"
export KBUILD_BUILD_HOST="Dark-Castle"
export CROSS_COMPILE="$PWD/toolchains/aarch64/bin/aarch64-elf-"
export CROSS_COMPILE_ARM32="$PWD/toolchains/aarch32/bin/arm-eabi-"
export CC=$PWD/toolchains/clang/bin/clang
export KBUILD_COMPILER_STRING=$($CC --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

# Install build package

sudo apt install bc

# Clone toolchains
git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-5657785.git toolchains/clang
git clone https://github.com/kdrag0n/aarch64-elf-gcc toolchains/aarch64
git clone https://github.com/arter97/arm-eabi-5.1.git toolchains/aarch32

# Clone AnyKernel2
git clone https://github.com/Blacksuan19/AnyKernel2 $PWD/Zipper

# Build start
DATE=`date`
BUILD_START=$(date +"%s")

tg_sendstick

if [ $BRANCH == "darky" ]; then
tg_sendinfo "<b>Dark Ages Kernel</b> new build!
	Started on: <b>$KBUILD_BUILD_HOST</b>
	Branch: <b>$BRANCH</b>
	commit <b>$(git log --pretty=format:'"%h : %s"' -1)</b>
	Date: <b>$(date)</b>"

elif [ $BRANCH == "darky-3.18" ]; then
tg_sendinfo "<b>Dark Ages Kernel 3.18 </b> new build!
	Started on: <b>$KBUILD_BUILD_HOST</b>
	Branch: <b>$BRANCH</b>
	commit <b>$(git log --pretty=format:'"%h : %s"' -1)</b>
	Date: <b>$(date)</b>"
else
tg_sendinfo "<b>Dark Ages Kernel</b> new <b>Beta</b> build!
	Started on: <b>$KBUILD_BUILD_HOST</b>
	Branch: <b>$BRANCH</b>
	commit <b>$(git log --pretty=format:'"%h : %s"' -1)</b>
	Date: <b>$(date)</b>"
fi

# building
make O=out $CONFIG

if [[ $BRANCH == "clang" ]]; then
    make $THREAD O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=aarch64-elf-

else
    make O=out $THREAD
fi

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))

if ! [ -a $KERN_IMG ]; then
	finerr
	exit 1
fi

cd $ZIP_DIR
make clean &>/dev/null
cp $KERN_IMG $ZIP_DIR/zImage
NAME=Dark-Ages
DATE=$(date "+%d%m%Y-%I%M")
CODE=Décimo
VERSION=4.9-$(awk '/SUBLEVEL/ {print $3}' /home/runner/android_kernel_dark_ages/Makefile | head -1 | sed 's/[^0-9]*//g')
if [ $BRANCH == "darky" ]; then
ZIP=${NAME}-${CODE}-${VERSION}-STABLE-${DATE}.zip
make stable &>/dev/null
elif [ $BRANCH == "darky-3.18" ]; then
git checkout 3.18
CODE=Septimo
VERSION=3.18
ZIP=${NAME}-${CODE}-${VERSION}-STABLE-${DATE}.zip
make stable &>/dev/null
else
ZIP=${NAME}-${CODE}-${VERSION}-BETA-${DATE}.zip
make beta &>/dev/null
fi
echo "Flashable zip generated under $ZIP_DIR."
push
cd ..
fin
# Build end
