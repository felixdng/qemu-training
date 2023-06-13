#!/bin/bash

# These variables are defined in the top-level Makefile.
# TOP_DIR,TARGET_DIR,ROOTFS_OUT,etc.

# check rootfs object directory
if [ ! -d "${ROOTFS_OUT}/${ROOTFS_OBJ_PATH}" ]; then
echo "Error: No rootfs object directory."
exit 1
fi

if [ -d "${TARGET_DIR}/rootfs" ]; then
	umount ${TARGET_DIR}/rootfs
	rm -rf ${TARGET_DIR}/rootfs
fi
mkdir ${TARGET_DIR}/rootfs

if [ -f "${TARGET_DIR}/rootfs.ext3" ]; then
	rm -rf ${TARGET_DIR}/rootfs.ext3
fi
dd if=/dev/zero of=${TARGET_DIR}/rootfs.ext3 bs=1M count=32
mkfs.ext3 -F ${TARGET_DIR}/rootfs.ext3
mount -t ext3 ${TARGET_DIR}/rootfs.ext3 ${TARGET_DIR}/rootfs/ -o loop
tar -xp -f ${TOP_DIR}/rootfs/rootfs_base.tar.bz2 -C ${TARGET_DIR}/rootfs/
if [ -d "${COMPILE_LIBS_DIR}" ]; then
	rm -rf ${TARGET_DIR}/rootfs/lib/*
	cp -raf ${COMPILE_LIBS_DIR}/* ${TARGET_DIR}/rootfs/lib/
	find ${TARGET_DIR}/rootfs/lib/ -name "*.a" | xargs rm -f
	find ${TARGET_DIR}/rootfs/lib/ -type f | xargs ${CROSS_COMPILE}strip
fi
cp -arf ${ROOTFS_OUT}/${ROOTFS_OBJ_PATH}/* ${TARGET_DIR}/rootfs/

umount ${TARGET_DIR}/rootfs
rm -rf ${TARGET_DIR}/rootfs

