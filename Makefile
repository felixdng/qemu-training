#
# Check the project type.
# Setting project variables
PROJECT?=
ifneq ($(p),)
PROJECT:=$(p)
else ifeq ($(PROJECT),)
$(error No project was setted)
endif
export PROJECT

export TOP_DIR=$(shell pwd)
export CONFIG_DIR=$(TOP_DIR)/configs
export DOWNLOAD_DIR=$(TOP_DIR)/download

export BUILD_DIR=$(TOP_DIR)/build
export TARGET_DIR=$(BUILD_DIR)/$(PROJECT)/target
export SRC_DIR=$(BUILD_DIR)/$(PROJECT)/src
export OUT_DIR=$(BUILD_DIR)/$(PROJECT)/output

export OBJ_UBOOT:=n
export OBJ_LINUX:=n
export OBJ_ROOTFS:=n

MK_JOBS:=-j2


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

ifeq ($(OBJ_UBOOT),y)
ifeq ($(UBOOT_VER),)
	$(error uboot version not setted)
else ifeq ($(MK_UBOOT_CONFIG),)
	$(error uboot config not setted)
else ifeq ($(UBOOT_OBJ_IMAGE),)
	$(error uboot image not setted)
else
export UBOOT_SRC=$(SRC_DIR)/$(UBOOT_VER)
export UBOOT_OUT=$(OUT_DIR)/$(UBOOT_VER)
endif
endif

ifeq ($(OBJ_LINUX),y)
ifeq ($(LINUX_VER),)
	$(error linux version not setted)
else ifeq ($(MK_LINUX_CONFIG),)
	$(error linux config not setted)
else ifeq ($(LINUX_OBJ_IMAGE),)
	$(error linux image not setted)
else
export LINUX_SRC=$(SRC_DIR)/$(LINUX_VER)
export LINUX_OUT=$(OUT_DIR)/$(LINUX_VER)
endif
endif

ifeq ($(OBJ_ROOTFS),y)
ifeq ($(ROOTFS_VER),)
	$(error rootfs version not setted)
else
export ROOTFS_SRC=$(SRC_DIR)/$(ROOTFS_VER)
export ROOTFS_OUT=$(OUT_DIR)/$(ROOTFS_VER)
endif
endif


#-------------------------------------------------------------#
#                                                             #
#-------------------------------------------------------------#
all:


#-------------------------------------------------------------#
# prebuild                                                    #
#-------------------------------------------------------------#
prebuild:
	$(info prebuild start...)
	$(shell mkdir -p $(SRC_DIR) $(OUT_DIR) $(TARGET_DIR))
ifeq ($(OBJ_UBOOT),y)
	$(shell mkdir -p $(UBOOT_OUT))
ifeq ($(wildcard $(UBOOT_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(UBOOT_VER).tar.*),)
	$(error [prebuild] u-boot package file is not exist!)
else
	$(info [prebuild] u-boot preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(UBOOT_VER).tar.* -C $(SRC_DIR))
	@$(TOP_DIR)/scripts/patch.sh uboot
	$(info [prebuild] u-boot finish.$(rst))
endif
else
	$(info [prebuild] u-boot directory already exist.)
endif
endif

ifeq ($(OBJ_LINUX),y)
	$(shell mkdir -p $(LINUX_OUT))
ifeq ($(wildcard $(LINUX_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(LINUX_VER).tar.*),)
	$(error [prebuild] linux kernel package file is not exist!)
else
	$(info [prebuild] linux kernel preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(LINUX_VER).tar.* -C $(SRC_DIR))
	@$(TOP_DIR)/scripts/patch.sh linux
	$(info [prebuild] linux kernel finish.)
endif
else
	$(info [prebuild] linux kernel directory already exist.)
endif
endif

ifeq ($(OBJ_ROOTFS),y)
	$(shell mkdir -p $(ROOTFS_OUT))
ifeq ($(wildcard $(ROOTFS_SRC)),)
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(ROOTFS_VER).tar.*),)
	$(error [prebuild] rootfs package file is not exist!)
else
	$(info [prebuild] rootfs preparing...)
	$(shell tar -xf $(DOWNLOAD_DIR)/$(ROOTFS_VER).tar.* -C $(SRC_DIR))
	@$(TOP_DIR)/scripts/patch.sh rootfs
	$(info [prebuild] rootfs finish.$(rst))
endif
else
	$(info [prebuild] rootfs directory already exist.)
endif
endif
	@echo "prebuild finish"


#-------------------------------------------------------------#
# uboot                                                       #
#-------------------------------------------------------------#
ifeq ($(OBJ_UBOOT),y)
uboot-defconfig:
	make $(MK_UBOOT_CONFIG) -C $(UBOOT_SRC) O=$(UBOOT_OUT)

ifneq ($(wildcard $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_uboot_oldconfig),)
uboot-oldconfig:
ifneq ($(wildcard $(UBOOT_OUT)/.config),)
	cp -f $(UBOOT_OUT)/.config $(UBOOT_OUT)/.config.bak
endif
	cp -f $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_uboot_oldconfig $(UBOOT_OUT)/.config
	make oldconfig -C $(UBOOT_SRC) O=$(UBOOT_OUT)
endif

ifneq ($(wildcard $(UBOOT_OUT)/.config),)
uboot-saveconfig:
	cp -f $(UBOOT_OUT)/.config $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_uboot_oldconfig
endif

uboot-build:
	make $(MK_JOBS) -C $(UBOOT_SRC) O=$(UBOOT_OUT)

uboot-clean:
	make clean -C $(UBOOT_SRC) O=$(UBOOT_OUT)

