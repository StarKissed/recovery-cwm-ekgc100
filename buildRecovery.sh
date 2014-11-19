#!/bin/sh

# Copyright (C) 2011 Twisted Playground

# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $1 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=TwistedZero
KERNELSPEC=$(pwd)
KERNELREPO=$DROPBOX_SERVER/TwistedServer/Playground/kernels
#TOOLCHAIN_PREFIX=/Volumes/android/android-toolchain-eabi-4.6/bin/arm-eabi-
TOOLCHAIN_PREFIX=/Volumes/android/android-tzb_ics4.0.1/prebuilt/darwin-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-
MODULEOUT=buildimg/recovery.img-ramdisk
GOOSERVER=loungekatt@upload.goo.im:public_html
PUNCHCARD=`date "+%m-%d-%Y_%H.%M"`

# CPU_JOB_NUM=`grep processor /proc/cpuinfo|wc -l`
CORES=`sysctl -a | grep machdep.cpu | grep core_count | awk '{print $2}'`
THREADS=`sysctl -a | grep machdep.cpu | grep thread_count | awk '{print $2}'`
CPU_JOB_NUM=$((($CORES * $THREADS) / 2))

if [ -e buildimg/recovery.img ]; then
rm -R buildimg/recovery.img
fi
if [ -e buildimg/newramdisk.cpio.gz ]; then
rm -R buildimg/newramdisk.cpio.gz
fi
#if [ -e buildimg/zImage ]; then
#rm -R buildimg/zImage
#fi

#make clean -j$CPU_JOB_NUM

#make gc1pq_00_defconfig
#make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

#if [ -e arch/arm/boot/zImage ]; then

#    if [ `find . -name "*.ko" | grep -c ko` > 0 ]; then

#        find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

#        if [ ! -d $MODULEOUT ]; then
#            mkdir $MODULEOUT
#        fi
#        if [ ! -d $MODULEOUT/lib ]; then
#            mkdir $MODULEOUT/lib
#        fi
#        if [ ! -d $MODULEOUT/lib/modules ]; then
#            mkdir $MODULEOUT/lib/modules
#        else
#            rm -r $MODULEOUT/lib/modules
#            mkdir $MODULEOUT/lib/modules
#        fi

#        for j in $(find . -name "*.ko"); do
#            cp -R "${j}" $MODULEOUT/lib/modules
#        done

#    fi

#    cp -R arch/arm/boot/zImage buildimg

    cd buildimg
    ./img.sh

    echo "building recovery package"
    cp -R recovery.img ../output
    cd ../

    if [ -e output/recovery.tar ]; then
        rm -R output/recovery.tar
    fi
    if [ -e output/recovery.tar ]; then
        rm -R output/recovery.tar.md5
    fi
    if [ -e output/recovery.tar ]; then
        rm -R output/recovery.tar.md5.gz
    fi

    IMAGEFILE=recovery.$PUNCHCARD.img
    KERNELFILE=recovery.$PUNCHCARD.tar

    cp -r  output/recovery.img $KERNELREPO/camera/recovery.img

    if cat /etc/issue | grep Ubuntu; then
        tar -H ustar -c output/recovery.img > output/recovery.tar
    else
        tar --format ustar -c output/recovery.img > output/recovery.tar
    fi
    cp -r output/recovery.tar $KERNELREPO/camera/recovery.tar
    cp -r output/recovery.tar output/recovery.tar.md5
    if cat /etc/issue | grep Ubuntu; then
        md5sum -t output/recovery.tar.md5 >> output/recovery.tar.md5
    else
        md5 -r output/recovery.tar.md5 >> output/recovery.tar.md5
    fi
    cp -r output/recovery.tar.md5 $KERNELREPO/camera/recovery.tar.md5

    cp -r  $KERNELREPO/camera/recovery.img ~/.goo/$IMAGEFILE
    scp ~/.goo/$IMAGEFILE $GOOSERVER/galaxycam/recovery
    rm -R ~/.goo/$IMAGEFILE
    cp -r $KERNELREPO/camera/recovery.tar ~/.goo/$KERNELFILE
    scp ~/.goo/$KERNELFILE $GOOSERVER/galaxycam/recovery
    rm -R ~/.goo/$KERNELFILE
    cp -r $KERNELREPO/camera/recovery.tar.md5 ~/.goo/$KERNELFILE.md5
    scp ~/.goo/$KERNELFILE.md5 $GOOSERVER/galaxycam/recovery
    rm -R ~/.goo/$KERNELFILE.md5
#fi

cd $KERNELSPEC
