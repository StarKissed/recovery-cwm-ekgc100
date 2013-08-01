#!/bin/sh

# Copyright (C) 2011 Twisted Playground

# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $2 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=TwistedZero
KERNELSPEC=/Volumes/android/ek-gc100_recovery
KERNELREPO=/Users/TwistedZero/Public/Dropbox/TwistedServer/Playground/kernels
#TOOLCHAIN_PREFIX=/Volumes/android/android-toolchain-eabi/bin/arm-eabi-
TOOLCHAIN_PREFIX=/Volumes/android/android-tzb_ics4.0.1/prebuilt/darwin-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-
MODULEOUT=$KERNELSPEC/buildimg/recovery.img-ramdisk
GOOSERVER=loungekatt@upload.goo.im:public_html
PUNCHCARD=`date "+%m-%d-%Y_%H.%M"`

CPU_JOB_NUM=8

if [ -e $KERNELSPEC/buildimg/recovery.img ]; then
rm -R $KERNELSPEC/buildimg/recovery.img
fi
if [ -e $KERNELSPEC/buildimg/newramdisk.cpio.gz ]; then
rm -R $KERNELSPEC/buildimg/newramdisk.cpio.gz
fi
if [ -e $KERNELSPEC/buildimg/zImage ]; then
rm -R $KERNELSPEC/buildimg/zImage
fi

make clean -j$CPU_JOB_NUM

make gc1pq_00_defconfig
make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

if [ -e arch/arm/boot/zImage ]; then

if [ `find . -name "*.ko" | grep -c ko` > 0 ]; then

find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

if [ ! -d $MODULEOUT ]; then
mkdir $MODULEOUT
fi
if [ ! -d $MODULEOUT/lib ]; then
mkdir $MODULEOUT/lib
fi
if [ ! -d $MODULEOUT/lib/modules ]; then
mkdir $MODULEOUT/lib/modules
else
rm -r $MODULEOUT/lib/modules
mkdir $MODULEOUT/lib/modules
fi

for j in $(find . -name "*.ko"); do
cp -R "${j}" $MODULEOUT/lib/modules
done

fi

cp -R arch/arm/boot/zImage buildimg

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

cp -r  output/recovery.img $KERNELREPO/gooserver/$IMAGEFILE
scp -P 2222 $KERNELREPO/gooserver/$IMAGEFILE $GOOSERVER/galaxycam

if cat /etc/issue | grep Ubuntu; then
    tar -H ustar -c output/recovery.img > output/recovery.tar
else
    gnutar -H ustar -c output/recovery.img > output/recovery.tar
fi
# Create an md5 kernel image
if [ "$1" == "1" ]; then
    KERNELFILE=$KERNELFILE.md5.gz
    cp -r output/recovery.tar output/recovery.tar.md5
    if cat /etc/issue | grep Ubuntu; then
        md5sum -r output/recovery.tar.md5 >> output/recovery.tar.md5
    else
        md5 -r output/recovery.tar.md5 >> output/recovery.tar.md5
    fi
    gzip output/recovery.tar.md5 -c -v > output/recovery.tar.md5.gz
    cp -r output/recovery.tar.md5.gz $KERNELREPO/recovery.tar.md5.gz
    cp -r $KERNELREPO/recovery.tar.md5.gz $KERNELREPO/gooserver/$KERNELFILE
# Skip md5 hash generation
else
    cp -r output/recovery.tar $KERNELREPO/recovery.tar
    cp -r $KERNELREPO/recovery.tar $KERNELREPO/gooserver/$KERNELFILE
fi
scp -P 2222 $KERNELREPO/gooserver/$KERNELFILE $GOOSERVER/galaxycam
rm -R $KERNELREPO/gooserver/$KERNELFILE

cd $KERNELSPEC
