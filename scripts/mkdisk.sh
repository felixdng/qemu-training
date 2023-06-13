#!/bin/bash

# These variables are defined in the top-level Makefile.
# TOP_DIR,TARGET_DIR,ROOTFS_OUT,etc.


# check free loop device
DEV_LOOP=`losetup -f | awk -F " " '(NR == 1) {print $1}'`
if [ "${DEV_LOOP}" = "" ]; then
echo "Error: No free loop device."
exit 1
fi

# check object files
if [ "${LINUX_OBJ_IMAGE}" = "" ] || [ ! -f "${LINUX_OUT}/${LINUX_OBJ_IMAGE}" ]; then
echo "Error: No linux kernel image. (${LINUX_OUT}/${LINUX_OBJ_IMAGE})"
exit 1
fi

FLAG_DTBS=
if [ ! "${LINUX_OBJ_DTB_PATH}" = "" ]; then
FLAG_DTBS=`ls ${LINUX_OUT}/${LINUX_OBJ_DTB_PATH}/*.dtb | awk -F " " '(NR == 1) {print $1}'`
fi
if [ "${FLAG_DTBS}" = "" ]; then
echo "Info: No dtbs, will ignore it."
fi

FLAG_ROOTFS=
if [ -d "${ROOTFS_OUT}/_install" ]; then
FLAG_ROOTFS=`ls ${ROOTFS_OUT}/_install/* | awk -F " " '(NR == 1) {print $1}'`
fi
if [ "${FLAG_ROOTFS}" = "" ]; then
echo "Error: No rootfs files."
fi

# create disk
dd if=/dev/zero of=${TARGET_DIR}/uboot.disk bs=1024 count=64K
sgdisk -n 0:0:+4M  -c 0:uboot  ${TARGET_DIR}/uboot.disk
sgdisk -n 0:0:+16M -c 0:kernel ${TARGET_DIR}/uboot.disk
sgdisk -n 0:0:0    -c 0:rootfs ${TARGET_DIR}/uboot.disk
sgdisk -p ${TARGET_DIR}/uboot.disk

losetup ${DEV_LOOP} ${TARGET_DIR}/uboot.disk
partprobe ${DEV_LOOP}
mkfs.ext2 -F ${DEV_LOOP}p2
mkfs.ext2 -F ${DEV_LOOP}p3

# copy zImage dtb
rm -rf ${TARGET_DIR}/loop-p2
mkdir -p ${TARGET_DIR}/loop-p2
mount -t ext2 ${DEV_LOOP}p2 ${TARGET_DIR}/loop-p2
cp ${LINUX_OUT}/${LINUX_OBJ_IMAGE} ${TARGET_DIR}/loop-p2/
[ ! "${FLAG_DTBS}" = "" ] && cp ${LINUX_OUT}/${LINUX_OBJ_DTB_PATH}/*.dtb ${TARGET_DIR}/loop-p2/
umount ${TARGET_DIR}/loop-p2
rm -rf ${TARGET_DIR}/loop-p2

# copy rootfs
rm -rf ${TARGET_DIR}/loop-p3
mkdir -p ${TARGET_DIR}/loop-p3
mount -t ext2 ${DEV_LOOP}p3 ${TARGET_DIR}/loop-p3

tar -xp -f ${TOP_DIR}/rootfs/rootfs_base.tar.bz2 -C ${TARGET_DIR}/loop-p3/
if [ -d "${COMPILE_LIBS_DIR}" ]; then
	rm -rf ${TARGET_DIR}/loop-p3/lib/*
	cp -raf ${COMPILE_LIBS_DIR}/* ${TARGET_DIR}/loop-p3/lib/
	find ${TARGET_DIR}/loop-p3/lib/ -name "*.a" | xargs rm -f
	find ${TARGET_DIR}/loop-p3/lib/ -type f | xargs ${CROSS_COMPILE}strip
fi
cp -arf ${ROOTFS_OUT}/_install/* ${TARGET_DIR}/loop-p3/

umount ${TARGET_DIR}/loop-p3
rm -rf ${TARGET_DIR}/loop-p3

# final
losetup -d ${DEV_LOOP}

