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
else ifeq ($(UBOOT_CONFIG_PATH),)
	$(error uboot config path not setted)
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
else ifeq ($(LINUX_CONFIG_PATH),)
	$(error linux config path not setted)
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

endif # ifeq ($(OBJ_UBOOT),y)


#-------------------------------------------------------------#
# linux kernel                                                #
#-------------------------------------------------------------#
ifeq ($(OBJ_LINUX),y)
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

endif # ifeq ($(OBJ_LINUX),y)


#-------------------------------------------------------------#
# rootfs                                                      #
#-------------------------------------------------------------#
ifeq ($(OBJ_ROOTFS),y)
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

endif # ifeq ($(OBJ_ROOTFS),y)


#-------------------------------------------------------------#
# install                                                     #
#-------------------------------------------------------------#
ifeq ($(OBJ_UBOOT),y)
install-uboot:
	@cp -f $(UBOOT_OUT)/$(UBOOT_OBJ_IMAGE) $(TARGET_DIR)/
endif

ifeq ($(OBJ_LINUX),y)
install-linux:
	@cp -f $(LINUX_OUT)/$(LINUX_OBJ_IMAGE) $(TARGET_DIR)/
ifneq ($(LINUX_OBJ_DTB_PATH),)
	@cp -f $(LINUX_OUT)/$(LINUX_OBJ_DTB_PATH)/*.dtb $(TARGET_DIR)/
endif
endif

ifeq ($(OBJ_ROOTFS),y)
install-rootfs:
	@cp -f $(TOP_DIR)/scripts/run*.sh $(TARGET_DIR)/
	$(TOP_DIR)/scripts/mkrootfs.sh
endif

ifeq ($(OBJ_UBOOT),y)
ifeq ($(OBJ_LINUX),y)
ifeq ($(OBJ_ROOTFS),y)
install-disk:
	@cp -f $(TOP_DIR)/scripts/run*.sh $(TARGET_DIR)/
	$(TOP_DIR)/scripts/mkdisk.sh
endif
endif
endif


#-------------------------------------------------------------#
#                                                             #
#-------------------------------------------------------------#
.PHONY:all prebuild \
       uboot-config uboot-saveconfig uboot-build uboot-clean uboot \
       linux-config linux-saveconfig linux-build linux-clean linux \
       rootfs-config rootfs-build rootfs-clean rootfs \
	   install-uboot install-linux install-rootfs install-disk

