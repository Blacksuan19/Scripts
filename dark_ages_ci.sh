#!/usr/bin/env bash
# Copyright (C) 2020 Abubakar Yagoub (Blacksuan19)

BOT=$BOT_API_KEY
KERN_IMG=$PWD/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=/root/Zipper
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
THREAD=-j$(nproc --all)
DEVICE=$1
[ -z "$DEVICE" ] && DEVICE="vince" # if no device specified use vince

if [[ "$DEVICE" == "vince" ]]; then
    CHAT_ID="-1001348786090"
    CONFIG=vince_defconfig
    [ -d /root/toolchains/aarch64 ] || git clone https://github.com/kdrag0n/aarch64-elf-gcc.git /root/toolchains/aarch64
    [ -d /root/toolchains/aarch32 ] || git clone https://github.com/kdrag0n/arm-eabi-gcc.git /root/toolchains/aarch32
    ls /root/toolchains/aarch32/bin
elif [[ "$DEVICE" == "phoenix" ]]; then
    CHAT_ID="-1001233365676"
    CONFIG=vendor/lineage_phoenix_defconfig
    # git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 /root/toolchains/aarch64
    # git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 /root/toolchains/aarch32
    # wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r407598b.tar.gz
    # mv *.tar.gz /root/toolchains
    # mkdir /root/toolchains/clang
    # tar xzf /root/toolchains/*.tar.gz -C /root/toolchains/clang
fi

# upload to channel
function tg_pushzip() {
	JIP=$ZIP_DIR/$ZIP
	curl -F document=@"$JIP"  "https://api.telegram.org/bot$BOT/sendDocument" \
        -F chat_id=$CHAT_ID -F caption="MD5: $(md5sum $ZIP_DIR/$ZIP | awk '{print $1}')"
}

# sed text message
function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$BOT/sendMessage" \
		-d "parse_mode=html" \
		-d text="${1}" \
		-d chat_id=$CHAT_ID \
		-d "disable_web_page_preview=true"
}

# Send sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT/sendSticker" \
		-d sticker="CAADAQADRQADS3HZGKLNCg7b540CAg" \
		-d chat_id=$CHAT_ID >> /dev/null
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
    generate_changelog

    tg_sendinfo "<b>New Kernel Build for $DEVICE</b>
    <b>Started on:</b> $KBUILD_BUILD_HOST
    <b>Branch:</b> $BRANCH
    <b>Changelog:</b> <a href='$CHANGE_URL'>Click Here</a>
    <b>Date:</b> $(date +%A\ %B\ %d\ %Y\ %H:%M:%S)"
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
        make O=out $THREAD \
                    CROSS_COMPILE="/root/toolchains/aarch64/bin/aarch64-elf-" \
                    CROSS_COMPILE_ARM32="/root/toolchains/aarch32/bin/arm-eabi-"
    else
        # export PATH="/root/toolchains/clang/bin:$PATH"
        make $THREAD O=out \
                    CC=clang \
                    LD=ld.lld \
                    CROSS_COMPILE=aarch64-linux-gnu- \
                    CROSS_COMPILE_ARM32=arm-linux-gnueabi-
                    # CROSS_COMPILE="/root/toolchains/aarch64/bin/aarch64-linux-android-" \
                    # CROSS_COMPILE_ARM32="/root/toolchains/aarch32/bin/arm-linux-androideabi-" \
                    # CLANG_TRIPLE=aarch64-linux-gnu-
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
    else
        make beta &>/dev/null
    fi
    echo "Flashable zip generated under $ZIP_DIR."
    ZIP=$(ls | grep *.zip)
    tg_pushzip
    cd -
    tg_finished
}

function generate_changelog() {
    # install drone CI
    wget --no-check-certificate https://github.com/drone/drone-cli/releases/download/v1.2.1/drone_linux_amd64.tar.gz
    tar -xzf drone_linux_amd64.tar.gz
    mv drone /bin

    # some magic
    current_build=$(drone build ls Blacksuan19/kernel_dark_ages_$DEVICE | awk '/Commit/{i++}i==1{print $2; exit}')
    last_build=$(drone build ls Blacksuan19/kernel_dark_ages_$DEVICE | awk '/Commit/{i++}i==2{print $2; exit}')
    log=$(git log --pretty=format:'- %s' $last_build".."$current_build)
    if [[ -z $log ]]; then
        log=$(git log --pretty=format:'- %s' $current_build)
    fi
    export CHANGE_URL=$(echo "$log" | curl -F 'clbin=<-' https://clbin.com)
}

# Export
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Blacksuan19"
export KBUILD_BUILD_HOST="Dark-Castle"
export LINUX_VERSION=$(awk '/SUBLEVEL/ {print $3}' Makefile \
    | head -1 | sed 's/[^0-9]*//g')

# Clone AnyKernel3
[ -d /root/Zipper ] || git clone https://github.com/Blacksuan19/AnyKernel3 /root/Zipper

# send nudes to telegram
tg_sendstick
tg_sendbuildinfo

# Build start
build_kern

# make zip
make_flashable
