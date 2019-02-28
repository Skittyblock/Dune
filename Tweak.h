// Dune Headers
// This file is kind of a mess, but hey. It works.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTPlatterHeaderContentView : UIView
-(UILabel *)_titleLabel;
-(UILabel *)_dateLabel;
@end

@interface NCNotificationContentView : UIView
-(UILabel *)_secondaryTextView;
-(UILabel *)_primaryLabel;
-(UILabel *)_primarySubtitleLabel;
-(UILabel *)_secondaryLabel;
-(UILabel *)_summaryLabel;
@end

@interface NCNotificationShortLookView : UIView
-(MTPlatterHeaderContentView *)_headerContentView;
@end

@interface NCNotificationLongLookView : UIView
@property (nonatomic, readonly) UIView *customContentView;
@end

@interface BSUIEmojiLabelView : UIView
@end

@interface NCNotificationViewControllerView : UIView
@end

@interface NCNotificationListCellActionButton : UIView
@end

@interface NCToggleControl : UIView
@end

@interface WGWidgetPlatterView : UIView
@property (nonatomic, readonly) UIButton *showMoreButton;
-(MTPlatterHeaderContentView *)_headerContentView;
@end

@interface SPUIHeaderBlurView : UIView
@end

@interface SBFolderBackgroundView : UIView
@end

@interface SBFolderIconBackgroundView : UIView
@end

@interface SBWallpaperEffectView : UIView
@property (nonatomic, assign) long long wallpaperStyle;
@end

@interface UIKBRenderConfig : UIView
@end

@interface CAFilter : NSObject
+(CAFilter*)filterWithType:(NSString*)type;
+(CAFilter*)filterWithName:(NSString*)name;
-(id)initWithType:(NSString*)type;
-(id)initWithName:(NSString*)name;
-(void)setDefaults;
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
