TARGET = iphone:

include theos/makefiles/common.mk

TWEAK_NAME = LinkOpener
LinkOpener_FILES = Tweak.xm
LinkOpener_FRAMEWORKS = UIKit
LinkOpener_LDFLAGS = -lopener

include $(THEOS_MAKE_PATH)/tweak.mk
