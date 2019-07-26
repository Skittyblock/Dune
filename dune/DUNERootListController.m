// Dune Settings Controller

#include "DUNERootListController.h"

#define kTintColor [UIColor colorWithRed:0.09 green:0.12 blue:0.16 alpha:1.0]

@interface DUNEHeader : UITableViewCell
@end

@implementation DUNEHeader
- (id)initWithSpecifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

  if (self) {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, 60)];
    title.numberOfLines = 1;
    title.font = [UIFont systemFontOfSize:50];
    title.text = @"Dune";
    title.textColor = kTintColor;
    title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:title];

    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, self.frame.size.width, 30)];
    subtitle.numberOfLines = 1;
    subtitle.font = [UIFont systemFontOfSize:20];
    subtitle.text = @"A Free iOS Dark Mode";
    subtitle.textColor = [UIColor grayColor];
    subtitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:subtitle];
  }

  return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  return -150.0;
}
@end

@implementation DUNERootListController
- (NSArray *)specifiers {
  if (!_specifiers) {
    _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
  }

  return _specifiers;
}
@end
