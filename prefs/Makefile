include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LinkOpenerPrefs
LinkOpenerPrefs_FILES = $(wildcard *.m)
LinkOpenerPrefs_INSTALL_PATH = /Library/PreferenceBundles
LinkOpenerPrefs_FRAMEWORKS = UIKit
LinkOpenerPrefs_PRIVATE_FRAMEWORKS = Preferences
LinkOpenerPrefs_EXTRA_FRAMEWORKS = CepheiPrefs
LinkOpenerPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
