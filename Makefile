TARGET = iphone:clang:latest:5.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LinkOpener
LinkOpener_FILES = HBLOLinkOpenerHandler.m
LinkOpener_INSTALL_PATH = /Library/Opener
LinkOpener_FRAMEWORKS = UIKit
LinkOpener_EXTRA_FRAMEWORKS = Cephei Opener

TWEAK_NAME = LinkOpenerHooks
LinkOpenerHooks_FILES = Tweak.xm
LinkOpenerHooks_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS = prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifneq ($(RESPRING),0)
	install.exec spring
endif
