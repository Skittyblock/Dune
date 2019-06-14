// Dune, by Skitty
// iOS 13's Dark Mode for iOS 11/12

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
static BOOL searchbar;
static int mode;

static CGRect ccBounds;
static BOOL trueTone;

static UIImage *nightImage;
static UIImage *toneImage;

static NSBundle *localizeBundle = [NSBundle bundleWithPath:@"/Library/Application Support/Dune/Localization.bundle"];

// Toggle Notifications
static void setDuneEnabled(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  enabled = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.dune.update" object:nil userInfo:nil];

  NSMutableDictionary *eclipsePreferences = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gmoran.eclipse.plist"]];
  if (eclipsePreferences) {
    [eclipsePreferences setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
    [eclipsePreferences writeToFile:@"/var/mobile/Library/Preferences/com.gmoran.eclipse.plist" atomically:YES];
  }
}

static void setDuneDisabled(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  enabled = NO;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.dune.update" object:nil userInfo:nil];

  NSMutableDictionary *eclipsePreferences = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gmoran.eclipse.plist"]];
  if (eclipsePreferences) {
    [eclipsePreferences setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
    [eclipsePreferences writeToFile:@"/var/mobile/Library/Preferences/com.gmoran.eclipse.plist" atomically:YES];
  }
}

static void duneEnabled() {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.skitty.dune.enabled"), nil, nil, true);
}

static void duneDisabled() {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.skitty.dune.disabled"), nil, nil, true);
}

// Preference Updates
static void refreshPrefs() {
  CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.skitty.dune"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
  if(keyList) {
    settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("com.skitty.dune"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
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
  searchbar = [([settings objectForKey:@"searchbar"] ?: @(NO)) boolValue];
  mode = [([settings objectForKey:@"mode"] ?: 0) floatValue];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.dune.update" object:nil userInfo:nil];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
  if (enabled) {
    duneEnabled();
  } else {
    duneDisabled();
  }
}

// Widget Hooks
%group Extension
%hook UILabel
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTextColor;
%property (nonatomic, retain) UIColor *lightTextColor;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.darkTextColor = [UIColor whiteColor];
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
- (void)setTextColor:(UIColor *)color {
  if (!self.isObserving) {
    self.darkTextColor = [UIColor whiteColor];
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
  if (color != self.darkTextColor) {
    self.lightTextColor = color;
  }
  if (self.darkTextColor && enabled && widgets) {
    %orig(self.darkTextColor);
  } else {
    %orig;
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  if (self.darkTextColor) {
    if (enabled) {
      self.textColor = self.darkTextColor;
    } else {
      self.textColor = self.lightTextColor;
    }
  }
}
%end

%hook UIButton
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTintColor;
%property (nonatomic, retain) UIColor *lightTintColor;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.darkTintColor = [UIColor whiteColor];
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
- (void)setTintColor:(UIColor *)color {
  if (color != self.darkTintColor) {
    self.lightTintColor = color;
  }
  if (self.darkTintColor && enabled && widgets) {
    %orig(self.darkTintColor);
  } else {
    %orig;
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  [self setDuneEnabled:enabled];
}
%new
- (void)setDuneEnabled:(bool)enable {
  if (self.darkTintColor) {
    if (enable) {
      self.tintColor = self.darkTintColor;
    } else {
      self.tintColor = self.lightTintColor;
    }
  }
}
%end

%hook UIActivityIndicatorView
- (void)setColor:(UIColor *)color {
  if (enabled) {
    %orig([UIColor whiteColor]);
  } else {
    %orig;
  }
}
%end
%end

%group Invert
%hook CALayer
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) NSArray *darkFilters;
%property (nonatomic, retain) NSArray *lightFilters;
%property (nonatomic, retain) CAFilter *darkFilter;
%property (nonatomic, retain) CAFilter *lightFilter;
- (void)layoutSublayers {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
  }
  [self duneToggled:nil];
}
- (void)setFilters:(NSArray *)filters {
  if (self.filters != self.darkFilters) {
    self.lightFilters = self.filters;
  }
  %orig;
}
- (void)setCompositingFilter:(CAFilter *)filter {
  if (self.compositingFilter != self.darkFilter) {
    self.lightFilter = self.compositingFilter;\
  }
  %orig;
}
%new
- (void)duneToggled:(NSNotification *)notification {
  if (self.filters && !self.darkFilters) {
    CAFilter *colorInvert = [CAFilter filterWithName:@"colorInvert"];
    [colorInvert setDefaults];
    [self setDarkFilters:[NSArray arrayWithObject:colorInvert]];
  }
  if (self.compositingFilter && !self.darkFilter) {
    CAFilter *colorInvert = [CAFilter filterWithName:@"colorInvert"];
    [colorInvert setDefaults];
    [self setDarkFilter:colorInvert];
  }
  if (enabled && widgets) {
    [self setDuneEnabled:YES];
  } else {
    [self setDuneEnabled:NO];
  }
}
%new
- (void)setDuneEnabled:(bool)enable {
  if (self.darkFilters) {
    if (enable) {
      self.filters = self.darkFilters;
    } else {
      self.filters = self.lightFilters;
    }
  }
  if (self.darkFilter) {
    if (enable) {
      self.compositingFilter = self.darkFilter;
    } else {
      self.compositingFilter = self.lightFilter;
    }
  }
}
%end
%end

%group SpringBoard
// Darkened Objects
%hook CALayer
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) NSArray *darkFilters;
%property (nonatomic, retain) NSArray *lightFilters;
- (void)setFilters:(NSArray *)filters {
  if (filters && ![filters isEqual:self.darkFilters]) {
    self.lightFilters = filters;
    if (enabled && self.darkFilters) {
      %orig(self.darkFilters);
    }
  }
  %orig;
}
%new
- (void)setDuneEnabled:(bool)enable {
  if (self.darkFilters) {
    if (enable) {
      self.filters = self.darkFilters;
    } else {
      self.filters = self.lightFilters;
    }
  }
}
%end

%hook UILabel
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTextColor;
%property (nonatomic, retain) UIColor *lightTextColor;
- (void)setTextColor:(UIColor *)color {
  if (color && ![color isEqual:self.darkTextColor]) {
    self.lightTextColor = color;
  }
  %orig;
}
%new
- (void)setDuneEnabled:(bool)enable {
  if (self.darkTextColor) {
    if (enable) {
      self.textColor = self.darkTextColor;
    } else {
      self.textColor = self.lightTextColor;
    }
  }
}
%end

%hook UITextView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTextColor;
%property (nonatomic, retain) UIColor *lightTextColor;
- (void)setTextColor:(UIColor *)color {
  if (color && ![color isEqual:self.darkTextColor]) {
    self.lightTextColor = color;
  }
  %orig;
}
%new
- (void)setDuneEnabled:(bool)enable {
  if (self.darkTextColor) {
    if (enable) {
      self.textColor = self.darkTextColor;
    } else {
      self.textColor = self.lightTextColor;
    }
  }
}
%end

%hook UIView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkBackgroundColor;
%property (nonatomic, retain) UIColor *lightBackgroundColor;
%property (nonatomic, retain) NSNumber *darkAlpha;
%property (nonatomic, retain) NSNumber *lightAlpha;
- (void)setBackgroundColor:(UIColor *)color {
  if (color && ![color isEqual:self.darkBackgroundColor]) {
    self.lightBackgroundColor = color;
  }
  %orig;
}
- (void)setAlpha:(CGFloat)alpha {
  if (alpha && alpha != [self.darkAlpha floatValue]) {
    self.lightAlpha = [NSNumber numberWithFloat:alpha];
  }
  %orig;
}
%new
- (void)setDuneEnabled:(bool)enable {
 if (self.darkBackgroundColor) {
    if (enable) {
      self.backgroundColor = self.darkBackgroundColor;
    } else {
      self.backgroundColor = self.lightBackgroundColor;
    }
  }
  if (self.darkAlpha) {
    if (enable) {
      self.alpha = [self.darkAlpha floatValue];
    } else {
      self.alpha = [self.lightAlpha floatValue];
    }
  }
}
%end

%hook BSUIEmojiLabelView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) UIColor *darkTextColor;
%property (nonatomic, retain) UIColor *lightTextColor;
- (void)layoutSubviews {
  %orig;
  if ([self.superview.superview isKindOfClass:%c(NCNotificationContentView)] && !self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
- (void)setTextColor:(UIColor *)color {
  if (color && ![color isEqual:self.darkTextColor]) {
    self.lightTextColor = color;
  }
  %orig;
}
%new
- (void)duneToggled:(NSNotification *)notification {
  if (!self.layer.darkFilters) {
    CAFilter* filter = [CAFilter filterWithName:@"colorInvert"];
    [filter setDefaults];
    [[self layer] setDarkFilters:[NSArray arrayWithObject:filter]];
  }
  if (enabled && notifications) {
    [[self layer] setDuneEnabled:YES];
  } else {
    [[self layer] setDuneEnabled:NO];
  }
}
%new
- (void)setDuneEnabled:(bool)enable {
  if (self.darkTextColor) {
    if (enable) {
      self.textColor = self.darkTextColor;
    } else {
      self.textColor = self.lightTextColor;
    }
  }
}
%end

// Notifications
%hook NCNotificationShortLookView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
  }
  [self duneToggled:nil];
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");

  if (mainOverlayView.backgroundColor != nil) {
    if (enabled && notifications && arg1 == YES ) {
      UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.4];
      if (mode == 1) {
        blackColor = [UIColor colorWithWhite:0.0 alpha:0.5];
      } else if (mode == 2) {
        blackColor = [UIColor colorWithWhite:0.0 alpha:0.9];
      }
      mainOverlayView.backgroundColor = blackColor;
    }
    if (enabled && notifications && arg1 == NO) {
      UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.5];
      if (mode == 1) {
        blackColor = [UIColor colorWithWhite:0.0 alpha:0.6];
      } else if (mode == 2) {
        blackColor = [UIColor colorWithWhite:0.0 alpha:1.0];
      }
      mainOverlayView.backgroundColor = blackColor;
    }
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");
  MTPlatterHeaderContentView *headerContentView = [self _headerContentView];
  NCNotificationContentView *notificationContentView = MSHookIvar<NCNotificationContentView *>(self, "_notificationContentView");

  UIColor *whiteColor = [UIColor whiteColor];
  UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  if (mode == 1) {
    blackColor = [UIColor colorWithWhite:0.0 alpha:0.6];
  } else if (mode == 2) {
    blackColor = [UIColor colorWithWhite:0.0 alpha:1.0];
  }

  // Do Not Disturb fix
  if (mainOverlayView.backgroundColor != nil) {
    [mainOverlayView setDarkBackgroundColor:blackColor];

    [[[headerContentView _titleLabel] layer] setDarkFilters:[[NSArray alloc] init]];
    [[[headerContentView _dateLabel] layer] setDarkFilters:[[NSArray alloc] init]];
    [[headerContentView _titleLabel] setDarkTextColor:whiteColor];
    [[headerContentView _dateLabel] setDarkTextColor:whiteColor];

    [[notificationContentView _secondaryTextView] setDarkTextColor:whiteColor];
    [[notificationContentView _primaryLabel] setDarkTextColor:whiteColor];
    [[notificationContentView _primarySubtitleLabel] setDarkTextColor:whiteColor];

    if ([notificationContentView respondsToSelector:@selector(_secondaryLabel)]) [[notificationContentView _secondaryLabel] setDarkTextColor:whiteColor];
    if ([notificationContentView respondsToSelector:@selector(_summaryLabel)]) [[notificationContentView _summaryLabel] setDarkTextColor:whiteColor];
  }

  if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
    MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView").darkBackgroundColor = [UIColor clearColor];
  }

  if (enabled && notifications && mainOverlayView.backgroundColor != nil) {
    [mainOverlayView setDuneEnabled:YES];
    [[headerContentView _titleLabel] setDuneEnabled:YES];
    [[headerContentView _dateLabel] setDuneEnabled:YES];
    [[[headerContentView _titleLabel] layer] setDuneEnabled:YES];
    [[[headerContentView _dateLabel] layer] setDuneEnabled:YES];
    [[notificationContentView _secondaryTextView] setDuneEnabled:YES];
    [[notificationContentView _primaryLabel] setDuneEnabled:YES];
    [[notificationContentView _primarySubtitleLabel] setDuneEnabled:YES];
    if ([notificationContentView respondsToSelector:@selector(_secondaryLabel)]) [[notificationContentView _secondaryLabel] setDuneEnabled:YES];
    if ([notificationContentView respondsToSelector:@selector(_summaryLabel)]) [[notificationContentView _summaryLabel] setDuneEnabled:YES];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
      [MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView") setDuneEnabled:YES];
    }
  } else if (mainOverlayView.backgroundColor != nil) {
    [mainOverlayView setDuneEnabled:NO];
    [[headerContentView _titleLabel] setDuneEnabled:NO];
    [[headerContentView _dateLabel] setDuneEnabled:NO];
    [[[headerContentView _titleLabel] layer] setDuneEnabled:NO];
    [[[headerContentView _dateLabel] layer] setDuneEnabled:NO];
    [[notificationContentView _secondaryTextView] setDuneEnabled:NO];
    [[notificationContentView _primaryLabel] setDuneEnabled:NO];
    [[notificationContentView _primarySubtitleLabel] setDuneEnabled:NO];
    if ([notificationContentView respondsToSelector:@selector(_secondaryLabel)]) [[notificationContentView _secondaryLabel] setDuneEnabled:NO];
    if ([notificationContentView respondsToSelector:@selector(_summaryLabel)]) [[notificationContentView _summaryLabel] setDuneEnabled:NO];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
      [MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView") setDuneEnabled:YES];
    }
  }
}
%end

// Widgets
%hook WGWidgetPlatterView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  UIView *headerOverlayView = MSHookIvar<UIView *>(self, "_headerOverlayView");
  UIView *mainOverlayView = MSHookIvar<UIView *>(self, "_mainOverlayView");
  MTPlatterHeaderContentView *headerContentView = [self _headerContentView];

  UIColor *whiteColor = [UIColor whiteColor];
  UIColor *headColor = [UIColor colorWithWhite:0.0 alpha:0.6];
  UIColor *mainColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  if (mode == 1) {
    headColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    mainColor = [UIColor colorWithWhite:0.0 alpha:0.6];
  } else if (mode == 2) {
    headColor = [UIColor blackColor];
    mainColor = [UIColor blackColor];
  }

  [headerOverlayView setDarkBackgroundColor:headColor];
  [mainOverlayView setDarkBackgroundColor:mainColor];

  if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
    MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView").darkBackgroundColor = [UIColor clearColor];
  }

  if (enabled && widgets) {
    [headerOverlayView setDuneEnabled:YES];
    [mainOverlayView setDuneEnabled:YES];
    [[[headerContentView _titleLabel] layer] setDarkFilters:[[NSArray alloc] init]];
    [[[headerContentView _titleLabel] layer] setDuneEnabled:YES];
    [[headerContentView _titleLabel] setDarkTextColor:whiteColor];
    [[headerContentView _titleLabel] setDuneEnabled:YES];
    if ([self showMoreButton]) {
      [[[[self showMoreButton] titleLabel] layer] setDarkFilters:[[NSArray alloc] init]];
      [[[[self showMoreButton] titleLabel] layer] setDuneEnabled:YES];
      [[self showMoreButton] setTitleColor:whiteColor forState:UIControlStateNormal];
    }
    if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
      [MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView") setDuneEnabled:YES];
    }
  } else {
    [headerOverlayView setDuneEnabled:NO];
    [mainOverlayView setDuneEnabled:NO];
    [[headerContentView _titleLabel] setDuneEnabled:NO];
    [[[headerContentView _titleLabel] layer] setDuneEnabled:NO];
    if ([self showMoreButton]) {
      [[[[self showMoreButton] titleLabel] layer] setDuneEnabled:NO];
    }
    if ([[[UIDevice currentDevice] systemVersion] compare:@"12.0" options:NSNumericSearch] == NSOrderedAscending) {
      [MSHookIvar<UIView *>(MSHookIvar<_UIBackdropView *>(MSHookIvar<UIView *>(self, "_backgroundView"), "_backdropView"), "_colorTintView") setDuneEnabled:NO];
    }
  }
}
%end

// Notification 3D Touch
%hook NCNotificationLongLookView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  UIColor *whiteColor = [UIColor whiteColor];

  NCNotificationContentView *notificationContentView = MSHookIvar<NCNotificationContentView *>(self, "_notificationContentView");
  UIView *mainContentView = MSHookIvar<UIView *>(self, "_mainContentView");
  NCNotificationContentView *headerContentView = MSHookIvar<NCNotificationContentView *>(self, "_headerContentView");
  UIView *headerDivider = MSHookIvar<UIView *>(self, "_headerDivider");

  if (!notificationContentView.darkBackgroundColor) {
    notificationContentView.darkBackgroundColor = [UIColor blackColor];
    mainContentView.darkBackgroundColor = [UIColor blackColor];
    self.customContentView.darkBackgroundColor = [UIColor blackColor];
    headerContentView.darkBackgroundColor = [UIColor blackColor];
    headerDivider.darkBackgroundColor = [UIColor grayColor];

    [[notificationContentView _secondaryTextView] setDarkTextColor:whiteColor];
    [[notificationContentView _primaryLabel] setDarkTextColor:whiteColor];
    [[notificationContentView _primarySubtitleLabel] setDarkTextColor:whiteColor];
  }
  if (enabled && notification3d) {
    [notificationContentView setDuneEnabled:YES];
    [mainContentView setDuneEnabled:YES];
    [self.customContentView setDuneEnabled:YES];
    [headerContentView setDuneEnabled:YES];
    [headerDivider setDuneEnabled:YES];
    [[notificationContentView _secondaryTextView] setDuneEnabled:YES];
    [[notificationContentView _primaryLabel] setDuneEnabled:YES];
    [[notificationContentView _primarySubtitleLabel] setDuneEnabled:YES];
  } else {
    [notificationContentView setDuneEnabled:NO];
    [mainContentView setDuneEnabled:NO];
    [self.customContentView setDuneEnabled:NO];
    [headerContentView setDuneEnabled:NO];
    [headerDivider setDuneEnabled:NO];
    [[notificationContentView _secondaryTextView] setDuneEnabled:NO];
    [[notificationContentView _primaryLabel] setDuneEnabled:NO];
    [[notificationContentView _primarySubtitleLabel] setDuneEnabled:NO];
  }
}
%end

