#include "HBLOLinkOpenerListController.h"

@implementation HBLOLinkOpenerListController

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

- (instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = [UIColor colorWithRed:248.f / 255.f green:194.f / 255.f blue:40.f / 255.f alpha:1];
		self.hb_appearanceSettings = appearanceSettings;
	}

	return self;
}

@end
