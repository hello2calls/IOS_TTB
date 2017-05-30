//
//  TPHeaderLabel.m
//  TouchPalDialer
//
//  Created by siyi on 16/5/12.
//
//

#import "TPHeaderLabel.h"
#import "TPDialerResourceManager.h"
#import "NSString+TPHandleNil.h"

@implementation TPHeaderLabel
- (instancetype) initWithFrame:(CGRect)frame headerTitle:(NSString *)headerTitle usingDefaultSkin:(BOOL)useDefaultSkin {
    self = [super initWithFrame:frame];
    if (self) {
        _usingDefaultSkin = useDefaultSkin;
        self.text = headerTitle;
        if (useDefaultSkin) {
            [self applyDefaultSkin];
        }
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame headerTitle:(NSString *)headerTitle {
    return [self initWithFrame:frame headerTitle:headerTitle usingDefaultSkin:YES];
}

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame headerTitle:nil];
}

- (instancetype) initWithHeaderTitle:(NSString *)title {
    CGRect frame = CGRectMake((TPScreenWidth() - 100) / 2, TPHeaderBarHeightDiff(), 120, 45);
    return [self initWithFrame:frame headerTitle:title];
}

- (instancetype) initWithDefaultSkin {
    self = [super init];
    if (self) {
        _usingDefaultSkin = YES;
        [self applyDefaultSkin];
    }
    return self;
}

#pragma mark view helpers
- (void) applyDefaultSkin {
    NSDictionary *propertyDict = [[TPDialerResourceManager sharedManager] getPropertyDicInDefaultPackageByStyle:@"defaultLabel_style"];
    NSString *bgColorString = [propertyDict objectForKey:@"backgroundColor_color"];
    NSString *textColorString = [propertyDict objectForKey:@"textColor_color"];
    
    if (![NSString isNilOrEmpty:bgColorString]) {
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:bgColorString];
    }
    if (![NSString isNilOrEmpty:textColorString]) {
        self.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:textColorString];
    }
}

#pragma mark SelfSkinChangeProtocol
- (id) selfSkinChange:(NSString *)style {
    NSDictionary *propertyDict = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    NSString *bgColorString = [propertyDict objectForKey:@"backgroundColor_color"];
    NSString *textColorString = [propertyDict objectForKey:@"textColor_color"];
    
    if (![NSString isNilOrEmpty:bgColorString]) {
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:bgColorString];
    }
    if (![NSString isNilOrEmpty:textColorString]) {
        self.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:textColorString];
    }
    return @(1);
}

@end
