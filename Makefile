PACKAGE_VERSION = 1.0.0
TARGET = iphone:clang:latest:11.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ChangeVolWithButtonFS
ChangeVolWithButtonFS_FILES = Switch.xm
ChangeVolWithButtonFS_LIBRARIES = flipswitch MobileGestalt
ChangeVolWithButtonFS_FRAMEWORKS = UIKit
ChangeVolWithButtonFS_PRIVATE_FRAMEWORKS = Celestial
ChangeVolWithButtonFS_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk
