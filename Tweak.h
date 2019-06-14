// Dune Headers
// This file is kind of a mess, but hey. It works.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern "C" {
  CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);
}

@interface MTPlatterHeaderContentView : UIView
- (UILabel *)_titleLabel;
- (UILabel *)_dateLabel;
@end

@interface NCNotificationContentView : UIView
- (UILabel *)_secondaryTextView;
- (UILabel *)_primaryLabel;
- (UILabel *)_primarySubtitleLabel;
- (UILabel *)_secondaryLabel;
- (UILabel *)_summaryLabel;
@end

@interface NCNotificationShortLookView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(NSNotification *)notification;
-(MTPlatterHeaderContentView *)_headerContentView;
@end

@interface NCNotificationLongLookView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(NSNotification *)notification;
@property (nonatomic, readonly) UIView *customContentView;
@end

@interface BSUIEmojiLabelView : UIView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkTextColor;
@property (nonatomic, retain) UIColor *lightTextColor;
@property (nonatomic, retain) UIColor *textColor;
- (void)duneToggled:(NSNotification *)notification;
@end

@interface NCNotificationViewControllerView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(NSNotification *)notification;
@end

@interface NCNotificationListCellActionButton : UIView
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(id)arg1;
@end

@interface NCToggleControl : UIView
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(id)arg1;
@end

@interface WGWidgetPlatterView : UIView
@property (nonatomic, readonly) UIButton *showMoreButton;
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(id)arg1;
- (MTPlatterHeaderContentView *)_headerContentView;
@end

@interface WGShortLookStyleButton : UIButton
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(id)arg1;
@end

@interface SPUIHeaderBlurView : UIVisualEffectView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIVisualEffect *lightBlur;
@property (nonatomic, retain) UIVisualEffect *darkBlur;
- (void)duneToggled:(id)arg1;
@end

@interface SBWallpaperEffectView : UIView
@property (nonatomic, assign) long long wallpaperStyle;
- (void)duneToggled:(id)arg1;
- (id)initWithWallpaperVariant:(long long)variant;
- (void)setStyle:(long long)style;
@end

@interface SBFolderBackgroundView : UIView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) NSArray *lightSubviews;
@property (nonatomic, retain) UIVisualEffectView *darkBlurView;
@property (nonatomic, retain) UIVisualEffectView *lightBlurView;
- (void)duneToggled:(id)arg1;
@end

@interface SBFolderIconImageView : UIImageView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) SBWallpaperEffectView *darkBackgroundView;
- (void)duneToggled:(id)arg1;
@end

@interface SBFolderIconBackgroundView : UIView
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) NSArray *wallpaperItems;
- (void)setWallpaperBackgroundRect:(CGRect)arg1 forContents:(CGImageRef)arg2 withFallbackColor:(CGColorRef)arg3;
- (void)duneToggled:(id)arg1;
@end

@interface SBFolderIconView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(id)arg1;
- (UIView *)iconBackgroundView;
@end

@interface UIKBRenderConfig : UIView
@end

@interface CAFilter : NSObject
+ (CAFilter*)filterWithType:(NSString*)type;
+ (CAFilter*)filterWithName:(NSString*)name;
- (id)initWithType:(NSString*)type;
- (id)initWithName:(NSString*)name;
- (void)setDefaults;
@end

@interface MTMaterialView : UIView
@end

@interface UIInterfaceAction : NSObject
@property (nonatomic, assign) bool enabled;
@property (nonatomic, assign) UIColor *titleTextColor;
@end

@interface PLInterfaceActionGroupView : UIView
@property (nonatomic, readonly) NSArray *actions;
@end

@interface MTVibrantStylingProvider : NSObject
@end

@interface MTSystemPlatterMaterialSettings : NSObject
@property (nonatomic, assign) UIColor *tintColor;
@end

@interface _UIBackdropView : UIView
@property (assign,nonatomic) long long style;
- (void)transitionToStyle:(NSInteger)style;
@end

@interface SBUIIconForceTouchWrapperViewController : UIViewController
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(id)arg1;
@end

