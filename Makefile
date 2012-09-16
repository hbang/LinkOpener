include theos/makefiles/common.mk

TWEAK_NAME = LinkOpener
YTOpener_FILES = Tweak.xm
YTOpener_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
