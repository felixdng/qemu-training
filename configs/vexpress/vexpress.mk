# vexpress.mk
# Some configurations for a specific project. 
# 

# [optional] Architecture and compiler.
unexport ARCH
export ARCH:=arm
unexport CROSS_COMPILE
export CROSS_COMPILE:=arm-linux-gnueabihf-
unexport COMPILE_LIBS_DIR
export COMPILE_LIBS_DIR:=/usr/arm-linux-gnueabihf/lib

# [optional] version infomations.
override UBOOT_VER:=u-boot-2015.01
override LINUX_VER:=linux-4.20.17
override ROOTFS_VER:=busybox-1.32.0

# [required]
override MK_UBOOT_CONFIG:=vexpress_ca9x4_defconfig
override UBOOT_CONFIG_PATH:=configs/vexpress_ca9x4_defconfig
override MK_LINUX_CONFIG:=vexpress_defconfig
override LINUX_CONFIG_PATH:=arch/arm/configs/vexpress_defconfig