// Stacked Notifications
%hook NCNotificationViewControllerView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
  }
  [self duneToggled:nil];
}
%new
- (void)duneToggled:(NSNotification *)notification {
  int count = 0;
  for (UIView *view in self.subviews) {
    if([view isKindOfClass:%c(PLPlatterView)]) {
      UIView *mainOverlayView = MSHookIvar<UIView *>(view, "_mainOverlayView");
      count++;
      if (count == 1) {
        mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.24];
        if (mode == 1) {
          mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.34];
        } else if (mode == 2) {
          mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.84];
        }
      } else if (count == 2) {
        mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.34];
        if (mode == 1) {
          mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.44];
        } else if (mode == 2) {
          mainOverlayView.darkAlpha = [NSNumber numberWithFloat:0.94];
        }
      }
      mainOverlayView.darkBackgroundColor = [UIColor blackColor];
      MSHookIvar<UIView *>(view, "_mainOverlayView") = mainOverlayView;

      if (enabled && notifications) {
        [MSHookIvar<UIView *>(view, "_mainOverlayView") setDuneEnabled:YES];
      } else {
        [MSHookIvar<UIView *>(view, "_mainOverlayView") setDuneEnabled:NO];
      }
    }
  }
}
%end

// Notification Action Buttons (Manage/View/Clear/Etc.)
%hook NCNotificationListCellActionButton
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
  }
  [self duneToggled:nil];
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && notifications && arg1 == YES) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.34];
    if (mode == 1) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    } else if (mode == 2) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:0.9];
    }
    MSHookIvar<UIView *>(self, "_backgroundOverlayView").backgroundColor = blackColor;
  }
  if (enabled && notifications && arg1 == NO) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    if (mode == 1) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
    } else if (mode == 2) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    }
    MSHookIvar<UIView *>(self, "_backgroundOverlayView").backgroundColor = blackColor;
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  UIView *backgroundOverlayView = MSHookIvar<UIView *>(self, "_backgroundOverlayView");
  UILabel *titleLabel = MSHookIvar<UILabel *>(self, "_titleLabel");

  UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
  if (mode == 1) {
    blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
  } else if (mode == 2) {
    blackColor = [UIColor colorWithWhite:0.0 alpha:1.0];
  }
  backgroundOverlayView.darkBackgroundColor = blackColor;
  [titleLabel.layer setDarkFilters:[[NSArray alloc] init]];

  if (enabled && notifications) {
    [backgroundOverlayView setDuneEnabled:YES];
    [titleLabel.layer setDuneEnabled:YES];
  } else {
    [backgroundOverlayView setDuneEnabled:NO];
    [titleLabel.layer setDuneEnabled:NO];
  }
}
%end

// NC Clear/Show More/Show Less Buttons
%hook NCToggleControl
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && notifications && arg1 == YES) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.34];
    if (mode == 1) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    } else if (mode == 2) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:0.9];
    }
    MSHookIvar<UIView *>(self, "_overlayMaterialView").backgroundColor = blackColor;
  }
  if (enabled && notifications && arg1 == NO) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    if (mode == 1) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
    } else if (mode == 2) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    }
    MSHookIvar<UIView *>(self, "_overlayMaterialView").backgroundColor = blackColor;
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  UIView *overlayMaterialView = MSHookIvar<UIView *>(self, "_overlayMaterialView");
  UILabel *titleLabel = MSHookIvar<UILabel *>(self, "_titleLabel");
  UIView *glyphView = MSHookIvar<UIView *>(self, "_glyphView");

  UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
  if (mode == 1) {
    blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
  } else if (mode == 2) {
    blackColor = [UIColor colorWithWhite:0.0 alpha:1.0];
  }
  overlayMaterialView.darkBackgroundColor = blackColor;
  CAFilter* filter = [CAFilter filterWithName:@"vibrantDark"];
  [filter setDefaults];
  [titleLabel.layer setDarkFilters:[NSArray arrayWithObject:filter]];
  [glyphView.layer setDarkFilters:[NSArray arrayWithObject:filter]];

  if (enabled && notifications) {
    [overlayMaterialView setDuneEnabled:YES];
    [titleLabel.layer setDuneEnabled:YES];
    [glyphView.layer setDuneEnabled:YES];
  } else {
    [overlayMaterialView setDuneEnabled:NO];
    [titleLabel.layer setDuneEnabled:NO];
    [glyphView.layer setDuneEnabled:NO];
  }
}
%end

// Edit Button
%hook WGShortLookStyleButton
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  UILabel *titleLabel = MSHookIvar<UILabel*>(self, "_titleLabel");
  MTMaterialView *backgroundView = MSHookIvar<MTMaterialView*>(self, "_backgroundView");

  [[titleLabel layer] setDarkFilters:[[NSArray alloc] init]];

  for (UIView *view in backgroundView.subviews) {
    UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.34];
    if (mode == 1) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
    } else if (mode == 2) {
      blackColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    }
    view.darkBackgroundColor = blackColor;
  }

  if (enabled && widgets) {
    [titleLabel.layer setDuneEnabled:YES];
    [titleLabel setDuneEnabled:YES];
    for (UIView *view in backgroundView.subviews) {
      [view setDuneEnabled:YES];
    }
  } else {
    [titleLabel.layer setDuneEnabled:NO];
    [titleLabel setDuneEnabled:NO];
    for (UIView *view in backgroundView.subviews) {
      [view setDuneEnabled:NO];
    }
  }
}
%end

// Search Bar
%hook SPUIHeaderBlurView
- (void)layoutSubviews {
  %orig;
  if (enabled && searchbar) {
    self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  } else {
    self.effect = nil;
  }
}
%end

// Folders
%hook SBFolderBackgroundView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) NSArray *lightSubviews;
%property (nonatomic, retain) UIVisualEffectView *darkBlurView;
%property (nonatomic, retain) UIVisualEffectView *lightBlurView;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  if (!self.lightSubviews) {
    self.lightSubviews = self.subviews;
    self.lightBlurView = MSHookIvar<UIVisualEffectView*>(self, "_blurView");
    self.darkBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.darkBlurView.frame = self.bounds;
    self.darkBlurView.alpha = 0;
  }
  if (enabled && folders) {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.darkBlurView];
    if (mode == 2) {
      self.darkBackgroundColor = [UIColor blackColor];
      [self setDuneEnabled:YES];
    } else {
      MSHookIvar<UIVisualEffectView *>(self, "_blurView") = self.darkBlurView;
      self.darkBlurView.alpha = 1;
    }
  } else {
    if (!self.subviews) {
      for (UIView *view in self.lightSubviews) {
        [self addSubview:view];
      }
    }
    MSHookIvar<UIVisualEffectView *>(self, "_blurView") = self.lightBlurView;
    self.darkBlurView.alpha = 0;
    [self setDuneEnabled:NO];
  }
}
%end

%hook SBFolderIconBackgroundView
- (void)didAddSubview:(id)arg1 {
  return;
}
%end

// Thanks Jake!
%hook SBFolderIconImageView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, retain) SBWallpaperEffectView *darkBackgroundView;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  if (!self.darkBackgroundView) {
    UIView *backgroundView = MSHookIvar<UIView*>(self, "_backgroundView");
    self.darkBackgroundView = [[%c(SBWallpaperEffectView) alloc] initWithWallpaperVariant:1];
    [self.darkBackgroundView setFrame:backgroundView.bounds];
    [self.darkBackgroundView setStyle:14];
    self.darkBackgroundView.backgroundColor = [UIColor blackColor];
    self.darkBackgroundView.alpha = 1;
    self.darkBackgroundView.layer.cornerRadius = backgroundView.layer.cornerRadius;
    self.darkBackgroundView.layer.masksToBounds = backgroundView.layer.masksToBounds;
    [backgroundView addSubview:self.darkBackgroundView];
  }
  if (enabled && folders && mode != 2) {
    self.darkBackgroundView.alpha = 1;
    [self.darkBackgroundView setStyle:14];
  } else if (enabled && folders && mode == 2) {
    self.darkBackgroundView.alpha = 1;
    [self.darkBackgroundView setStyle:0];
  } else {
    self.darkBackgroundView.alpha = 0;
  }
}
%end

// Dock
%hook SBWallpaperEffectView
- (void)layoutSubviews {
  %orig;
  if ([self.superview isKindOfClass:%c(SBDockView)]) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  if (enabled && dock && mode != 2) {
    self.wallpaperStyle = 14;
  } else if (enabled && dock && mode == 2) {
    self.wallpaperStyle = 0;
    self.backgroundColor = [UIColor blackColor];
  } else {
    self.wallpaperStyle = 12;
  }
}
%end

@interface SBFloatingDockPlatterView : UIView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, assign) long long lightStyle;
- (void)duneToggled:(id)arg1;
@end

%hook SBFloatingDockPlatterView
%property (nonatomic, assign) bool isObserving;
%property (nonatomic, assign) long long lightStyle;
- (void)layoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
  }
  [self duneToggled:nil];
}
%new
- (void)duneToggled:(NSNotification *)notification {
  _UIBackdropView *backgroundView = MSHookIvar<_UIBackdropView*>(self, "_backgroundView");
  if (!self.lightStyle) {
    self.lightStyle = backgroundView.style;
  }
  if (enabled && dock) {
    [backgroundView transitionToStyle:2030];
  } else {
    [backgroundView transitionToStyle:self.lightStyle];
  }
}
%end

// 3D Touch Menus
%hook SBUIIconForceTouchWrapperViewController
%property (nonatomic, assign) bool isObserving;
- (void)viewDidLayoutSubviews {
  %orig;
  if (!self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
  }
  [self duneToggled:nil];
}
%new
- (void)duneToggled:(NSNotification *)notification {
  for (MTMaterialView *materialView in self.view.subviews) {
    for (UIView *view in materialView.subviews) {
      UIColor *blackColor = [UIColor colorWithWhite:0.0 alpha:0.44];
      if (mode == 1) {
        blackColor = [UIColor colorWithWhite:0.0 alpha:0.54];
      } else if (mode == 2) {
        blackColor = [UIColor colorWithWhite:0.0 alpha:1.0];
      }
      view.darkBackgroundColor = blackColor;
      if (enabled && touch3d) {
        [view setDuneEnabled:YES];
      } else {
        [view setDuneEnabled:NO];
      }
    }
  }
}
%end

