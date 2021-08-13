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

DOWNLOAD_DIR=$(TOP_DIR)/download

MYMAKE=make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

all:prebuild uboot-config uboot kernel-config kernel rootfs-config rootfs

prebuild:
	$(info prebuild start...)
ifeq ($(wildcard $(UBOOT_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(UBOOT_VER).tar.*),)
	$(error "[prebuild] u-boot package file is not exist!")
else
	$(info [prebuild] u-boot preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(UBOOT_VER).tar.* -C $(TOP_DIR))
	$(info [prebuild] u-boot finish.$(rst))
endif
else
	$(info [prebuild] u-boot directory already exist.)
endif
ifeq ($(wildcard $(KERNEL_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(KERNEL_VER).tar.*),)
	$(error "[prebuild] linux kernel package file is not exist!")
else
	$(info [prebuild] linux kernel preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(KERNEL_VER).tar.* -C $(TOP_DIR))
	$(info [prebuild] linux kernel finish.)
endif
else
	$(info [prebuild] linux kernel directory already exist.)
endif
ifeq ($(wildcard $(ROOTFS_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(ROOTFS_VER).tar.*),)
	$(error "[prebuild] rootfs package file is not exist!")
else
	$(info [prebuild] rootfs preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(ROOTFS_VER).tar.* -C $(TOP_DIR))
	$(info [prebuild] rootfs finish.$(rst))
endif
else
	$(info [prebuild] rootfs directory already exist.)
endif
	@echo "prebuild finish"

# ------------------------- u-boot -------------------------
uboot:
	$(MYMAKE) -C $(UBOOT_SRC) O=$(UBOOT_OUT)

uboot-config:
	$(MYMAKE) vexpress_ca9x4_defconfig -C $(UBOOT_SRC) O=$(UBOOT_OUT)

uboot-clean:
	rm -rf $(UBOOT_OUT)

uboot-rebuild:uboot-clean uboot-config uboot

# ------------------------- linux kernel -------------------------
kernel:
	$(MYMAKE) zImage -C $(KERNEL_SRC) O=$(KERNEL_OUT)
	$(MYMAKE) modules -C $(KERNEL_SRC) O=$(KERNEL_OUT)
	$(MYMAKE) dtbs -C $(KERNEL_SRC) O=$(KERNEL_OUT)

kernel-config:
	$(MYMAKE) vexpress_defconfig -C $(KERNEL_SRC) O=$(KERNEL_OUT)

kernel-clean:
	rm -rf $(KERNEL_OUT)

kernel-rebuild:kernel-clean kernel-config kernel

rootfs:
	$(MYMAKE) -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
	$(MYMAKE) install -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
	
rootfs-config:
	mkdir -p $(ROOTFS_OUT)
	$(MYMAKE) defconfig -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)

rootfs-clean:
	rm -rf $(ROOTFS_OUT)

rootfs-rebuild:rootfs-clean rootfs-config rootfs

install:
	mkdir -p $(TARGET_DIR)
	cp -f $(UBOOT_OUT)/u-boot $(TARGET_DIR)/u-boot
	cp -f $(KERNEL_OUT)/arch/arm/boot/zImage $(TARGET_DIR)/zImage
	cp -f $(KERNEL_OUT)/arch/arm/boot/dts/vexpress-v2p-ca9.dtb $(TARGET_DIR)/vexpress-v2p-ca9.dtb
	cp -f $(TOP_DIR)/scripts/run*.sh $(TARGET_DIR)/
	$(TOP_DIR)/scripts/mkrootfs.sh

.PHONY:all prebuild install \
       uboot uboot-config uboot-clean uboot-rebuild\
       kernel kernel-config kernel-clean kernel-rebuild \
       rootfs rootfs-config rootfs-clean rootfs-rebuild

