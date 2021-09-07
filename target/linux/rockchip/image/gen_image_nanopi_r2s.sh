#!/bin/sh

OUTPUT="$1"
KERNELSIZE="$2"
KERNELDIR="$3"
ROOTFSSIZE="$4"
ROOTFSIMAGE="$5"
UBOOT_STAGING_PREFIX="$6"

rm -f "$OUTPUT"

# create partition table
head=16
sect=63
ptgen -o "$OUTPUT" -h $head -s $sect -g -p "17m"


TPLSPLOFFSET=64 		# sector 0x0040, 32 kB
UBOOTOFFSET=2048		# sector 0x0800, 1  MB
KERNELOFFSET=4096		# sector 0x1000, 2  MB
ROOTFSOFFSET="$(($KERNELOFFSET + ($KERNELSIZE * 2048) ))"
DTBOFFSET="$(($ROOTFSOFFSET - 512))"

dd if="${UBOOT_STAGING_PREFIX}-idbloader.img" of="$OUTPUT" seek="$TPLSPLOFFSET" conv=notrunc

dd if="${UBOOT_STAGING_PREFIX}-u-boot.itb" of="$OUTPUT" seek="$UBOOTOFFSET" conv=notrunc

dd if=/dev/zero of="$OUTPUT" bs=1M seek=2 count=14

lzma e $KERNELDIR/kernel.img $KERNELDIR/kernel.lzma
dd if="$KERNELDIR/kernel.lzma" of="$OUTPUT" bs=512 seek="$KERNELOFFSET" conv=notrunc

dd if="$KERNELDIR/rockchip.dtb" of="$OUTPUT" bs=512 seek="$DTBOFFSET" conv=notrunc

dd if="$ROOTFSIMAGE" of="$OUTPUT" bs=512 seek="$ROOTFSOFFSET" conv=notrunc

ls -l "$OUTPUT"
