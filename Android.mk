# Copyright (C) 2007 The Android Open Source Project
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

LOCAL_PATH := $(call my-dir)


include $(CLEAR_VARS)

LOCAL_SRC_FILES := fuse_sideload.cpp
LOCAL_CLANG := true
LOCAL_CFLAGS := -O2 -g -DADB_HOST=0 -Wall -Wno-unused-parameter
LOCAL_CFLAGS += -D_XOPEN_SOURCE -D_GNU_SOURCE

LOCAL_MODULE := libfusesideload

LOCAL_STATIC_LIBRARIES := libcutils libc libmincrypt
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    adb_install.cpp \
    asn1_decoder.cpp \
    bootloader.cpp \
    device.cpp \
    fuse_sdcard_provider.cpp \
    install.cpp \
    recovery.cpp \
    messagesocket.cpp \
    roots.cpp \
    screen_ui.cpp \
    ui.cpp \
    verifier.cpp \
    wear_ui.cpp \

LOCAL_MODULE := recovery

LOCAL_FORCE_STATIC_EXECUTABLE := true

ifeq ($(HOST_OS),linux)
LOCAL_REQUIRED_MODULES := mkfs.f2fs
endif

RECOVERY_API_VERSION := 3
RECOVERY_FSTAB_VERSION := 2
LOCAL_CFLAGS += -DRECOVERY_API_VERSION=$(RECOVERY_API_VERSION)
LOCAL_CFLAGS += -Wno-unused-parameter
LOCAL_CLANG := true

LOCAL_C_INCLUDES += \
    system/vold \
    system/extras/ext4_utils \
    system/core/adb \

LOCAL_STATIC_LIBRARIES := \
    libext4_utils_static \
    libsparse_static \
    libminzip \
    libz \
    libmtdutils \
    libmincrypt \
    libminadbd \
    libfusesideload \
    libminui \
    libpng \
    libfs_mgr \
    libbase \
    libcutils \
    liblog \
    libselinux \
    libm \
    libc \
    libc++_static \
    libz

LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/sbin

# Handling for EV_REL is disabled by default because some accelerometers
# send EV_REL events.  Actual EV_REL devices are rare on modern hardware
# so it's cleaner just to disable it by default.
ifneq ($(BOARD_RECOVERY_NEEDS_REL_INPUT),)
    LOCAL_CFLAGS += -DBOARD_RECOVERY_NEEDS_REL_INPUT
endif

ifeq ($(TARGET_RECOVERY_UI_LIB),)
  LOCAL_SRC_FILES += default_device.cpp
else
  LOCAL_STATIC_LIBRARIES += $(TARGET_RECOVERY_UI_LIB)
endif

include $(BUILD_EXECUTABLE)

# All the APIs for testing
include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := libverifier
LOCAL_MODULE_TAGS := tests
LOCAL_SRC_FILES := \
    asn1_decoder.cpp
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_MODULE := verifier_test
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_MODULE_TAGS := tests
LOCAL_CFLAGS += -Wno-unused-parameter
LOCAL_SRC_FILES := \
    verifier_test.cpp \
    asn1_decoder.cpp \
    verifier.cpp \
    ui.cpp
LOCAL_STATIC_LIBRARIES := \
    libmincrypt \
    libminui \
    libminzip \
    libcutils \
    libc
include $(BUILD_EXECUTABLE)


include $(LOCAL_PATH)/minui/Android.mk \
    $(LOCAL_PATH)/minzip/Android.mk \
    $(LOCAL_PATH)/minadbd/Android.mk \
    $(LOCAL_PATH)/mtdutils/Android.mk \
    $(LOCAL_PATH)/tests/Android.mk \
    $(LOCAL_PATH)/tools/Android.mk \
    $(LOCAL_PATH)/edify/Android.mk \
    $(LOCAL_PATH)/uncrypt/Android.mk \
    $(LOCAL_PATH)/updater/Android.mk \
    $(LOCAL_PATH)/applypatch/Android.mk
