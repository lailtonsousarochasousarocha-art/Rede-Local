LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := redelocal
LOCAL_SRC_FILES := native-lib.cpp
LOCAL_CPPFLAGS := -std=c++11 -Wall -Wextra
LOCAL_LDLIBS := -llog
include $(BUILD_SHARED_LIBRARY)
