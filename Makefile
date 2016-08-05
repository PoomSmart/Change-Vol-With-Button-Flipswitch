DEBUG = 0
PACKAGE_VERSION = 0.0.1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ChangeVolWithBtn
ChangeVolWithBtn_FILES = Switch.xm
ChangeVolWithBtn_LIBRARIES = flipswitch MobileGestalt
ChangeVolWithBtn_FRAMEWORKS = UIKit
ChangeVolWithBtn_PRIVATE_FRAMEWORKS = Celestial
ChangeVolWithBtn_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk