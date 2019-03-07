// Dune, by Skitty
// A macOS Mojave-like dark mode for iOS.

#import "Tweak.h"

static NSMutableDictionary *settings;
static BOOL enabled;
static BOOL notifications;
static BOOL notification3d;
static BOOL widgets;
static BOOL touch3d;
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

  enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
  notifications = [([settings objectForKey:@"notifications"] ?: @(YES)) boolValue];
  notification3d = [([settings objectForKey:@"notification3d"] ?: @(YES)) boolValue];
  widgets = [([settings objectForKey:@"widgets"] ?: @(YES)) boolValue];
  touch3d = [([settings objectForKey:@"touch3d"] ?: @(YES)) boolValue];
  folders = [([settings objectForKey:@"folders"] ?: @(YES)) boolValue];
  dock = [([settings objectForKey:@"dock"] ?: @(YES)) boolValue];
  keyboard = [([settings objectForKey:@"keyboard"] ?: @(NO)) boolValue];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}

// Widget Hooks
// Only hooks inside widget (and notification) extension content views to (more or less) change the text white.
%group Extension
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
%end

%group Invert
%hook CALayer
- (void)setFilters:(NSArray *)filters {
  if (enabled && widgets) {
    CAFilter *colorInvert = [CAFilter filterWithName:@"colorInvert"];
    [colorInvert setDefaults];
    %orig([NSArray arrayWithObject:colorInvert]);
  } else {
    %orig;
  }
}
- (void)setCompositingFilter:(CAFilter *)filter {
  if (enabled && widgets && filter) {
    CAFilter *colorInvert = [CAFilter filterWithName:@"colorInvert"];
    [colorInvert setDefaults];
    %orig(colorInvert);
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
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");

  if (mainOverlayView.backgroundColor != nil) {
    if (enabled && notifications && arg1 == YES ) {
      mainOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    }
    if (enabled && notifications && arg1 == NO) {
      mainOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    }
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

// Notification 3D Touch
%hook NCNotificationLongLookView
- (void)layoutSubviews {
  %orig;

  if (enabled && notification3d) {
    UIColor *whiteColor = [UIColor whiteColor];

    NCNotificationContentView *notificationContentView = MSHookIvar<NCNotificationContentView *>(self, "_notificationContentView");
    UIView *mainContentView = MSHookIvar<UIView *>(self, "_mainContentView");
    NCNotificationContentView *headerContentView = MSHookIvar<NCNotificationContentView *>(self, "_headerContentView");
    UIView *headerDivider = MSHookIvar<UIView *>(self, "_headerDivider");

    notificationContentView.backgroundColor = [UIColor blackColor];
    mainContentView.backgroundColor = [UIColor blackColor];
    self.customContentView.backgroundColor = [UIColor blackColor];
    headerContentView.backgroundColor = [UIColor blackColor];
    headerDivider.backgroundColor = [UIColor grayColor];

    [[notificationContentView _secondaryTextView] setTextColor:whiteColor];
    [[notificationContentView _primaryLabel] setTextColor:whiteColor];
    [[notificationContentView _primarySubtitleLabel] setTextColor:whiteColor];
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
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && notifications && arg1 == YES) {
    MSHookIvar<UIView *>(self, "_backgroundOverlayView").backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.34];
  }
  if (enabled && notifications && arg1 == NO) {
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

// Edit Button
%hook WGShortLookStyleButton
- (void)layoutSubviews {
  %orig;

  if (enabled && widgets) {
    UILabel *titleLabel = MSHookIvar<UILabel*>(self, "_titleLabel");
    [[titleLabel layer] setFilters:nil];
    titleLabel.textColor = [UIColor whiteColor];

    MTMaterialView *backgroundView = MSHookIvar<MTMaterialView*>(self, "_backgroundView");
    for (UIView *view in backgroundView.subviews) {
      view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
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
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
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

%hook SBFloatingDockPlatterView
- (void)layoutSubviews {
  %orig;

  if (enabled && dock) {
    _UIBackdropView *backgroundView = MSHookIvar<_UIBackdropView*>(self, "_backgroundView");
    [backgroundView transitionToStyle:2030];
  }
}
%end

// 3D Touch Menus
%hook SBUIIconForceTouchWrapperViewController
- (void)viewDidLayoutSubviews {
  %orig;
  if (enabled && touch3d) {
    for (MTMaterialView *materialView in self.view.subviews) {
      for (UIView *view in materialView.subviews) {
        view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.44];
      }
    }
  }
}
%end

%hook SBUIActionView
- (void)layoutSubviews {
  %orig;
  // I know, this is terrible. I was lazy.
  if ([self.superview.superview.superview.superview.superview.superview.superview.superview isKindOfClass:%c(SBUIIconForceTouchWindow)] && enabled && touch3d) {
    SBUIActionViewLabel *titleLabel = MSHookIvar<SBUIActionViewLabel*>(self, "_titleLabel");
    SBUIActionViewLabel *subtitleLabel = MSHookIvar<SBUIActionViewLabel*>(self, "_subtitleLabel");
    UILabel *title = MSHookIvar<UILabel*>(titleLabel, "_label");
    UILabel *subtitle = nil;
    if (subtitleLabel) subtitle = MSHookIvar<UILabel*>(subtitleLabel, "_label");
    UIImageView *imageView = MSHookIvar<UIImageView*>(self, "_imageView");

    title.textColor = [UIColor whiteColor];
    if (subtitle) subtitle.textColor = [UIColor whiteColor];
    imageView.tintColor = [UIColor whiteColor];

    [[title layer] setFilters:nil];
    if (subtitle) [[subtitle layer] setFilters:nil];
    [[imageView layer] setFilters:nil];
  }
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && touch3d && arg1 == YES) {
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
  }
  if (enabled && touch3d && arg1 == NO) {
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
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
			if (([[[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"] isEqualToString:[NSString stringWithFormat:@"com.apple.widget-extension"]] && widgets) || ([[[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"] isEqualToString:[NSString stringWithFormat:@"com.apple.usernotifications.content-extension"]] && notification3d)) {
        %init(Extension);
			}
      if ([[[(NSDictionary *)[NSBundle mainBundle].infoDictionary valueForKey:@"NSExtension"] valueForKey:@"NSExtensionPointIdentifier"] isEqualToString:[NSString stringWithFormat:@"com.apple.widget-extension"]] && widgets) {
        %init(Invert);
      }
		}
	}
}
