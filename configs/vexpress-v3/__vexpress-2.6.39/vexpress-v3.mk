# vexpress-v3.mk
# Some configurations for a specific project. 
# 

# [optional] Architecture and compiler.
export ARCH:=arm
export CROSS_COMPILE:=arm-linux-gnueabihf-
export COMPILE_LIBS_DIR:=/usr/arm-linux-gnueabihf/lib

# [required] uboot
override OBJ_UBOOT:=n
#export UBOOT_VER:=u-boot-2015.01
#export MK_UBOOT_CONFIG:=versatilepb_defconfig
#export UBOOT_OBJ_IMAGE:=u-boot

# [required] linux
override OBJ_LINUX:=y
export LINUX_VER:=linux-2.6.39
export MK_LINUX_CONFIG:=vexpress_defconfig
export LINUX_OBJ_IMAGE:=arch/arm/boot/zImage
#export LINUX_OBJ_DTB_PATH:=arch/arm/boot/dts

# [required] rootfs
override OBJ_ROOTFS:=y
export ROOTFS_VER:=busybox-1.32.0
export ROOTFS_OBJ_PATH:=_install