UBOOT_DEF_CMD=$(MK_UBOOT_CONFIG) oldconfig clean
uboot:
ifneq ($(t),)
ifeq ($(call ifeq_any_of,$(t),$(UBOOT_DEF_CMD)),)
	make $(t) -C $(UBOOT_SRC) O=$(UBOOT_OUT)
endif
endif

endif # ifeq ($(OBJ_UBOOT),y)


#-------------------------------------------------------------#
# linux kernel                                                #
#-------------------------------------------------------------#
ifeq ($(OBJ_LINUX),y)
linux-defconfig:
	make $(MK_LINUX_CONFIG) -C $(LINUX_SRC) O=$(LINUX_OUT)

ifneq ($(wildcard $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_linux_oldconfig),)
linux-oldconfig:
ifneq ($(wildcard $(LINUX_OUT)/.config),)
	cp -f $(LINUX_OUT)/.config $(LINUX_OUT)/.config.bak
endif
	cp -f $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_linux_oldconfig $(LINUX_OUT)/.config
	make oldconfig -C $(LINUX_SRC) O=$(LINUX_OUT)
endif

ifneq ($(wildcard $(LINUX_OUT)/.config),)
linux-saveconfig:
	cp -f $(LINUX_OUT)/.config $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_linux_oldconfig
endif

linux-build:
ifeq ($(ARCH),arm)
	make $(MK_JOBS) zImage -C $(LINUX_SRC) O=$(LINUX_OUT)
else
	make $(MK_JOBS) bzImage -C $(LINUX_SRC) O=$(LINUX_OUT)
endif
	make $(MK_JOBS) modules -C $(LINUX_SRC) O=$(LINUX_OUT)
ifneq ($(LINUX_OBJ_DTB_PATH),)
	make $(MK_JOBS) dtbs -C $(LINUX_SRC) O=$(LINUX_OUT)
endif

linux-clean:
	make clean -C $(LINUX_SRC) O=$(LINUX_OUT)

LINUX_DEF_CMD=$(MK_LINUX_CONFIG) oldconfig clean
linux:
ifneq ($(t),)
ifeq ($(call ifeq_any_of,$(t),$(LINUX_DEF_CMD)),)
	make $(t) -C $(LINUX_SRC) O=$(LINUX_OUT)
endif
endif

endif # ifeq ($(OBJ_LINUX),y)


#-------------------------------------------------------------#
# rootfs                                                      #
#-------------------------------------------------------------#
ifeq ($(OBJ_ROOTFS),y)
rootfs-defconfig:
	make defconfig -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)

ifneq ($(wildcard $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_rootfs_oldconfig),)
rootfs-oldconfig:
ifneq ($(wildcard $(ROOTFS_OUT)/.config),)
	cp -f $(ROOTFS_OUT)/.config $(ROOTFS_OUT)/.config.bak
endif
	cp -f $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_rootfs_oldconfig $(ROOTFS_OUT)/.config
	make oldconfig -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
endif

ifneq ($(wildcard $(ROOTFS_OUT)/.config),)
rootfs-saveconfig:
	cp -f $(ROOTFS_OUT)/.config $(CONFIG_DIR)/$(PROJECT)/$(PROJECT)_rootfs_oldconfig
endif

rootfs-build:
	make $(MK_JOBS) -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
	make install -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)

rootfs-clean:
	make clean -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)

ROOTFS_DEF_CMD=defconfig oldconfig install clean
rootfs:
ifneq ($(t),)
ifeq ($(call ifeq_any_of,$(t),$(ROOTFS_DEF_CMD)),)
	make $(t) -C $(ROOTFS_SRC) O=$(ROOTFS_OUT)
endif
endif

endif # ifeq ($(OBJ_ROOTFS),y)


#-------------------------------------------------------------#
# install                                                     #
#-------------------------------------------------------------#
ifeq ($(OBJ_UBOOT),y)
install-uboot:
	cp -f $(UBOOT_OUT)/$(UBOOT_OBJ_IMAGE) $(TARGET_DIR)/
endif

ifeq ($(OBJ_LINUX),y)
install-linux:
	cp -f $(LINUX_OUT)/$(LINUX_OBJ_IMAGE) $(TARGET_DIR)/
ifneq ($(LINUX_OBJ_DTB_PATH),)
	cp -f $(LINUX_OUT)/$(LINUX_OBJ_DTB_PATH)/*.dtb $(TARGET_DIR)/
endif
endif

ifeq ($(OBJ_ROOTFS),y)
install-rootfs:
	cp -f $(TOP_DIR)/scripts/run*.sh $(TARGET_DIR)/
	$(TOP_DIR)/scripts/mkrootfs.sh
endif

ifeq ($(OBJ_UBOOT),y)
ifeq ($(OBJ_LINUX),y)
ifeq ($(OBJ_ROOTFS),y)
install-disk:
	cp -f $(TOP_DIR)/scripts/run*.sh $(TARGET_DIR)/
	$(TOP_DIR)/scripts/mkdisk.sh
endif
endif
endif


#-------------------------------------------------------------#
#                                                             #
#-------------------------------------------------------------#
.PHONY:all prebuild \
       uboot-defconfig uboot-oldconfig uboot-saveconfig uboot-build uboot-clean uboot \
       linux-defconfig linux-oldconfig linux-saveconfig linux-build linux-clean linux \
       rootfs-defconfig rootfs-oldconfig rootfs-saveconfig rootfs-build rootfs-clean rootfs \
       install-uboot install-linux install-rootfs install-disk