%hook SBUIActionView
%property (nonatomic, assign) bool isObserving;
- (void)layoutSubviews {
  %orig;
  // I know, this is terrible. I was lazy.
  if ([self.superview.superview.superview.superview.superview.superview.superview.superview isKindOfClass:%c(SBUIIconForceTouchWindow)] && !self.isObserving) {
    self.isObserving = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duneToggled:) name:@"xyz.skitty.dune.update" object:nil];
    [self duneToggled:nil];
  }
}
- (void)setHighlighted:(BOOL)arg1 {
  %orig;
  if (enabled && touch3d && arg1) {
    UIColor *whiteColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    if (mode == 1) {
      whiteColor = [UIColor colorWithWhite:1.0 alpha:0.05];
    } else if (mode == 2) {
      whiteColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    }
    self.backgroundColor = whiteColor;
  } else if (enabled && touch3d && arg1 == NO) {
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
  }
}
%new
- (void)duneToggled:(NSNotification *)notification {
  SBUIActionViewLabel *titleLabel = MSHookIvar<SBUIActionViewLabel*>(self, "_titleLabel");
  SBUIActionViewLabel *subtitleLabel = MSHookIvar<SBUIActionViewLabel*>(self, "_subtitleLabel");
  UILabel *title = MSHookIvar<UILabel*>(titleLabel, "_label");
  UILabel *subtitle = nil;
  if (subtitleLabel) subtitle = MSHookIvar<UILabel*>(subtitleLabel, "_label");
  UIImageView *imageView = MSHookIvar<UIImageView*>(self, "_imageView");

  if (!title.darkTextColor) {
    title.darkTextColor = [UIColor whiteColor];
    if (subtitle) subtitle.darkTextColor = [UIColor whiteColor];
    [title.layer setDarkFilters:[[NSArray alloc] init]];
    if (subtitle) [subtitle.layer setDarkFilters:[[NSArray alloc] init]];
    [imageView.layer setDarkFilters:[[NSArray alloc] init]];
  }
  if (enabled && touch3d) {
    [title setDuneEnabled:YES];
    if (subtitle) [subtitle setDuneEnabled:YES];
    [title.layer setDuneEnabled:YES];
    if (subtitle) [subtitle.layer setDuneEnabled:YES];
    [imageView.layer setDuneEnabled:YES];
    imageView.tintColor = [UIColor whiteColor];
  } else {
    [title setDuneEnabled:NO];
    if (subtitle) [subtitle setDuneEnabled:NO];
    [title.layer setDuneEnabled:NO];
    if (subtitle) [subtitle.layer setDuneEnabled:NO];
    [imageView.layer setDuneEnabled:NO];
    //imageView.tintColor = [UIColor blackColor];
  }
}
%end
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

// Control Center Toggle
%group Toggle
%subclass CCUIDuneButton : CCUIRoundButton
%property (nonatomic, retain) UIView *backgroundView;
%property (nonatomic, retain) CCUICAPackageView *packageView;
- (void)layoutSubviews {
  %orig;
  if (!self.packageView) {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.userInteractionEnabled = NO;
    self.backgroundView.layer.cornerRadius = self.bounds.size.width/2;
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.alpha = 0;
    [self addSubview:self.backgroundView];

    self.packageView = [[%c(CCUICAPackageView) alloc] initWithFrame:self.bounds];
    self.packageView.package = [CAPackage packageWithContentsOfURL:[NSURL fileURLWithPath:@"/Library/Application Support/Dune/StyleMode.ca"] type:kCAPackageTypeCAMLBundle options:nil error:nil];
    [self.packageView
setStateName:@"dark"];
    [self addSubview:self.packageView];

    [self setHighlighted:NO];
    [self updateStateAnimated:NO];
  }
}
- (void)touchesEnded:(id)arg1 withEvent:(id)arg2 {
  %orig;
  if (enabled) {
    duneDisabled();
    CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:NO], CFSTR("com.skitty.dune"));
  } else {
    duneEnabled();
    CFPreferencesSetAppValue((CFStringRef)@"enabled", (CFPropertyListRef)[NSNumber numberWithBool:YES], CFSTR("com.skitty.dune"));
  }

  refreshPrefs();
  [self updateStateAnimated:YES];
}
%new
- (void)updateStateAnimated:(bool)animated {
  if (!enabled) {
    ((CCUILabeledRoundButton *)self.superview).subtitle = [localizeBundle localizedStringForKey:@"LIGHT" value:@"Light" table:nil];
    [self.packageView setStateName:@"light"];
    if (animated) {
      [UIView animateWithDuration:0.3 delay:0 options:nil animations:^{
        self.backgroundView.alpha = 1;
      } completion:nil];
    } else {
      self.backgroundView.alpha = 1;
    }
  } else {
    ((CCUILabeledRoundButton *)self.superview).subtitle = [localizeBundle localizedStringForKey:@"DARK" value:@"Dark" table:nil];
    [self.packageView setStateName:@"dark"];
    if (animated) {
      [UIView animateWithDuration:0.3 delay:0 options:nil animations:^{
        self.backgroundView.alpha = 0;
      } completion:nil];
    } else {
      self.backgroundView.alpha = 0;
    }
  }
}
%end

