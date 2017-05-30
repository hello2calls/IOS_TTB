//
//  PersonalCenterEntranceView.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/2/7.
//
//

#import "EntranceIcon.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import "NoahManager.h"
#import "UsageConst.h"
#import "PersonalCenterUtility.h"
#import "CootekNotifications.h"
#import "QueryCallerid.h"
#import "FileUtils.h"
#import "TouchPalVersionInfo.h"
@interface EntranceIcon()

@property (nonatomic, retain) UIView *iconView;

@end


@implementation EntranceIcon{
    UILabel *imageView;
    UIImageView *marketImageView;
}

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat radius = 25;
        CGFloat startX = (frame.size.width - radius) / 2 - 0.5;
        CGFloat startY = (frame.size.height - radius) / 2;
        CGFloat marketRadius = 25;
        CGFloat marketStartX = (frame.size.width - marketRadius) / 2 - 0.5;
        CGFloat marketStartY = (frame.size.height - marketRadius) / 2;
        
        imageView = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, radius, radius)];
        imageView.text = @"l";
        imageView.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
        imageView.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_color"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = radius / 2;
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        
        
        marketImageView = [[UIImageView alloc]initWithFrame:CGRectMake(marketStartX, marketStartY, marketRadius, marketRadius)];
        marketImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:marketImageView];
        
        UIButton *actionBut = [[UIButton alloc]initWithFrame:CGRectMake (0,0,frame.size.width, frame
                                                                         .size.height)];
        [actionBut addTarget:self action:@selector(onClickDown) forControlEvents:UIControlEventTouchDown];
        [actionBut addTarget:self action:@selector(onClickOutsideUp) forControlEvents:UIControlEventTouchUpOutside];
        [actionBut addTarget:self action:@selector(onClickOutsideUp) forControlEvents:UIControlEventTouchCancel];
        [actionBut addTarget:self action:@selector(onClickInsideUp) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:actionBut];
        
        [self addGuideHint];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:GUIDEPOINT_DIALER_MENU object:nil];

    }
    
    return self;
}

- (void)refresh {
    [marketImageView stopAnimating];
    marketImageView.hidden = YES;
    imageView.hidden = NO;
    _iconView.hidden = YES;

    imageView.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_color"];
    BOOL menuShown = [UserDefaultsManager boolValueForKey:SHOULD_MENU_POINT_SHOW defaultValue:YES];
    if (menuShown) {
        ExtensionStaticToast *estToast = [PersonalCenterUtility getPersonalMarketExtensionStaticToast];
            if (estToast && [estToast getDownloadFilePathInner].length > 0) {
                NSString *zipFilePath = [estToast getDownloadFilePathInner];
                NSString *zipFileName = [zipFilePath lastPathComponent];
                NSString *fileName = [zipFilePath stringByDeletingPathExtension];
                    if (![FileUtils checkFileExist:fileName]) {
                        [FileUtils copyFile:zipFileName];
                        [FileUtils unzipFile:zipFileName];
                    }
                    NSArray *gifArray = [PersonalCenterUtility getMarketOutterGifArray:fileName];
                    marketImageView.hidden = NO;
                    marketImageView.animationImages = gifArray;
                    marketImageView.animationDuration = gifArray.count * 0.06;
                    marketImageView.animationRepeatCount = 0;
                    [marketImageView startAnimating];
                    imageView.hidden = YES;
                    _iconView.hidden = YES;
                    imageView.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_color"];
            } else {
                if ([UIDevice currentDevice].systemVersion.floatValue >= 10) {
                    _iconView.hidden = ![UserDefaultsManager boolValueForKey:ANTIHARASS_REDDOT_GUARD defaultValue:YES];
                }
            }
    } else {
        _iconView.hidden = ![UserDefaultsManager boolValueForKey:ANTIHARASS_REDDOT_GUARD defaultValue:YES];

    }
    
}

- (void) addGuideHint {
    _iconView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 16,8, 8,8)];
    _iconView.layer.masksToBounds = YES;
    _iconView.layer.cornerRadius = 4;
    _iconView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
    _iconView.hidden = YES;
    [self addSubview:_iconView];
}

- (void)onClickInsideUp{
    
    imageView.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_color"];
    [[NoahManager sharedPSInstance]getGuidePointClicked:GUIDEPOINT_DIALER_MENU];
    if ([UserDefaultsManager boolValueForKey:SHOULD_MENU_POINT_SHOW defaultValue:YES]) {
        [UserDefaultsManager setBoolValue:NO forKey:SHOULD_MENU_POINT_SHOW];
        [[NSNotificationCenter defaultCenter] postNotificationName:GUIDEPOINT_DIALER_MENU object:nil];
    }
    if ([self.delegate respondsToSelector:@selector(onEntranceClick)] ) {
        [self.delegate onEntranceClick];
    }
    
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_REDDOT_GUARD defaultValue:YES]) {
        [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_REDDOT_GUARD];
    }
}

- (void)onClickOutsideUp {
    imageView.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_color"];
}

- (void)onClickDown {
    imageView.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"];
}

- (id)selfSkinChange:(NSString *)style{
    imageView.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_color"];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}


@end

