// Dune, by Skitty
// A macOS Mojave-like dark mode for iOS.

#import "Tweak.h"

static NSMutableDictionary *settings;
static BOOL enabled;
static BOOL notifications;
static BOOL widgets;
static BOOL folders;
static BOOL dock;
static BOOL keyboard;

// Preference Updates
static void refreshPrefs() {
  [settings release];

  CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.skitty.dune"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if(keyList) {
    settings = (NSMutableDictionary *)CFPreferencesCopyMultiple(keyList, CFSTR("com.skitty.dune"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFRelease(keyList);
  } else {
    settings = nil;
  }
  if (!settings) {
    settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.skitty.dune.plist"];
  }

  enabled = [[settings objectForKey:@"enabled"] boolValue] ? [[settings objectForKey:@"enabled"] boolValue] : YES;
  notifications = [[settings objectForKey:@"notifications"] boolValue] ? [[settings objectForKey:@"notifications"] boolValue] : YES;
  widgets = [[settings objectForKey:@"widgets"] boolValue] ? [[settings objectForKey:@"widgets"] boolValue] : YES;
  folders = [[settings objectForKey:@"folders"] boolValue] ? [[settings objectForKey:@"folders"] boolValue] : YES;
  dock = [[settings objectForKey:@"dock"] boolValue] ? [[settings objectForKey:@"dock"] boolValue] : YES;
  keyboard = [[settings objectForKey:@"keyboard"] boolValue] ? [[settings objectForKey:@"keyboard"] boolValue] : NO;
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}

// Widget Hooks
// Only hooks inside widget content views to (more or less) change the text white.
%group Widget
%hook UILabel
- (void)setTextColor:(UIColor *)textColor {
  if (enabled && widgets) {
    %orig([UIColor whiteColor]);
  } else {
    %orig;
  }
}
%end

%hook UIButton
- (void)setTintColor:(UIColor *)color {
  if (enabled && widgets) {
    %orig([UIColor whiteColor]);
  } else {
    %orig;
  }
}
%end

%hook UIActivityIndicatorView
- (void)setColor:(UIColor *)color {
  if (enabled && widgets) {
    %orig([UIColor whiteColor]);
  } else {
    %orig;
  }
}
%end

%hook CALayer
- (void)setFilters:(NSArray *)filters {
  if (enabled && widgets) {
    CAFilter* filter = [CAFilter filterWithName:@"colorInvert"];
    [filter setDefaults];
    %orig([NSArray arrayWithObject:filter]);
  } else {
    %orig;
  }
}
%end
%end

// Notifications
%hook NCNotificationShortLookView
- (void)layoutSubviews {
  %orig;

  if (enabled && notifications) {
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.5];

    UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");

    // Do Not Disturb fix
    if (mainOverlayView.backgroundColor != nil) {
      [mainOverlayView setBackgroundColor:blackColor];
    }

    MTPlatterHeaderContentView *headerContentView = [self _headerContentView];
    [[[headerContentView _titleLabel] layer] setFilters:nil];
    [[[headerContentView _dateLabel] layer] setFilters:nil];
    [[headerContentView _titleLabel] setTextColor:whiteColor];
    [[headerContentView _dateLabel] setTextColor:whiteColor];

    NCNotificationContentView *notificationContentView = MSHookIvar<NCNotificationContentView *>(self, "_notificationContentView");
    [[notificationContentView _secondaryTextView] setTextColor:whiteColor];
    [[notificationContentView _primaryLabel] setTextColor:whiteColor];
    [[notificationContentView _primarySubtitleLabel] setTextColor:whiteColor];

    if ([notificationContentView respondsToSelector:@selector(_secondaryLabel)]) [[notificationContentView _secondaryLabel] setTextColor:whiteColor];
    if ([notificationContentView respondsToSelector:@selector(_summaryLabel)]) [[notificationContentView _summaryLabel] setTextColor:whiteColor];
  }
}
%end

%hook BSUIEmojiLabelView
- (void)layoutSubviews {
  %orig;
  if ([self.superview.superview isKindOfClass:%c(NCNotificationContentView)] && enabled && notifications) {
    CAFilter* filter = [CAFilter filterWithName:@"colorInvert"];
    [filter setDefaults];
    [[self layer] setFilters:[NSArray arrayWithObject:filter]];
  }
}
%end

