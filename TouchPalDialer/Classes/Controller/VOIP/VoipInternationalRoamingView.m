//
//  VoipInternationalRoamingView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/1.
//
//

#import "VoipInternationalRoamingView.h"
#import "TPDialerResourceManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "RootScrollViewController.h"
#import "AppSettingsModel.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"

#define WIDTH_ADJUST ((TPScreenWidth() > 330)? 1.1:1)

@implementation VoipInternationalRoamingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        UIView *boardView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280*WIDTH_ADJUST)/2,200,280*WIDTH_ADJUST,300)];
        boardView.backgroundColor = [UIColor whiteColor];
        boardView.layer.masksToBounds = YES;
        boardView.layer.cornerRadius = 3.0f;
        [self addSubview:boardView];
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(boardView.frame.size.width - 45*WIDTH_ADJUST , 0, 45*WIDTH_ADJUST, 45*WIDTH_ADJUST)];
        [cancelButton setTitle:@"F" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:16*WIDTH_ADJUST];
        [cancelButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"]] forState:UIControlStateHighlighted];
        [boardView addSubview:cancelButton];
        
        
        float globalY = 30*WIDTH_ADJUST;
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, boardView.frame.size.width , 18*WIDTH_ADJUST)];
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.font = [UIFont boldSystemFontOfSize:17*WIDTH_ADJUST];
        label1.text = @"国际漫游电话免费啦";
        label1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [boardView addSubview:label1];
        
        globalY += label1.frame.size.height + 30*WIDTH_ADJUST;
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(35*WIDTH_ADJUST, globalY, boardView.frame.size.width - 55*WIDTH_ADJUST, 16*WIDTH_ADJUST)];
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont fontWithName:@"Helvetica-Light" size:15*WIDTH_ADJUST];
        label2.text = @"用触宝电话，免费拨打国内号码";
        label2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [boardView addSubview:label2];
        
        UILabel *dotLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(-15*WIDTH_ADJUST, -7*WIDTH_ADJUST, 30*WIDTH_ADJUST, 30*WIDTH_ADJUST)];
        dotLabel1.backgroundColor = [UIColor clearColor];
        dotLabel1.text = @"·";
        dotLabel1.font = [UIFont systemFontOfSize:30*WIDTH_ADJUST];
        dotLabel1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [label2 addSubview:dotLabel1];
        
        globalY += label2.frame.size.height + 10*WIDTH_ADJUST;
        
        UILabel *label3 =[[UILabel alloc]initWithFrame:CGRectMake(35*WIDTH_ADJUST, globalY, boardView.frame.size.width - 55*WIDTH_ADJUST, 36*WIDTH_ADJUST)];
        label3.backgroundColor = [UIColor clearColor];
        label3.numberOfLines = 2;
        label3.font = [UIFont fontWithName:@"Helvetica-Light" size:15*WIDTH_ADJUST];
        label3.text = @"同行伙伴间用触宝免费电话，接听也免费";
        label3.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [boardView addSubview:label3];
        
        UILabel *dotLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(-15*WIDTH_ADJUST, -7*WIDTH_ADJUST, 30*WIDTH_ADJUST, 30*WIDTH_ADJUST)];
        dotLabel2.backgroundColor = [UIColor clearColor];
        dotLabel2.text = @"·";
        dotLabel2.font = [UIFont systemFontOfSize:30*WIDTH_ADJUST];
        dotLabel2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [label3 addSubview:dotLabel2];
        
        globalY += label2.frame.size.height + 10*WIDTH_ADJUST;
        
        UIImage *image = [TPDialerResourceManager getImage:@"voip_international_roaming_notification@2x.png"];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20*WIDTH_ADJUST, globalY, boardView.frame.size.width-40*WIDTH_ADJUST, (boardView.frame.size.width-40*WIDTH_ADJUST)/image.size.width*image.size.height)];
        imageView.image = image;
        [boardView addSubview:imageView];
        
        globalY += imageView.frame.size.height + 30*WIDTH_ADJUST;
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20*WIDTH_ADJUST, globalY, boardView.frame.size.width - 40*WIDTH_ADJUST, 46*WIDTH_ADJUST)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 4.0f;
        [button setTitle:NSLocalizedString(@"立即打一通试试", "") forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:17*WIDTH_ADJUST];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_highlight_image"] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_image"] forState:UIControlStateNormal];
        [button setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_disable_image"] forState:UIControlStateDisabled];
        [boardView addSubview:button];
        [button addTarget:self action:@selector(onButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        globalY += button.frame.size.height+ 20*WIDTH_ADJUST;
        
        boardView.frame = CGRectMake((TPScreenWidth()-280*WIDTH_ADJUST)/2,(TPScreenHeight()-globalY)/2,280*WIDTH_ADJUST,globalY);
    }
    
    return self;
}

- (void)onButtonPressed{
    UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    [navi popToRootViewControllerAnimated:YES];
    if ( [[navi.viewControllers objectAtIndex:0] isKindOfClass:[RootScrollViewController class]]){
        RootScrollViewController *con = [navi.viewControllers objectAtIndex:0];
        [con selectTabIndex:1];
        if ( ![PhonePadModel getSharedPhonePadModel].phonepad_show ){
            [con selectTabIndex:1];
        }
        if ( ![UserDefaultsManager boolValueForKey:IS_VOIP_ON] ){
            [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:YES] forKey:IS_VOIP_ON];
        }
    }
    [self removeFromSuperview];
}

- (void)removeView{
    [self removeFromSuperview];
}

@end
