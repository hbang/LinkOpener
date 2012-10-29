include theos/makefiles/common.mk

TWEAK_NAME = LinkOpener
LinkOpener_FILES = Tweak.xm
LinkOpener_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
