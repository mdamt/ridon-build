# Copyright (C) 2013-2014 Paul Kocialkowski <contact@paulk.fr>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

UBOOT_SRC := $(TARGET_UBOOT_SOURCE)
UBOOT_CONFIG := $(TARGET_UBOOT_CONFIG)
UBOOT_OUT := $(TARGET_OUT_INTERMEDIATES)/UBOOT_OBJ

UBOOT_BIN := $(UBOOT_OUT)/u-boot.bin

ifeq ($(TARGET_ARCH),arm)
    ifneq ($(USE_CCACHE),)
     # search executable
      ccache =
      ifneq ($(strip $(wildcard $(ANDROID_BUILD_TOP)/prebuilts/misc/$(HOST_PREBUILT_EXTRA_TAG)/ccache/ccache)),)
        ccache := $(ANDROID_BUILD_TOP)/prebuilts/misc/$(HOST_PREBUILT_EXTRA_TAG)/ccache/ccache
      else
        ifneq ($(strip $(wildcard $(ANDROID_BUILD_TOP)/prebuilts/misc/$(HOST_PREBUILT_TAG)/ccache/ccache)),)
          ccache := $(ANDROID_BUILD_TOP)/prebuilts/misc/$(HOST_PREBUILT_TAG)/ccache/ccache
        endif
      endif
    endif
    ifneq ($(TARGET_KERNEL_CUSTOM_TOOLCHAIN),)
        ifeq ($(HOST_OS),darwin)
            ARM_CROSS_COMPILE:=CROSS_COMPILE="$(ccache) $(ANDROID_BUILD_TOP)/prebuilt/darwin-x86/toolchain/$(TARGET_KERNEL_CUSTOM_TOOLCHAIN)/bin/arm-eabi-"
        else
            ARM_CROSS_COMPILE:=CROSS_COMPILE="$(ccache) $(ANDROID_BUILD_TOP)/prebuilt/linux-x86/toolchain/$(TARGET_KERNEL_CUSTOM_TOOLCHAIN)/bin/arm-eabi-"
        endif
    else
        ARM_CROSS_COMPILE:=CROSS_COMPILE="$(ccache) $(ARM_EABI_TOOLCHAIN)/arm-eabi-"
    endif
    ccache = 
endif

$(UBOOT_OUT):
	mkdir -p $(UBOOT_OUT)

$(UBOOT_CONFIG):
	$(MAKE) -C $(UBOOT_SRC) O=$(UBOOT_OUT) ARCH=$(TARGET_ARCH) $(ARM_CROSS_COMPILE) $(UBOOT_CONFIG)

$(UBOOT_BIN): $(UBOOT_CONFIG)
	$(MAKE) -C $(UBOOT_SRC) O=$(UBOOT_OUT) ARCH=$(TARGET_ARCH) $(ARM_CROSS_COMPILE)

$(INSTALLED_UBOOT_MODULE): $(UBOOT_OUT) $(UBOOT_BIN)
	mv $(UBOOT_BIN) $@
