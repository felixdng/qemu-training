# vexpress.mk
# Some configurations for a specific project. 
# 

# [optional] Architecture and compiler.
export ARCH:=arm
export CROSS_COMPILE:=arm-linux-gnueabihf-
export COMPILE_LIBS_DIR:=/usr/arm-linux-gnueabihf/lib

# [required] uboot
override OBJ_UBOOT:=y
export UBOOT_VER:=u-boot-2019.10
export MK_UBOOT_CONFIG:=vexpress_ca9x4_defconfig
export UBOOT_CONFIG_PATH:=configs/vexpress_ca9x4_defconfig
export UBOOT_OBJ_IMAGE:=u-boot

# [required] linux
override OBJ_LINUX:=y
export LINUX_VER:=linux-4.20.17
export MK_LINUX_CONFIG:=vexpress_defconfig
export LINUX_CONFIG_PATH:=arch/arm/configs/vexpress_defconfig
export LINUX_OBJ_IMAGE:=arch/arm/boot/zImage
export LINUX_OBJ_DTB_PATH:=arch/arm/boot/dts

# [required] rootfs
override OBJ_ROOTFS:=y
export ROOTFS_VER:=busybox-1.32.0
export ROOTFS_OBJ_PATH:=_install

