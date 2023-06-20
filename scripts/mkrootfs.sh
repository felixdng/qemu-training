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
dd if=/dev/zero of=${TARGET_DIR}/rootfs.ext3 bs=1K count=64K
mkfs.ext3 -F ${TARGET_DIR}/rootfs.ext3
mount -t ext3 ${TARGET_DIR}/rootfs.ext3 ${TARGET_DIR}/rootfs/ -o loop
tar -xp -f ${TOP_DIR}/rootfs/rootfs_base.tar.bz2 -C ${TARGET_DIR}/rootfs/
if [ -d "${COMPILE_LIBS_DIR}" ]; then
	rm -rf /tmp/__tmp_lib
	mkdir /tmp/__tmp_lib
	cp -raf ${COMPILE_LIBS_DIR}/* /tmp/__tmp_lib/
	find /tmp/__tmp_lib/ -name "*.a" | xargs rm -f
	find /tmp/__tmp_lib/ -name "*.so*" | xargs ${CROSS_COMPILE}strip
	LIBSIZE=`du -s -m /tmp/__tmp_lib/ | cut -f 1`
	echo "libsize: ${LIBSIZE}"
	if [ ${LIBSIZE} -ge 64 ]; then
		echo "Info: Size of libs more than 64M. (${LIBSIZE})"
	else
		rm -rf ${TARGET_DIR}/rootfs/lib/*
		cp -raf /tmp/__tmp_lib/* ${TARGET_DIR}/rootfs/lib/
	fi
	rm -rf /tmp/__tmp_lib
fi
cp -arf ${ROOTFS_OUT}/${ROOTFS_OBJ_PATH}/* ${TARGET_DIR}/rootfs/
mknod ${TARGET_DIR}/rootfs/dev/console c 5 1

umount ${TARGET_DIR}/rootfs
rm -rf ${TARGET_DIR}/rootfs

