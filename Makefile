TOP_DIR=$(shell pwd)
BUILD_DIR=$(TOP_DIR)/build
TARGET_DIR=$(TOP_DIR)/target

UBOOT_VER=u-boot-2015.01
UBOOT_SRC=$(TOP_DIR)/$(UBOOT_VER)
UBOOT_OUT=$(BUILD_DIR)/$(UBOOT_VER)

KERNEL_VER=linux-4.0.1
KERNEL_SRC=$(TOP_DIR)/$(KERNEL_VER)
KERNEL_OUT=$(BUILD_DIR)/$(KERNEL_VER)

ROOTFS_VER=busybox-1.27.0
ROOTFS_SRC=$(TOP_DIR)/$(ROOTFS_VER)
ROOTFS_OUT=$(BUILD_DIR)/$(ROOTFS_VER)

all:

uboot:
	export ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
	make -C $(UBOOT_SRC) O=$(UBOOT_OUT)

uboot-config:
	export ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
	make vexpress_ca9x4_defconfig -C $(UBOOT_SRC) O=$(UBOOT_OUT)

uboot-clean:
	rm -rf $(UBOOT_OUT)

uboot-rebuild:uboot-clean uboot-config uboot

kernel:
	export ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
	make zImage -C $(KERNEL_SRC) O=$(KERNEL_OUT)
	make modules -C $(KERNEL_SRC) O=$(KERNEL_OUT)
	make dtbs -C $(KERNEL_SRC) O=$(KERNEL_OUT)

kernel-config:
	export ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
	make vexpress_defconfig -C $(KERNEL_SRC) O=$(KERNEL_OUT)

kernel-clean:
	rm -rf $(KERNEL_OUT)

kernel-rebuild:kernel-clean kernel-config kernel

rootfs:
	export ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
	make -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
	make install -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
	
rootfs-config:
	mkdir -p $(ROOTFS_OUT)
	export ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
	make defconfig -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)

rootfs-clean:
	rm -rf $(ROOTFS_OUT)

rootfs-rebuild:rootfs-clean rootfs-config rootfs

install:
	mkdir -p $(TARGET_DIR)
	cp -f $(UBOOT_OUT)/u-boot $(TARGET_DIR)/u-boot
	cp -f $(KERNEL_OUT)/arch/arm/boot/zImage $(TARGET_DIR)/zImage
	cp -f $(KERNEL_OUT)/arch/arm/boot/dts/vexpress-v2p-ca9.dtb $(TARGET_DIR)/vexpress-v2p-ca9.dtb
	$(TOP_DIR)/scripts/mkrootfs.sh 
