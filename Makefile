export ARCHS = armv7 arm64
export SDKVERSION = 7.0

include theos/makefiles/common.mk

TWEAK_NAME = IconLock
IconLock_FILES = Tweak.xm
IconLock_FRAMEWORKS = UIKit
#SUBPROJECTS = settings

include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
