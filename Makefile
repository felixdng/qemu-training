#
# Check the project type.
# Setting project variables
PROJECT?=
ifneq ($(p),)
PROJECT:=$(p)
else ifeq ($(PROJECT),)
PROJECT:=vexpress
endif
export PROJECT

export TOP_DIR:=$(shell pwd)
export CONFIG_DIR=$(TOP_DIR)/configs
export DOWNLOAD_DIR=$(TOP_DIR)/download

export BUILD_DIR=$(TOP_DIR)/build
export TARGET_DIR=$(BUILD_DIR)/$(PROJECT)/target
export SRC_DIR=$(BUILD_DIR)/$(PROJECT)/src
export OUT_DIR=$(BUILD_DIR)/$(PROJECT)/output

export ARCH?=arm
export CROSS_COMPILE?=arm-linux-gnueabihf-
export COMPILE_LIBS_DIR?=/usr/arm-linux-gnueabihf/lib


#-------------------------------------------------------------#
# functions defined.                                          #
#-------------------------------------------------------------#

# $(call ifeq_any_of,arg1,arg2)
# return:
#    non null: arg1 is equal to at least one element in arg2
#    null: not equal
ifeq_any_of = $(filter $(1),$(foreach v,$(2),$(v)))


#-------------------------------------------------------------#
# configs                                                     #
#-------------------------------------------------------------#

# check config files
ifeq ($(wildcard $(CONFIG_DIR)/$(PROJECT)),)
$(error project '$(PROJECT)' not supported)
else ifeq ($(wildcard $(CONFIG_DIR)/$(PROJECT)/$(PROJECT).mk),)
$(error project '$(PROJECT)' configs does not exist)
endif
include $(CONFIG_DIR)/$(PROJECT)/$(PROJECT).mk

export UBOOT_VER?=u-boot-2015.01
export UBOOT_SRC=$(SRC_DIR)/$(UBOOT_VER)
export UBOOT_OUT=$(OUT_DIR)/$(UBOOT_VER)

export LINUX_VER?=linux-4.0.1
export LINUX_SRC=$(SRC_DIR)/$(LINUX_VER)
export LINUX_OUT=$(OUT_DIR)/$(LINUX_VER)

export ROOTFS_VER?=busybox-1.27.0
export ROOTFS_SRC=$(SRC_DIR)/$(ROOTFS_VER)
export ROOTFS_OUT=$(OUT_DIR)/$(ROOTFS_VER)

MK_UBOOT_CONFIG?=vexpress_ca9x4_defconfig
UBOOT_CONFIG_PATH?=configs/vexpress_ca9x4_defconfig
MK_LINUX_CONFIG?=vexpress_defconfig
LINUX_CONFIG_PATH?=arch/arm/configs/vexpress_defconfig


#-------------------------------------------------------------#
#                                                             #
#-------------------------------------------------------------#
all:


#-------------------------------------------------------------#
# prebuild                                                    #
#-------------------------------------------------------------#
prebuild:
	$(info prebuild start...)
	$(shell mkdir -p $(SRC_DIR) $(OUT_DIR) $(TARGET_DIR) $(UBOOT_OUT) $(LINUX_OUT) $(ROOTFS_OUT))