@interface SBUIActionView : UIView
@property (nonatomic, assign) bool isObserving;
- (void)duneToggled:(id)arg1;
@end

@interface SBUIActionViewLabel : UILabel
@end

@interface _UINavigationBarLargeTitleView
@property (nonatomic,readonly) UILabel *accessibilityTitleView;
@end

@interface CALayer (Dune)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) NSArray *darkFilters;
@property (nonatomic, retain) NSArray *lightFilters;
@property (nonatomic, retain) CAFilter *darkFilter;
@property (nonatomic, retain) CAFilter *lightFilter;
- (void)duneToggled:(id)arg1;
- (void)setDuneEnabled:(bool)arg1;
@end

@interface UILabel (Dune)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkTextColor;
@property (nonatomic, retain) UIColor *lightTextColor;
- (void)duneToggled:(id)arg1;
- (void)setDuneEnabled:(bool)arg1;
@end

@interface UIButton (Dune)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkTintColor;
@property (nonatomic, retain) UIColor *lightTintColor;
- (void)duneToggled:(id)arg1;
- (void)setDuneEnabled:(bool)arg1;
@end

@interface UITextView (Dune)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkTextColor;
@property (nonatomic, retain) UIColor *lightTextColor;
- (void)duneToggled:(id)arg1;
- (void)setDuneEnabled:(bool)arg1;
@end

@interface UIView (Dune)
@property (nonatomic, assign) bool isObserving;
@property (nonatomic, retain) UIColor *darkBackgroundColor;
@property (nonatomic, retain) UIColor *lightBackgroundColor;
@property (nonatomic, retain) NSNumber *darkAlpha;
@property (nonatomic, retain) NSNumber *lightAlpha;
- (void)layoutDune;
- (void)duneToggled:(id)arg1;
- (void)setDuneEnabled:(bool)arg1;
+ (void)crash;
- (void)crash;
@end

@interface CCUIRoundButton : UIControl
@property (nonatomic, retain) MTMaterialView *normalStateBackgroundView;
- (void)_unhighlight;
- (void)setHighlighted:(bool)arg1;
@end

@interface CCUILabeledRoundButton : UIView
@property (nonatomic, assign) bool centered;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic, assign) bool labelsVisible;
@property (nonatomic, retain) CCUIRoundButton *buttonView;
- (id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3;
- (void)updatePosition;
@end

@interface CCUILabeledRoundButtonViewController : UIViewController
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic, retain) UIColor *highlightColor;
@property (nonatomic, assign) bool labelsVisible;
@property (nonatomic, retain) CCUILabeledRoundButton *buttonContainer;
@property (nonatomic, retain) CCUIRoundButton *button;
-(id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 ;
@end

@interface CCUIDisplayBackgroundViewController : UIViewController
@property (nonatomic, retain) CCUILabeledRoundButtonViewController *nightShiftButton;
@property (nonatomic, retain) CCUILabeledRoundButtonViewController *trueToneButton;
@end

@interface CCUIContentModuleContainerViewController : UIViewController
@property (nonatomic,copy) NSString *moduleIdentifier;
@property (nonatomic,retain) CCUIDisplayBackgroundViewController *backgroundViewController;
@property (nonatomic, retain) CCUILabeledRoundButtonViewController *darkButton;
@end

@interface CAPackage : NSObject
@property (readonly) CALayer *rootLayer;
@property (readonly) BOOL geometryFlipped;
+ (id)packageWithContentsOfURL:(id)arg1 type:(id)arg2 options:(id)arg3 error:(id)arg4;
- (id)_initWithContentsOfURL:(id)arg1 type:(id)arg2 options:(id)arg3 error:(id)arg4;
@end

extern NSString const *kCAPackageTypeCAMLBundle;

@interface CCUICAPackageView : UIView
@property (nonatomic, retain) CAPackage *package;
- (void)setStateName:(id)arg1;
@end

@interface CCUIDuneButton : CCUIRoundButton
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) CCUICAPackageView *packageView;
- (id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3;
- (void)updateStateAnimated:(bool)arg1;
@end
