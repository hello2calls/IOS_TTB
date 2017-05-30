//
//  SnowGenerator.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/16.
//
//

#import "SnowGenerator.h"
#import "TouchPalVersionInfo.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "NoahManager.h"

@implementation SnowGenerator {
    __strong NSMutableArray *_snows;
    __strong NSDictionary *_noahBgDic;
    __weak UIView *_holderView;
}

- (id)initWithHolderView:(UIView *)view {
    self = [super init];
    if (self) {
        _snows = [[NSMutableArray alloc] initWithCapacity:25];
        _holderView = view;
        [self checkNoahPushingSnow];
    }
    return self;
}

- (void)stopSnow {
    for (int i=0 ; i<_snows.count; i++) {
        UIImageView *snow = [_snows objectAtIndex:i];
        [snow removeFromSuperview];
    }
    [_snows removeAllObjects];
}

- (void)startSnow{
    int count = arc4random() % 4;
    for (int i=0; i< count; i++) {
        if (_snows.count > 0 && [self getFromOriginals]) {
            
        } else {
            [self createNewSnow];
        }
    }
}

- (BOOL)getFromOriginals {
    if (_snows.count <= 0) {
        return NO;
    }
    for (UIImageView *snow in _snows) {
        if (snow.tag == 1) {
            snow.tag = 0;
            [self animateSnow:snow];
            return YES;
        }
    }
    return NO;
}

- (void)createNewSnow{
    int limitY = 50;
    UIImage *image = nil;
    NSArray *snows = [_noahBgDic objectForKey:@"snows"];
    if (snows.count > 0) {
        int pic = arc4random() % snows.count;
        image = snows[pic];
    } else {
        if (!ENABLE_DEFAULT_SNOW) {
            return;
        }
        int pic = arc4random() % 3 + 1;
        image = [TPDialerResourceManager getImage:[NSString stringWithFormat:@"voip_default_falling_snow%d@2x.png", pic]];
    }
    int x = arc4random() % ((int)TPScreenWidth());
    int sizeSetting = _noahBgDic ? [[[_noahBgDic objectForKey:@"settings"] objectForKey:@"snow_size"] integerValue] : 0;
    int size = 0;
    int y = 0;
    if (sizeSetting == 0) {
        size = image.size.height/(arc4random()%5 + 1) + image.size.height/2;
    } else {
        size = image.size.height * sizeSetting/2;
    }
    y = -(arc4random()%limitY) - size;
    int alphaSetting = _noahBgDic ? [[[_noahBgDic objectForKey:@"settings"] objectForKey:@"snow_alpha"] integerValue] : 0;
    float alpha = ((arc4random()%30)/60) + 0.5;
    if (alphaSetting != 0) {
        alpha = alphaSetting/3;
    }
    UIImageView *snow = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, size, size)];
    snow.image = image;
    snow.tag = 0;
    snow.alpha = alpha;
    [_holderView addSubview:snow];
    [_snows addObject:snow];
    [self animateSnow:snow];
    NSLog(@"snow count: %d", _snows.count);
}

- (void)animateSnow:(UIImageView *)snow {
    int finalX = (arc4random() % 100 -50) + snow.frame.origin.x;
    CGRect origiFrame = snow.frame;
    int speedSetting =  _noahBgDic ? (2 - [[[_noahBgDic objectForKey:@"settings"] objectForKey:@"snow_speed"] integerValue]) : 1;
    if (speedSetting < 0) {
        speedSetting = 0;
    }
    int dur = (arc4random() % 20) + 10 + 5*speedSetting;
    int finalY = TPScreenHeight();
    CGSize originalSize = snow.frame.size;
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        snow.frame = CGRectMake(finalX, finalY, originalSize.width, originalSize.height);
    } completion:^(BOOL finished) {
        snow.frame = origiFrame;
        snow.tag = 1;
    }];
}

- (void)checkNoahPushingSnow{
    BackgroundImageToast *toast = [[NoahManager sharedPSInstance] getBackgroundImageToast];
    if (toast && [FunctionUtility isCurrentBetweenDate:toast.startTime andDate:toast.endTime]) {
        NSString *filePathSuffix = [[toast getDownloadFilePathInner] stringByAppendingPathComponent:@"voipbg"];
        NSString *filePath = [FunctionUtility documentFile:filePathSuffix];
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:NULL];
        NSMutableArray *snows = [NSMutableArray array];
        UIImage *backbg = nil;
        NSDictionary *dict = nil;
        for (NSString *fileName in dirContents) {
            if ([fileName.lowercaseString hasPrefix:@"falling"]) {
                UIImage *image = [UIImage imageWithContentsOfFile:[filePath stringByAppendingPathComponent:fileName]];
                if (image) {
                    [snows addObject:image];
                }
            } else if ([fileName.lowercaseString hasPrefix:@"backgroundimage"]) {
                backbg = [UIImage imageWithContentsOfFile:[filePath stringByAppendingPathComponent:fileName]];
            } else if ([fileName.lowercaseString hasPrefix:@"settings"]) {
                dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[filePath stringByAppendingPathComponent:fileName]] options:NSJSONWritingPrettyPrinted error:NULL];
            }
        }
        if (!backbg) {
            return;
        }
        if (!dict) {
            dict = [NSDictionary dictionary];
        }
        _noahBgDic = @{@"bg":backbg, @"snows":snows, @"settings":dict};
    }
    return;
}

- (UIImage *)noahPushBg {
    return _noahBgDic[@"bg"];
}

@end