ifeq ($(wildcard $(UBOOT_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(UBOOT_VER).tar.*),)
	$(error [prebuild] u-boot package file is not exist!)
else
	$(info [prebuild] u-boot preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(UBOOT_VER).tar.* -C $(SRC_DIR))
	$(info [prebuild] u-boot finish.$(rst))
endif
else
	$(info [prebuild] u-boot directory already exist.)
endif
ifeq ($(wildcard $(LINUX_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(LINUX_VER).tar.*),)
	$(error [prebuild] linux kernel package file is not exist!)
else
	$(info [prebuild] linux kernel preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(LINUX_VER).tar.* -C $(SRC_DIR))
	$(info [prebuild] linux kernel finish.)
endif
else
	$(info [prebuild] linux kernel directory already exist.)
endif
ifeq ($(wildcard $(ROOTFS_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(ROOTFS_VER).tar.*),)
	$(error [prebuild] rootfs package file is not exist!)
else
	$(info [prebuild] rootfs preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(ROOTFS_VER).tar.* -C $(SRC_DIR))
	$(info [prebuild] rootfs finish.$(rst))
endif
else
	$(info [prebuild] rootfs directory already exist.)
endif
	@echo "prebuild finish"


#-------------------------------------------------------------#
# uboot                                                       #
#-------------------------------------------------------------#
uboot-config:
ifeq ($(wildcard $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_uboot_defconfig),)
	@cp -f $(UBOOT_SRC)/$(UBOOT_CONFIG_PATH) $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_uboot_defconfig
endif
	@cp -f $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_uboot_defconfig $(UBOOT_SRC)/$(UBOOT_CONFIG_PATH)
	make $(MK_UBOOT_CONFIG) -C $(UBOOT_SRC) O=$(UBOOT_OUT)
uboot-saveconfig:
	make savedefconfig -C $(UBOOT_SRC) O=$(UBOOT_OUT)
	@cp -f $(UBOOT_OUT)/defconfig $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_uboot_defconfig
uboot-build:
	make -C $(UBOOT_SRC) O=$(UBOOT_OUT)
uboot-clean:
	make clean -C $(UBOOT_SRC) O=$(UBOOT_OUT)
UBOOT_DEF_CMD=$(MK_UBOOT_CONFIG) savedefconfig clean
uboot:
ifneq ($(t),)
ifeq ($(call ifeq_any_of,$(t),$(UBOOT_DEF_CMD)),)
	make $(t) -C $(UBOOT_SRC) O=$(UBOOT_OUT)
endif
endif


#-------------------------------------------------------------#
# linux kernel                                                #
#-------------------------------------------------------------#
linux-config:
ifeq ($(wildcard $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_linux_defconfig),)
	@cp -f $(LINUX_SRC)/$(LINUX_CONFIG_PATH) $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_linux_defconfig
endif
	@cp -f $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_linux_defconfig $(LINUX_SRC)/$(LINUX_CONFIG_PATH)
	make $(MK_LINUX_CONFIG) -C $(LINUX_SRC) O=$(LINUX_OUT)
linux-saveconfig:
	make savedefconfig -C $(LINUX_SRC) O=$(LINUX_OUT)
	@cp -f $(LINUX_OUT)/defconfig $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_linux_defconfig
linux-build:
	make zImage -C $(LINUX_SRC) O=$(LINUX_OUT)
	make modules -C $(LINUX_SRC) O=$(LINUX_OUT)
	make dtbs -C $(LINUX_SRC) O=$(LINUX_OUT)
linux-clean:
	make clean -C $(LINUX_SRC) O=$(LINUX_OUT)
LINUX_DEF_CMD=$(MK_LINUX_CONFIG) savedefconfig clean
linux:
ifneq ($(t),)
ifeq ($(call ifeq_any_of,$(t),$(LINUX_DEF_CMD)),)
	make $(t) -C $(LINUX_SRC) O=$(LINUX_OUT)
endif
endif


#-------------------------------------------------------------#
# rootfs                                                      #
#-------------------------------------------------------------#
rootfs-config:
	make defconfig -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
rootfs-build:
	make -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
	make install -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
rootfs-clean:
	make clean -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
ROOTFS_DEF_CMD=defconfig install clean
rootfs:
ifneq ($(t),)
ifeq ($(call ifeq_any_of,$(t),$(ROOTFS_DEF_CMD)),)
	make $(t) -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
endif
endif


#-------------------------------------------------------------#
# install                                                     #
#-------------------------------------------------------------#
install-uboot:
	cp -f $(UBOOT_OUT)/u-boot $(TARGET_DIR)/

install-linux:
ifeq ($(ARCH),arm)
	cp -f $(LINUX_OUT)/arch/arm/boot/zImage $(TARGET_DIR)/
	cp -f $(LINUX_OUT)/arch/arm/boot/dts/*.dtb $(TARGET_DIR)/
else
endif

install-rootfs:
	cp -f $(TOP_DIR)/scripts/run*.sh $(TARGET_DIR)/
	$(TOP_DIR)/scripts/mkrootfs.sh


#-------------------------------------------------------------#
#                                                             #
#-------------------------------------------------------------#
.PHONY:all prebuild \
       uboot-config uboot-saveconfig uboot-build uboot-clean uboot \
       linux-config linux-saveconfig linux-build linux-clean linux \
       rootfs-config rootfs-build rootfs-clean rootfs \
	   install-uboot install-linux install-rootfs

