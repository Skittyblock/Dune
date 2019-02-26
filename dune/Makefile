include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Dune
Dune_FILES = DUNERootListController.m
Dune_INSTALL_PATH = /Library/PreferenceBundles
Dune_FRAMEWORKS = UIKit
Dune_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Dune.plist$(ECHO_END)
