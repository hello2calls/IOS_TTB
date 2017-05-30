//
//  PublicNumberCenterView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-8-10.
//
//

#import "PublicNumberCenterView.h"
#import "ImageUtils.h"
#import "PublicNumberListController.h"
#import "UIDataManager.h"
#import "YellowPageMainTabController.h"
#import "CTUrl.h"
#import "TPDialerResourceManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "PublicNumberProvider.h"
#import "ImageUtils.h"
#import "PushConstant.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "UserDefaultsManager.h"
#import "DateTimeUtil.h"

@interface PublicNumberCenterView(){
    NSString* url;
    
}
@property (nonatomic, retain) UIView *iconView;
@end

@implementation PublicNumberCenterView

@synthesize label;
@synthesize iconView;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
    
    label = [[VerticallyAlignedLabel alloc]initWithFrame:self.bounds];
    label.text = @"4";
    label.textColor = [[TPDialerResourceManager sharedManager]
                       getUIColorFromNumberString:@"header_btn_color"];
    label.font = [UIFont fontWithName:IPHONE_ICON_2 size:24];
    label.textAlignment = NSTextAlignmentCenter;
    label.verticalAlignment = VerticalAlignmentMiddle;
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
    
    iconView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 16,8, 8,8)];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 4;
    iconView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
    iconView.hidden = YES;
    [self addSubview:iconView];
    
    return self;
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //highlight
    if (self.pressed) {
        label.textColor = [TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"];
    } else {
        label.textColor = [[TPDialerResourceManager sharedManager]
                           getUIColorFromNumberString:@"header_btn_color"];
    }
    if ([PublicNumberProvider getNewMsgCount]>0) {
        iconView.hidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewMsgCountIconView" object:nil];
    }else{
        iconView.hidden =YES;
    }
}

- (void) doClick {
    PublicNumberListController* controller= [[PublicNumberListController alloc] init];
    
    controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_PN_BTN kvs:Pair(@"action", @"selected"), nil];
    if (!iconView.hidden) {
        long long timestampInSecond = (long long)[DateTimeUtil currentTimestampInSecond];
        [UserDefaultsManager setDoubleValue:timestampInSecond forKey:PUBLIC_NUMBER_RED_DOT_LAST_CLICK];
    }
}

@end
