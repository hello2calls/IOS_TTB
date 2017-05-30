//
//  ReportCommitAlertView.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReportCommitAlertView.h"
#import "ImageViewUtility.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultKeys.h"
#import "SnsModel.h"
#import "TouchPalDialerAppDelegate.h"
#import "DefaultSnsDelegateImpl.h"
#import "UserDefaultsManager.h"
#import "TPUIButton.h"
#import "AppSettingsModel.h"

@interface ReportCommitAlertView(){
    TPUIButton *buttonCheckSina_;
    NSString *sinaMessage_;
}

@end
@implementation ReportCommitAlertView
- (id)initWithFrame:(CGRect)frame message:(NSString *)message
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
        sinaMessage_ = [message copy];
        
        int marginTop = 60;
        ImageViewUtility *bgView = [[ImageViewUtility alloc] initImageViewUtilityWithFrame:CGRectMake(0,marginTop,TPScreenWidth(),350) withImage:[[TPDialerResourceManager sharedManager] getCachedImageByName:@"common_popup_bg@2x.png"]];
        [self addSubview:bgView];
        [bgView release];
        
        UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(26,30, 264, 30)];
		titleView.backgroundColor = [UIColor clearColor];
		titleView.font = [UIFont boldSystemFontOfSize:CELL_FONT_LARGE];
		titleView.text = NSLocalizedString(@"Report received",@"");
        titleView.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"common_popup_title_color"];
		titleView.numberOfLines = 0;
        titleView.textAlignment = UITextAlignmentLeft;
        [bgView addSubview:titleView];
        [titleView release];
        
        UILabel *contentView = [[UILabel alloc]initWithFrame:CGRectMake(27,80, 264, 30)];
		contentView.backgroundColor = [UIColor clearColor];
		contentView.font = [UIFont boldSystemFontOfSize:17];
		contentView.text = NSLocalizedString(@"Thank you for your contribution to Yellow book!",@"");
        contentView.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"common_popup_text_color"];
        contentView.textAlignment = UITextAlignmentLeft;
        contentView.numberOfLines = 0;
        contentView.lineBreakMode = UILineBreakModeWordWrap;
        [bgView addSubview:contentView];
        [contentView release];
        
        UIImage *shareNormal = [[TPDialerResourceManager sharedManager] getImageByName:@"common_select_unchecked@2x.png"];
        UIImage *sharePress = [[TPDialerResourceManager sharedManager] getImageByName:@"common_select_checked@2x.png"];
        UIColor *color = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"common_popup_shareToSinaText_color"];
        buttonCheckSina_ = [TPUIButton buttonWithType:UIButtonTypeCustom];
        [buttonCheckSina_ setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        buttonCheckSina_.titleLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
        buttonCheckSina_.frame = CGRectMake(16, 110, 264, 50);
        [buttonCheckSina_ setTitle:NSLocalizedString(@"Share to Weibo", @"")  forState:UIControlStateNormal];
        [buttonCheckSina_ setTitleColor:color forState:UIControlStateNormal];
        [buttonCheckSina_ setImage:shareNormal forState:UIControlStateNormal];
        [buttonCheckSina_ setImage:sharePress forState:UIControlStateSelected];
        
        [buttonCheckSina_ addTarget:self action:@selector(shareToSina) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:buttonCheckSina_];
        NSObject<SocialClient>* client = [[SnsModel getShareInstance] getClient:kSNS_SINA_WEIBO];
        buttonCheckSina_.selected = [AppSettingsModel appSettings].isShareToSina && [client isSessionValid];
        
        UIImage *buttonBackgroundNormal = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_button_normal@2x.png"];
        UIImage *buttonBackgroundHighlighted = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_button_hg@2x.png"];
        
        TPUIButton *buttonConfirm = [TPUIButton buttonWithType:UIButtonTypeCustom];
        buttonConfirm.frame = CGRectMake(26, 165, 268, 40);
        [buttonConfirm setBackgroundImage:buttonBackgroundNormal forState:UIControlStateNormal];
        [buttonConfirm setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
        [buttonConfirm setTitle:NSLocalizedString(@"Ok", @"") forState:UIControlStateNormal];
        [buttonConfirm setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_popup_button_text_color"] forState:UIControlStateNormal];
        [buttonConfirm addTarget:self action:@selector(addShopToServe) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:buttonConfirm];
        
    }
    return self;
}

-(void)shareToSina
{
    //绑定新浪微博
    NSObject<SocialClient>* client = [[SnsModel getShareInstance] getClient:kSNS_SINA_WEIBO];
    if (![client isSessionValid]) {
        client.needShareAppWhenLogin = NO;
        UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
        [client logIn:aViewController withLoginDelegate:self];
    }else{
        buttonCheckSina_.selected = !buttonCheckSina_.selected;
        [AppSettingsModel appSettings].isShareToSina = buttonCheckSina_.selected;
    }
}
#pragma SnsLoginDelegate
-(void)loginBack:(NSObject<SocialClient>*)client withSccess:(BOOL)is_success{
    cootek_log(@"%@ logined: %i", [client getSNSString], is_success);
    buttonCheckSina_.selected = !buttonCheckSina_.selected && is_success;
    [UserDefaultsManager setObject:[NSNumber numberWithBool:buttonCheckSina_.selected] forKey:IS_SHARE_TO_SINA];
}
-(void)addShopToServe{ 
    if (buttonCheckSina_.selected) {
        NSObject<SocialClient>*  client = [[SnsModel getShareInstance] getClient:kSNS_SINA_WEIBO];
        if ([client isSessionValid]){
            [client post:sinaMessage_ withDelegate:[DefaultSnsDelegateImpl instance]];
        }
    }
    [self removeFromSuperview];
}

-(void)dealloc{
    [sinaMessage_ release];
    [super dealloc];
}
@end
