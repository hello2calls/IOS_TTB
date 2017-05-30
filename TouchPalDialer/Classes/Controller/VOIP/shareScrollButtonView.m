//
//  shareScrollButtonView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/30.
//
//

#import "shareScrollButtonView.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import "TPMFMessageActionController.h"
#import "TouchPalDialerAppDelegate.h"
#import "DefaultUIAlertViewHandler.h"
#import "WXApi.h"
#import "TouchPalVersionInfo.h"
#import "TPShareController.h"
#import "DialerUsageRecord.h"
#import "FunctionUtility.h"
#import "QQShareController.h"
#import "EditVoipViewController.h"
#import "SeattleFeatureExecutor.h"
#import "ShareButtonTitleView.h"
#import "ShareButtonObject.h"

#define HEIGHT_ADAPT (TPScreenWidth()>320?1.1:1)

@interface shareScrollButtonView()<shareButtonTitleViewDelegate>{
    
}

@end

@implementation shareScrollButtonView

- (instancetype)initWithFrame:(CGRect)frame andButtonArray:(NSArray *)buttonArray{
    self = [super initWithFrame:frame];
    
    if (self){
        for ( int i = 0 ; i < [buttonArray count] ; i ++ ){
            float x = (i%4)*(frame.size.width - 40)/4 + ((frame.size.width - 40)/4-60*HEIGHT_ADAPT)/2+20;
            float y = i/4 * 100 * HEIGHT_ADAPT;
            ShareButtonObject *object = [buttonArray objectAtIndex:i];
            ShareButtonTitleView *buttonView = [[ShareButtonTitleView alloc]initWithFrame:CGRectMake(x, y, 60*HEIGHT_ADAPT, 70*HEIGHT_ADAPT) andButtonTitle:object.buttonTitle andLabelTitle:object.labelTitle andTag:object.tag];
            [buttonView.shareButton setTitleColor:[TPDialerResourceManager getColorForStyle:object.normalColor] forState:UIControlStateNormal];
            [buttonView.shareButton setTitleColor:[TPDialerResourceManager getColorForStyle:object.hlColor] forState:UIControlStateHighlighted];
            buttonView.delegate = self;
            [self addSubview:buttonView];
        }
    }
    
    return self;
}

- (void)clickOnButton:(NSInteger)tag{
    [_shareDelegate clickOnButton:tag];
}

@end
