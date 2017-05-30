//
//  YPFullScreenAdView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/2/15.
//
//

#import "YPFullScreenAdView.h"
#import "UIDataManager.h"
#import "CTUrl.h"
#import "FullScreenAdItem.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "UpdateService.h"
#import "EdurlManager.h"

@interface YPFullScreenAdView() {
    UIImageView* adImgView;
    UIImageView* closeImgView;
}

@end

@implementation YPFullScreenAdView


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(instancetype)initWithSelfFrameScale:(CGRect) frame  image1:(UIImage *)image1 andFrame1:(CGRect)frame1 image2:(UIImage *)image2 andFrame2:(CGRect)frame2 ifRemoveSelf:(BOOL)ifRemoveSelf{
    if (self = [super initWithFrame:frame]) {
        UIImageView *adImageView = [[UIImageView alloc] initWithFrame:frame1];
        adImageView.image = image1;
        adImageView.contentMode = UIViewContentModeScaleAspectFit;
        adImgView = adImageView;
        [self addSubview:adImageView];
        
        UITapGestureRecognizer *tapOnAdImgGes  =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnImage)];
        adImageView.userInteractionEnabled = YES;
        [adImageView addGestureRecognizer:tapOnAdImgGes];
        
        UIImageView *closeImageView = [[UIImageView alloc] initWithFrame:frame2];
        closeImageView.image = image2;
        closeImageView.contentMode = UIViewContentModeCenter;
        closeImgView = closeImageView;
        [self addSubview:closeImageView];
        
        UITapGestureRecognizer *tapOnCloseImgGes  =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sureToBlock)];
        closeImageView.userInteractionEnabled = YES;
        [closeImageView addGestureRecognizer:tapOnCloseImgGes];
        if (ifRemoveSelf) {
            [self addRemoveTap];
        }
      
        cootek_log(@"tl->fullscreen :edurl url");
        if ([UIDataManager instance].showAdItem.edMonitorUrl) {
            [[EdurlManager instance] requestEdurl:[UIDataManager instance].showAdItem.edMonitorUrl];
        }
        
    }
    
    return self;
}

-(void)addRemoveTap{
    UITapGestureRecognizer *tapOnBg  =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sureToBlock)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapOnBg];
}

-(void)closeToBlock{
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self removeSelf];
}

-(void)removeSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
        [UIDataManager instance].showAdItem = nil;
    }];
}

-(void)sureToBlock{
    if (self.sureBlock) {
        self.sureBlock();
    }
    [self removeSelf];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FULL_AD_CLOSE kvs:Pair(@"action", @"selected"), Pair(@"url",[UIDataManager instance].showAdItem.ctUrl.url), nil];
}

- (void)handleTapOnImage {
    [[UIDataManager instance].showAdItem.ctUrl startWebView];
    [self removeSelf];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FULL_AD_CLICK kvs:Pair(@"action", @"selected"), Pair(@"url",[UIDataManager instance].showAdItem.ctUrl.url), nil];
    
    [[EdurlManager instance] sendCMonitorUrl:[UIDataManager instance].showAdItem];
}

@end