%hook CCUIContentModuleContainerViewController
%property (nonatomic, retain) CCUILabeledRoundButtonViewController *darkButton;
- (void)setExpanded:(bool)arg1 {
  %orig;
  if (arg1 && ([self.moduleIdentifier isEqual:@"com.apple.control-center.DisplayModule"] || [self.moduleIdentifier isEqual:@"com.jailbreak365.control-center.TinyDisplayModule"])) {
    ccBounds = self.view.bounds;
    if (self.backgroundViewController.trueToneButton) {
      trueTone = YES;
    } else {
      trueTone = NO;
    }
    if (!self.darkButton) {
      self.darkButton = [[%c(CCUILabeledRoundButtonViewController) alloc] initWithGlyphImage:nil highlightColor:nil useLightStyle:NO];
      self.darkButton.buttonContainer = [[%c(CCUILabeledRoundButton) alloc] initWithGlyphImage:nil highlightColor:nil useLightStyle:NO];
      [self.darkButton.buttonContainer setFrame:CGRectMake(0, 0, 72, 91)];
      self.darkButton.view = self.darkButton.buttonContainer;
      self.darkButton.buttonContainer.buttonView = [[%c(CCUIDuneButton) alloc] initWithGlyphImage:nil highlightColor:nil useLightStyle:NO];
      [self.darkButton.buttonContainer addSubview:self.darkButton.buttonContainer.buttonView];
      self.darkButton.button = self.darkButton.buttonContainer.buttonView;

      self.darkButton.title = [localizeBundle localizedStringForKey:@"APPEARANCE" value:@"Appearance" table:nil];
      if (enabled) {
        self.darkButton.subtitle = [localizeBundle localizedStringForKey:@"DARK" value:@"Dark" table:nil];
        [((CCUIDuneButton *)self.darkButton.buttonContainer.buttonView).packageView setStateName:@"dark"];
      } else {
        self.darkButton.subtitle = [localizeBundle localizedStringForKey:@"LIGHT" value:@"Light" table:nil];
        [((CCUIDuneButton *)self.darkButton.buttonContainer.buttonView).packageView setStateName:@"light"];
      }
      [self.darkButton setLabelsVisible:YES];

      [self.backgroundViewController.view addSubview:self.darkButton.buttonContainer];
    }
    [self.darkButton.buttonContainer updatePosition];
    nightImage = self.backgroundViewController.nightShiftButton.buttonContainer.glyphImage;
    [self.backgroundViewController.nightShiftButton.buttonContainer updatePosition];
    if (self.backgroundViewController.trueToneButton) {
      toneImage = self.backgroundViewController.trueToneButton.buttonContainer.glyphImage;
      [self.backgroundViewController.trueToneButton.buttonContainer updatePosition];
    }
    self.darkButton.buttonContainer.alpha = 1;
  }
}
%end

%hook CCUILabeledRoundButton
%property (nonatomic, assign) bool centered;
- (void)setCenter:(CGPoint)center {
  if (self.centered) {
    return;
  } else {
    self.centered = YES;
    %orig;
  }
}
%new
- (void)updatePosition {
  self.centered = NO;
  CGPoint center;
  if ([self.title isEqual: [localizeBundle localizedStringForKey:@"APPEARANCE" value:@"Appearance" table:nil]]) {
    if (ccBounds.size.width < ccBounds.size.height && !trueTone) {
      center.x = ccBounds.size.width/2-ccBounds.size.width*0.192;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else if (!trueTone) {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2-ccBounds.size.width*0.1;
    } else if (ccBounds.size.width < ccBounds.size.height && trueTone) {
      center.x = ccBounds.size.width/2-ccBounds.size.width*0.29;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else if (trueTone) {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2-ccBounds.size.height*0.3;
    }
  } else if (self.glyphImage == nightImage) {
    if (ccBounds.size.width < ccBounds.size.height && !trueTone) {
      center.x = ccBounds.size.width/2+ ccBounds.size.width*0.192;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else if (!trueTone) {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2+ ccBounds.size.width*0.1;
    } else if (ccBounds.size.width < ccBounds.size.height && trueTone) {
      center.x = ccBounds.size.width/2;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else if (trueTone) {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2;
    }
  } else if (trueTone && self.glyphImage == toneImage) {
    if (ccBounds.size.width < ccBounds.size.height) {
      center.x = ccBounds.size.width/2+ccBounds.size.width*0.29;
      center.y = ccBounds.size.height-ccBounds.size.height*0.14;
    } else {
      center.x = ccBounds.size.width-ccBounds.size.width*0.2;
      center.y = ccBounds.size.height/2+ ccBounds.size.height*0.3;
    }
  }
  [self setCenter:center];
}
%end
%end

// Initialize
%ctor {
  refreshPrefs();

  settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.skitty.dune.plist"];
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("xyz.skitty.dune.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, setDuneEnabled, CFSTR("xyz.skitty.dune.enabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, setDuneDisabled, CFSTR("xyz.skitty.dune.disabled"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

  %init;
  %init(Toggle);

  if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
    %init(SpringBoard);
  }

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
