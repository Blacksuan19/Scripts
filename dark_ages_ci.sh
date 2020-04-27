#!/usr/bin/env bash
# Copyright (C) 2020 Abubakar Yagoub (Blacksuan19)

BOT=$BOT_API_KEY
KERN_IMG=$PWD/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$HOME/Zipper
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
COMMIT=$(git log --pretty=format:'"%h : %s"' -1)
THREAD=-j$(nproc --all)
DEVICE=$1
[ -z "$DEVICE" ] && DEVICE="vince" # if no device specified use vince

if [[ "$DEVICE" == "vince" ]]; then
    CHAT_ID="-1001348786090"
    CONFIG=vince_defconfig
    [ -d $HOME/toolchains/aarch64 ] || git clone https://github.com/kdrag0n/aarch64-elf-gcc.git $HOME/toolchains/aarch64
    [ -d $HOME/toolchains/aarch32 ] || git clone https://github.com/kdrag0n/arm-eabi-gcc.git $HOME/toolchains/aarch32
elif [[ "$DEVICE" == "phoenix" ]]; then
    CHAT_ID="" # TODO: make phoenix ci channel
    CONFIG=phoenix_defconfig
    [ -d $HOME/toolchains/clang ] || git clone https://github.com/kdrag0n/proton-clang.git --depth 1 $HOME/toolchains/clang
fi

# upload to channel
function tg_pushzip() {
	JIP=$ZIP_DIR/$ZIP
	MD5=$ZIP_DIR/$ZIP.sha1
	curl -F document=@"$JIP"  "https://api.telegram.org/bot$BOT/sendDocument" \
			-F chat_id=$CHAT_ID

	curl -F document=@"$MD5"  "https://api.telegram.org/bot$BOT/sendDocument" \
			-F chat_id=$CHAT_ID
}

# sed text message
function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$BOT/sendMessage" \
		-d "parse_mode=html" \
		-d text="${1}" \
		-d chat_id="@da_ci" \
		-d "disable_web_page_preview=true"
}

# Send sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT/sendSticker" \
		-d sticker="CAADAQADRQADS3HZGKLNCg7b540CAg" \
		-d chat_id="-1001348786090" >> /dev/null
}

# finished without errors
function tg_finished() {
	tg_sendinfo "$(echo "Build Finished in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.")"
}

# finished with error
function tg_error() {
	tg_sendinfo "Reep build Failed, Check log for more Info"
	exit 1
}

# send build details
function tg_sendbuildinfo() {
    if [ $BRANCH == "darky" ]; then
        tg_sendinfo "<b>New Kernel Build for $DEVICE</b>
	    Started on: <b>$KBUILD_BUILD_HOST</b>
	    Branch: <b>$BRANCH</b>
        Commit: <b>$COMMIT</b>
	    Date: <b>$(date)</b>"

    else
        tg_sendinfo "<b>New Beta Kernel Build for $DEVICE</b>
	    Started on: <b>$KBUILD_BUILD_HOST</b>
	    Branch: <b>$BRANCH</b>
        Commit: <b>$COMMIT</b>
	    Date: <b>$(date)</b>"

fi
}

# build the kernel
function build_kern() {
    DATE=`date`
    BUILD_START=$(date +"%s")

    # cleaup first
    make clean && make mrproper

    # building
    make O=out $CONFIG $THREAD
    # use gcc for vince and clang for phoenix
    if [[ "$DEVICE" == "vince" ]]; then
        make O=out $THREAD
    else
        export PATH="$HOME/toolchains/clang/bin:$PATH"
        make $THREAD O=out \
                    CC=clang \
                    CROSS_COMPILE=aarch64-linux-gnu- \
                    CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    fi
    
    BUILD_END=$(date +"%s")
    DIFF=$(($BUILD_END - $BUILD_START))
    
    if ! [ -a $KERN_IMG ]; then
    	tg_error
    	exit 1
    fi
}

# make flashable zip
function make_flashable() {
    cd $ZIP_DIR
    if [[ "$DEVICE" == "vince" ]]; then
        git checkout vince
    elif [[ "$DEVICE" == "phoenix" ]]; then
        git checkout phoenix
    fi
    make clean &>/dev/null
    cp $KERN_IMG $ZIP_DIR/zImage
    if [ $BRANCH == "darky" ]; then
        make stable &>/dev/null
    elif [ $BRANCH == "darky-3.18" ]; then
        git checkout 3.18
        make stable &>/dev/null
    else
        make beta &>/dev/null
    fi
    echo "Flashable zip generated under $ZIP_DIR."
    ZIP=$(ls | grep *.zip | grep -v *.sha1)
    tg_pushzip
    cd - 
    tg_finished
}

# Export
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Blacksuan19"
export KBUILD_BUILD_HOST="Dark-Castle"
export CROSS_COMPILE="$HOME/toolchains/aarch64/bin/aarch64-elf-"
export CROSS_COMPILE_ARM32="$HOME/toolchains/aarch32/bin/arm-eabi-"
export LINUX_VERSION=$(awk '/SUBLEVEL/ {print $3}' Makefile \
    | head -1 | sed 's/[^0-9]*//g')

# Clone AnyKernel3
[ -d $HOME/Zipper ] || git clone https://github.com/Blacksuan19/AnyKernel3 $HOME/Zipper

# send nudes to telegram
tg_sendstick
tg_sendbuildinfo

# Build start
build_kern

# make zip
make_flashable
