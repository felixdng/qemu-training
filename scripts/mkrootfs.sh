#!/bin/bash

TOP_DIR=$(pwd)
BUILD_DIR=${TOP_DIR}/build
TARGET_DIR=${TOP_DIR}/target

ROOTFS_VER=busybox-1.27.0
ROOTFS_SRC=${TOP_DIR}/${ROOTFS_VER}
ROOTFS_OUT=${BUILD_DIR}/${ROOTFS_VER}

if [ -d ${TARGET_DIR}/rootfs ]; then
	umount ${TARGET_DIR}/rootfs
	rm -rf ${TARGET_DIR}/rootfs
fi
mkdir ${TARGET_DIR}/rootfs

if [ -f ${TARGET_DIR}/rootfs.ext3 ]; then
	rm -rf ${TARGET_DIR}/rootfs.ext3
fi
dd if=/dev/zero of=${TARGET_DIR}/rootfs.ext3 bs=1M count=32
mkfs.ext3 ${TARGET_DIR}/rootfs.ext3
mount -t ext3 ${TARGET_DIR}/rootfs.ext3 ${TARGET_DIR}/rootfs/ -o loop
cp -r ${TOP_DIR}/rootfs_base/* ${TARGET_DIR}/rootfs/
cp -r ${ROOTFS_OUT}/_install/* ${TARGET_DIR}/rootfs/

umount ${TARGET_DIR}/rootfs/
