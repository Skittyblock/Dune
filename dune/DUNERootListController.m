#include "DUNERootListController.h"

#define kTintColor [UIColor colorWithRed:0.09 green:0.12 blue:0.16 alpha:1.0]

@interface DUNEHeader : UITableViewCell {
  UILabel *label;
  UILabel *underLabel;
}
@end

@implementation DUNEHeader
- (id)initWithSpecifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
  if (self) {
		#define kWidth [[UIApplication sharedApplication] keyWindow].frame.size.width
		CGRect labelFrame = CGRectMake(0, -15, kWidth, 80);
		CGRect underLabelFrame = CGRectMake(0, 35, kWidth, 60);

		label = [[UILabel alloc] initWithFrame:labelFrame];
		[label setNumberOfLines:1];
		label.font = [UIFont systemFontOfSize:50];
		[label setText:@"Dune"];
		//[label setBackgroundColor:[UIColor clearColor]];
		label.textColor = kTintColor;
		label.textAlignment = NSTextAlignmentCenter;

		underLabel = [[UILabel alloc] initWithFrame:underLabelFrame];
		[underLabel setNumberOfLines:1];
		underLabel.font = [UIFont systemFontOfSize:20];
		[underLabel setText:@"A Free iOS Dark Mode"];
		//[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;

		[self addSubview:label];
		[self addSubview:underLabel];
  }
  return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  CGFloat prefHeight = 75.0;
  return prefHeight;
}
@end

@implementation DUNERootListController
- (id)init {
	self = [super init];
	if (self) {
    UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
    self.navigationItem.rightBarButtonItem = respringButton;
	}
	return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)respring {
  NSTask *task = [[[NSTask alloc] init] autorelease];
  [task setLaunchPath:@"/usr/bin/killall"];
  [task setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
  [task launch];
}
@end
