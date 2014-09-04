TWEAK_NAME = HomekeyHangup
HomekeyHangup_FILES = main.xm
HomekeyHangup_FRAMEWORKS = AVFoundation

export THEOS_DEVICE_IP = 192.168.0.170
export TARGET=iphone:clang
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
