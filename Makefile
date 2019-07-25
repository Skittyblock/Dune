DEBUG = 0
FINALPACKAGE = 1

TARGET = iphone:clang::11.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dune
Dune_CFLAGS = -fobjc-arc
Dune_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += dune
include $(THEOS_MAKE_PATH)/aggregate.mk
