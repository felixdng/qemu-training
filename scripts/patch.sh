#!/bin/bash

# These variables are defined in the top-level Makefile.
# TOP_DIR,TARGET_DIR,ROOTFS_OUT,etc.

# example for use patch.
# 1. how to make patch:
# diff -Naur linux-2.6.24 linux-2.6.24-new > linux.patch
# 
# 2. how to patch:
# cd linux-2.6.24/
# patch -p1 < linux.patch

OBJ_PATCH=$1
if [ "${OBJ_PATCH}" = "uboot" ]; then
  for PT_FILE in $(find ${CONFIG_DIR}/${PROJECT} -name "uboot*.patch")
  do
    cd ${UBOOT_SRC}
    patch -p1 < ${PT_FILE}
  done
elif [ "${OBJ_PATCH}" = "linux" ]; then
  for PT_FILE in $(find ${CONFIG_DIR}/${PROJECT} -name "linux*.patch")
  do
    cd ${LINUX_SRC}
    patch -p1 < ${PT_FILE}
  done
elif [ "${OBJ_PATCH}" = "rootfs" ]; then
  for PT_FILE in $(find ${CONFIG_DIR}/${PROJECT} -name "rootfs*.patch")
  do
    cd ${ROOTFS_SRC}
    patch -p1 < ${PT_FILE}
  done
else
echo "Not supported: ${OBJ_PATCH}"
fi