// Stacked Notifications
%hook NCNotificationViewControllerView
- (void)layoutSubviews {
  %orig;
  if (enabled && notifications) {
    int count = 0;
    for (UIView *view in self.subviews) {
      if([view isKindOfClass:%c(PLPlatterView)]) {
        count++;
        if (count == 1) {
          MSHookIvar<UIView *>(view, "_mainOverlayView").alpha = 0.24;
        }
        MSHookIvar<UIView *>(view, "_mainOverlayView").backgroundColor = [UIColor blackColor];
      }
    }
  }
}
%end

// Notification Action Buttons (Manage/View/Clear/Etc.)
%hook NCNotificationListCellActionButton
- (void)layoutSubviews {
  %orig;
  if (enabled && notifications) {
    [[MSHookIvar<UILabel *>(self, "_titleLabel") layer] setFilters:nil];
    MSHookIvar<UIView *>(self, "_backgroundOverlayView").backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
  }
}
%end

// NC Clear/Show More/Show Less Buttons
%hook NCToggleControl
- (void)layoutSubviews {
  %orig;
  if (enabled && notifications) {
    MSHookIvar<UIView *>(self, "_overlayMaterialView").backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    CAFilter* filter = [CAFilter filterWithName:@"vibrantDark"];
    [filter setDefaults];
    [[MSHookIvar<UIView *>(self, "_titleLabel") layer] setFilters:[NSArray arrayWithObject:filter]];
    [[MSHookIvar<UIView *>(self, "_glyphView") layer] setFilters:[NSArray arrayWithObject:filter]];
  }
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && notifications && arg1 == YES) {
    MSHookIvar<UIView *>(self, "_overlayMaterialView").backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.34];
  }
  if (enabled && notifications && arg1 == NO) {
    MSHookIvar<UIView *>(self, "_overlayMaterialView").backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
  }
}
%end

// Widgets
%hook WGWidgetPlatterView
- (void)layoutSubviews {
  %orig;

  if (enabled && widgets) {
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *headColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    UIColor *mainColor = [UIColor colorWithWhite:0.0 alpha:0.5];

    UIView *headerOverlayView = MSHookIvar<UIView *>(self, "_headerOverlayView");
    UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");
    [headerOverlayView setBackgroundColor:headColor];
    [mainOverlayView setBackgroundColor:mainColor];

    MTPlatterHeaderContentView *headerContentView = [self _headerContentView];
    [[[headerContentView _titleLabel] layer] setFilters:nil];
    [[headerContentView _titleLabel] setTextColor:whiteColor];

    if ([self showMoreButton]) {
      [[[[self showMoreButton] titleLabel] layer] setFilters:nil];
      [[self showMoreButton] setTitleColor:whiteColor forState:UIControlStateNormal];
    }
  }
}
%end

// Search Bar
%hook SPUIHeaderBlurView
- (void)layoutSubviews {
  %orig;
  if (enabled && widgets) {
    ((UIVisualEffectView*)self).effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  }
}
%end

// Folders
%hook SBFolderBackgroundView
- (void)layoutSubviews {
  %orig;

  if (enabled && folders) {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIVisualEffectView* folderBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    MSHookIvar<UIVisualEffectView*>(self, "_blurView") = folderBackgroundView;
    [MSHookIvar<UIVisualEffectView*>(self, "_blurView") setFrame:self.bounds];
    [self addSubview:folderBackgroundView];
  }
}
%end

%hook SBFolderIconBackgroundView
- (void)setWallpaperBackgroundRect:(CGRect)rect forContents:(CGImageRef)contents withFallbackColor:(CGColorRef)fallbackColor {
  if (enabled && folders) {
  	%orig(CGRectNull, nil, nil);
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
  } else {
    %orig;
  }
}
%end


// Dock
%hook SBWallpaperEffectView
- (void)layoutSubviews {
  %orig;
  if ([self.superview isKindOfClass:%c(SBDockView)]) {
    if (enabled && dock) {
      self.wallpaperStyle = 14;
    }
  }
}
%end

// Keyboard
%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)light {
  if (enabled && keyboard) {
    %orig(NO);
  } else {
    %orig;
  }
}
%end

// Initialize
%ctor {
  settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.skitty.dune.plist"];

  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.skitty.dune.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

  refreshPrefs();
	%init;

	if ([(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"]) {
		if ([[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"]) {
			if ([[[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"] isEqualToString:[NSString stringWithFormat:@"com.apple.widget-extension"]]) {
        %init(Widget);
			}
		}
	}
}
