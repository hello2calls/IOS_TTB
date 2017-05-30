//
//  RootTabBar.m
//  TouchPalDialer
//
//  Created by zhang Owen on 8/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "RootTabBar.h"
#import "PhonePadModel.h"
#import "consts.h"
#import "UserDefaultKeys.h"
#import "TPDialerResourceManager.h"
#import "HighlightTip.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "TPUIButton.h"
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "CootekNotifications.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "TouchpalMembersManager.h"
#import "DialerUsageRecord.h"
#import "TouchPalDialerAppDelegate.h"
#import "RootScrollViewController.h"
#import "GesturePhonePadGuideView.h"
#import "ImageUtils.h"
#import "UIDataManager.h"
#import "IndexData.h"
#import "SectionMiniBanner.h"
#import "MiniBannerItem.h"
#import "UIImage+Extra.h"
#import "MiniBannerItem.h"
#import "SectionFullScreenAd.h"
#import "FullScreenAdItem.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "CTUrl.h"
#import "CommonTipsWithBolckView.h"
#import "DefaultLoginController.h"
#import "HandlerWebViewController.h"
#import "TouchLifeTabBarAdManager.h"
#import "VoipUtils.h"
#import "TPFilterRecorder.h"
#import "DateTimeUtil.h"
#define NEW_FEATURE_TIPS_TAG 200

typedef enum {
    Fold,
    UnFold,
    Normal,
}DialButtonState;

@interface RootTabBar () <TouchpalsChangeDelegate> {
    NSDate *lastDeleteKeyPressedTime_;
    BOOL shouldRespondTo_;
    NSMutableArray* buttons_;
    UILabel *contactNumberLabel;
    NSInteger selectedButtonID_;
    UIImageView *shadowImageView;
    UIView* redPointYP;
    NSInteger sumWeight_;
    DialButtonState dialButtonState_;
    BOOL disable_;

    NSMutableArray *pvTimeArray;
    NSInteger totalPVTime;
    NSString* defaultYPStyle;
    NSInteger selectedButtonIndex_;
    SectionGroup* usingGroup;
    BOOL didSelectedYP;
    UIImageView *dotImageView;
}



@property (nonatomic, retain) NSMutableArray* buttons;
- (void)touchDownAction:(TPUIButton*)button;
- (void)touchUpInsideAction:(TPUIButton*)button;
- (void)otherTouchesAction:(TPUIButton*)button;
- (void)dimAllButtonsExcept:(TPUIButton*)selectedButton;
@end

@implementation RootTabBar
@synthesize buttons = buttons_;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableForAWhile) name:N_ROOT_BAR_DISABLE_FOR_A_WHILE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEnterBackground) name:N_APP_DID_ENTER_BACKGROUND object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEnterForeground) name:N_APPLICATION_BECOME_ACTIVE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVoipOn) name:N_REFRESH_IS_VOIP_ON object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVoipOn) name:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
        [TouchpalMembersManager addListener:self];

        int nowTime = [[NSDate date] timeIntervalSince1970];
        pvTimeArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:nowTime],[NSNumber numberWithInt:nowTime],[NSNumber numberWithInt:nowTime], nil];
        didSelectedYP = NO;
    }
    return self;
}

- (void) selectButtonAtIndex:(NSInteger)index
{
    if (disable_) {
        return;
    }
    selectedButtonIndex_ = index;
    TPUIButton* button = [buttons_ objectAtIndex:index];
	[self dimAllButtonsExcept:button];

    NSMutableSet* set = (NSMutableSet*)[UserDefaultsManager objectForKey:INDEX_TAB_POINT_URLS];
    if (!set) {
        set = [NSMutableSet new];
    }
    if ( _rootScrollView.nowStatus != index ){
        [self setIndexRecord:_rootScrollView.nowStatus];
        [self setIndexInTime:index];
        cootek_log(@"ad_pu, tabbar, index change, async get popup ad");
        [self refreshVoipOn];
    }
    [shadowImageView setFrame:CGRectMake(button.frame.origin.x, button.frame.size.height-3, button.frame.size.width, 3)];
    _rootScrollView.contentOffset = CGPointMake(index*TPScreenWidth(), 0);
    _rootScrollView.nowStatus = index;
    [self usageRecordCurrentTab:index];

    if (delegate) {
        [delegate customTabBar:self clickedButtonAtIndex:index];
    }
}

- (void)setIndexRecord:(NSInteger)index{
    int nowTime = [[NSDate date] timeIntervalSince1970];
    int nowOffset = [NSTimeZone localTimeZone].secondsFromGMT;
    NSString *path = @"";
    if ( index == 0 )
        path = @"contactPage";
    else if ( index == 1 ) {
        path = @"dialerPage";
        if ([[TPDialerResourceManager sharedManager].skinTheme rangeOfString:@".AD."].length > 0) {
            [DialerUsageRecord recordpath:PATH_COMMERCIAL_SKIN kvs:Pair(SHOW_SKIN,[TPDialerResourceManager sharedManager].skinTheme), nil];
        }
    }
    else if ( index == 2 )
        path = @"YellowPage";
    NSInteger inTime = [[pvTimeArray objectAtIndex:index] integerValue];
    [DialerUsageRecord recordPV:path inTime:inTime outTime:nowTime rawOffset:nowOffset];
}

- (void)setIndexInTime:(NSInteger)index{
    int nowTime = [[NSDate date] timeIntervalSince1970];
    [pvTimeArray replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:nowTime]];
}

- (void)setTotalInTime{
    totalPVTime = [[NSDate date] timeIntervalSince1970];
}

- (void)setTotalIndexRecord{
    int nowTime = [[NSDate date] timeIntervalSince1970];
    int nowOffset = [NSTimeZone localTimeZone].secondsFromGMT;
    NSString *path = @"rootTotalPage";
    [DialerUsageRecord recordPV:path inTime:totalPVTime outTime:nowTime rawOffset:nowOffset];
}

- (void)rootViewAppear{
    [self setIndexInTime:_rootScrollView.nowStatus];
    [self setTotalInTime];
    [self usageRecordCurrentTab:_rootScrollView.nowStatus];
    cootek_log(@"ad_pu, tabbar, root will appear, async get popup ad");
    [AllViewController asyncGetActivityFamilyInfo];
    [self refreshVoipOn];
    
}

- (void)rootViewDisappear{
    [self setIndexRecord:_rootScrollView.nowStatus];
    [self setTotalIndexRecord];
}

- (void)refreshEnterForeground{
    UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    if ( [navi.topViewController isKindOfClass:[RootScrollViewController class]] ){
        [self rootViewAppear];
        [self updateYellowPageAlertLabel];
    }
}

- (void)refreshEnterBackground{
    UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    if ( [navi.topViewController isKindOfClass:[RootScrollViewController class]] ){
        [self rootViewDisappear];
    }
}

- (void) firstSelectButtonAtIndex:(NSInteger)index
{
	TPUIButton* button = [buttons_ objectAtIndex:index];
	[self dimAllButtonsExcept:button];
    [shadowImageView setFrame:CGRectMake(button.frame.origin.x, button.frame.size.height-3, button.frame.size.width, 3)];
    _rootScrollView.contentOffset = CGPointMake(index*TPScreenWidth(), 0);

    if (delegate) {
        [delegate customTabBar:self clickedButtonAtIndex:index];
    }
}

-(void) dimAllButtonsExcept:(TPUIButton*)selectedButton
{
    for (NSUInteger i = 0; i < buttons_.count; i++) {
        TPUIButton* button = [buttons_ objectAtIndex:i];
        if (button == selectedButton) {
            if (!button.isSelected) {
                button.selected = YES;
                if (i != 1) {
                    // do not disable the phone pad tab
                    button.userInteractionEnabled = NO;
                }
            }
        } else {
            button.selected = NO;
            button.userInteractionEnabled = YES;
        }
    }
}

- (void)loadItemWithCount:(NSUInteger)itemCount
{
    // Adjust our width based on the number of items & the width of each item
    // Initalize the array we use to store our buttons
    NSMutableArray *tmpButtons = [[NSMutableArray alloc] initWithCapacity:itemCount];
    self.buttons = tmpButtons;
    userSelectedChannelID = 1;
    // horizontalOffset tracks the proper x value as we add buttons as subviews
    CGFloat horizontalOffset = 0;
    NSInteger buttonHeight = 0;
    NSInteger buttonWidth = 0;
    //get sum weight
    sumWeight_ = 0;
    for (NSUInteger i = 0 ; i < itemCount ; i++) {
        sumWeight_ += [[[delegate attrForTabAtIndex:i] objectForKey:@"weight"] integerValue];
    }
    // Iterate through each item
    for (NSUInteger i = 0 ; i < itemCount ; i++)
    {
        // Create a button
        TPUIButton* button = [self buttonAtIndex:i];
        button.exclusiveTouch = YES;//prevent more than one view to response touch event
        [button setTag:i+100];
        // Register for touch events
        [button addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragOutside];
        [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragInside];
        // Add the button to our buttons array
        [buttons_ addObject:button];
        buttonHeight = button.frame.size.height;
        buttonWidth = button.frame.size.width;
        [button setFrame:CGRectMake(horizontalOffset, 0, buttonWidth, buttonHeight)];
        // Set the button's x offset
        [self addSubview:button];
        // Advance the horizontal offset
        horizontalOffset = horizontalOffset + buttonWidth;



    }
    [self addAlertLabel];
    dialButtonState_ = Normal;
    [self setDialButtonState:[PhonePadModel getSharedPhonePadModel].phonepad_show ? Fold : UnFold];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenPhonePadShow) name:N_PHONE_PAD_SHOW object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenPhonePadHide) name:N_PHONE_PAD_HIDE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToIndexPage:) name:N_JUMP_TO_REGISTER_INDEX_PAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSkinChange) name:N_SKIN_DID_CHANGE object:nil];

    shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, buttonHeight-3, 75, 3)];
    [shadowImageView setSkinStyleWithHost:self forStyle:@"root_tab_bar_shadow_color"];
    [self addSubview:shadowImageView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateYellowPageAlertLabel) name:N_MINI_BANNER_REQUEST_SUCCESS object:nil];
}

- (void) updateYellowPageAlertLabel{

    if (selectedButtonIndex_ == 2) {
        if (!didSelectedYP) {
            didSelectedYP = YES;
        }
    } else {
        didSelectedYP = NO;
    }

    if (didSelectedYP) return;

    BOOL miniTabClick = [UserDefaultsManager boolValueForKey:INDEX_REQUEST_MINI_BANNER_TAB_CLICK];
    BOOL adClick = [UserDefaultsManager boolValueForKey:INDEX_REQUEST_FULL_AD_TAB_CLICK];
    if (miniTabClick && adClick) {
        return;
    }
    [UIDataManager instance].showAdItem = nil;
    IndexData* miniBannerAndAdsData = nil;
    NSDictionary* data = (NSDictionary *)[UserDefaultsManager objectForKey:INDEX_REQUEST_MINI_BANNER];
    if (data) {
        miniBannerAndAdsData = [[IndexData alloc]initWithJson:data];
    }


    if (miniBannerAndAdsData && miniBannerAndAdsData.groupArray.count > 0) {
        NSMutableArray* secBaseArray = [NSMutableArray new];
        for (SectionGroup* group in miniBannerAndAdsData.groupArray) {
            if ([group.sectionType isEqualToString:SECTION_TYPE_FULL_SCREEN_ADS]) {

                if ([group isValid]) {
                    [secBaseArray insertObject:group atIndex:0];
                }
            } else if ([group.sectionType isEqualToString:SECTION_TYPE_MINI_BANNERS]) {
                if ([group isValid]) {
                    [secBaseArray insertObject:group atIndex:secBaseArray.count];

                }
            }
        }

        SectionBase* selectedSection = nil;
        NSString* tabIcon = nil;
        if (secBaseArray.count > 0) {
            usingGroup = [secBaseArray objectAtIndex:0];
            if ([usingGroup.sectionType isEqualToString:SECTION_TYPE_FULL_SCREEN_ADS]) {
                if (adClick) {
                    return;
                }
                SectionFullScreenAd* adSection = [usingGroup.sectionArray objectAtIndex:0];
                tabIcon = adSection.tabGuideIcon;

            } else if ([usingGroup.sectionType isEqualToString:SECTION_TYPE_MINI_BANNERS]) {
                if (miniTabClick) {
                    return;
                }
                SectionMiniBanner* bannerSection = [usingGroup.sectionArray objectAtIndex:0];
                tabIcon = bannerSection.tabGuideIcon;
            }
        }

        if ([usingGroup isValid]) {
            selectedSection = [usingGroup.sectionArray objectAtIndex:0];
        }

        if (selectedSection.items && selectedSection.items.count > 0 && tabIcon) {
            BaseItem* item =[selectedSection.items objectAtIndex:0];

            if ([usingGroup.sectionType isEqualToString:SECTION_TYPE_FULL_SCREEN_ADS]
                && [UserDefaultsManager boolValueForKey:INDEX_REQUEST_FULL_AD_TAB_CLICK] == NO) {
                [UIDataManager instance].showAdItem = (FullScreenAdItem *)item;
            }

            if ([item shouldShowHighLight]) {
                UIButton* ypBtn = [buttons_ objectAtIndex:2];
                NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"dialerViewController_tabBar_style"];
                UIImage* img = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"phonePadHide_image"]];
                [ImageUtils getImageFromUrl:item.iconLink success:^(UIImage *image) {

                    if (!redPointYP) {
                        redPointYP = [[UIView alloc] initWithFrame:CGRectMake(ypBtn.bounds.size.width / 2 + img.size.width / 2, 4, 8, 8)];
                        redPointYP.layer.masksToBounds = YES;
                        redPointYP.layer.cornerRadius = 4;
                        redPointYP.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
                        [ypBtn addSubview:redPointYP];
                    }
                    redPointYP.hidden = NO;
                    [ypBtn setImage:[image imageByScalingProportionallyToSize:img.size] forState:UIControlStateNormal];
                } failed:^{

                }];
            }
        }
    }


}

- (void) addAlertLabel{
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return;
    BOOL isFirstVisit = [UserDefaultsManager boolValueForKey:VOIP_FIRST_VISIT_TOUCHPAL_PAGE_WITH_ALERT defaultValue:NO];
//    if (!isFirstVisit){
        TPUIButton *contactButton = [buttons_ objectAtIndex:0];
        CGFloat dotDiameter = 16;
        CGRect dotFrame = CGRectMake(contactButton.bounds.size.width / 2 + 8, 4, dotDiameter, dotDiameter);
        
        UILabel *numberLabel = [[UILabel alloc]initWithFrame:dotFrame];
        numberLabel.layer.masksToBounds = YES;
        numberLabel.layer.cornerRadius = numberLabel.frame.size.width / 2;
        numberLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        NSString *numberString = nil;
//        if ([TouchpalMembersManager getTouchpalerArrayCount]>99) {
//            numberString = @"99+";
//        }else{
        numberString = [NSString stringWithFormat:@"%d",[TouchpalMembersManager getTouchpalerFamilyArrayCount]];
//        }
//        if (<#condition#>) {
//        <#statements#>
//        }
        numberLabel.text = numberString;
        if ( [numberLabel.text length] > 1 ){
            numberLabel.font = [UIFont systemFontOfSize:8];
        }else{
            numberLabel.font = [UIFont systemFontOfSize:12];
        }
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.hidden = YES;
        numberLabel.textAlignment = NSTextAlignmentCenter;
        
        // view tree
        [contactButton addSubview:numberLabel];
        
        contactNumberLabel = numberLabel;
        [self refreshVoipOn];
//    }
}

// Create a button at the provided index
- (TPUIButton*) buttonAtIndex:(NSUInteger)itemIndex
{
	TPUIButton* button = [TPUIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *attr = [delegate attrForTabAtIndex:itemIndex];
    NSInteger weight = [[attr objectForKey:@"weight"] integerValue];
    float width = ((float)weight/(float)sumWeight_) * self.frame.size.width;
	button.frame = CGRectMake(0.0, 0.0, width, self.frame.size.height);
    [button setSkinStyleWithHost:self forStyle:[attr objectForKey:@"style"]];
	button.adjustsImageWhenHighlighted = NO;
    [button setBackgroundColor:[UIColor clearColor]];
    NSString *title = [attr objectForKey:@"text_for_tab"];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    //arrange title and image position
    [self setButtonEdgeInsets:button];
    if (itemIndex == 2) {
        defaultYPStyle = [attr objectForKey:@"style"];
    }
    return button;
}

- (void)setButtonEdgeInsets:(UIButton *)button{
    [button setTitleEdgeInsets:UIEdgeInsetsMake( 28.0,-button.imageView.bounds.size.width, 0.0,0.0)];
    BOOL ifMiddle = [[[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"rootTabBarButtonMiddle"] boolValue];
    if ( !ifMiddle ){
        [button setImageEdgeInsets:UIEdgeInsetsMake(-15.0, 0.0,0.0, -button.titleLabel.bounds.size.width)];
    }else{
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0.0,0.0, -button.titleLabel.bounds.size.width)];
    }
}

- (void)setDialButtonState:(DialButtonState)state force:(DialButtonState)force{
    if (dialButtonState_ == state && !force) {
        return;
    }
    UIButton *button = [buttons_ objectAtIndex:1];
    UIImage *buttonPressedImage;
    NSString *text;
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"dialerViewController_tabBar_style"];
    switch (state) {
        case Fold:
            buttonPressedImage = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"phonePadHide_image"]];
            text = NSLocalizedString(@"Fold_Dialpad_", @"");
            break;
        case UnFold:
            buttonPressedImage = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"phonePadShow_image"]];
            text = NSLocalizedString(@"Unfold_Dialpad_", @"");
            break;
        case Normal:
            buttonPressedImage = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:@"phonePadNormal_image"]];
            NSDictionary *attr = [delegate attrForTabAtIndex:1];
            text = [attr objectForKey:@"text_for_tab"];
            break;
    }
    [button setImage:buttonPressedImage forState:UIControlStateSelected];
    [button setImage:buttonPressedImage forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateSelected];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake( 28.0,-button.imageView.bounds.size.width, 0.0,0.0)];
    [self setButtonEdgeInsets:button];

    dialButtonState_ = state;
}

- (void)setDialButtonState:(DialButtonState)state {
    [self setDialButtonState:state force:NO];
}

- (void)drawRect:(CGRect)rect {
    UIImage *bg = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"tabBarBackground_image" needCache:NO];
	[bg drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void)doWhenPhonePadShow {
    [self setDialButtonState:Fold];
}

- (void)doWhenPhonePadHide {
    [self setDialButtonState:UnFold];
}

- (void)removeGestureTips:(TPUIButton*) button{
    if ([button viewWithTag:NEW_FEATURE_TIPS_TAG]) {
        [[button viewWithTag:NEW_FEATURE_TIPS_TAG] removeFromSuperview];
    }
}

- (void)goToIndexPage:(NSNotification *)noti {
    int  indexPage = [noti.object intValue];
	[self selectButtonAtIndex:indexPage];
    if ([noti.userInfo[@"show"] isEqualToString:@"add_Dial_GUSTRE_View"]) {
            GesturePhonePadGuideView *view =[[GesturePhonePadGuideView alloc] init];
            [DialogUtil showDialogWithContentView:view inRootView:nil];
    }
    if ([noti.userInfo[@"show"] isEqualToString:@"internationCall_toast"]) {
        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [uiWindow makeToast:INTERNATIONAL_CALL_OK duration:1.0f position:CSToastPositionBottom];
    }
    if ([noti.userInfo[@"show"] isEqualToString:@"testFreeCall_View"]) {
        [self showFreeCallTip];
    }
}

-(void)showFreeCallTip{
    CommonTipsWithBolckView  *view ;
    if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME].length>0) {
        view =[[CommonTipsWithBolckView alloc]initWithtitleString:@"触宝提示" lable1String:@"你已经掌握了免费打电话这门绝学，要不顺便告诉下常打电话的那些人，一起免费打电话！"lable1textAlignment:NSTextAlignmentLeft lable2String:nil lable2textAlignment:0 leftString:@"再说吧" rightString:@"通知一下" rightBlock:^{
            HandlerWebViewController *webVC = [[HandlerWebViewController alloc] init];
            NSString *url = USE_DEBUG_SERVER ? TEST_INVITE_REWARDS_WEB : INVITE_REWARDS_WEB;
            webVC.url_string = [url stringByAppendingString:[NSString stringWithFormat:@"?share_from=%@",TESTFREECALL]];
            webVC.header_title = NSLocalizedString(@"invite_friends", @"邀请有奖");
            [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:YES];
            
        } leftBlock:nil];
    }else{
        view =[[CommonTipsWithBolckView alloc]initWithtitleString:@"开启免费电话" lable1String:@"已经体验过免费电话了，是否要开启完整的免费电话功能呢？" lable1textAlignment:NSTextAlignmentLeft lable2String:nil lable2textAlignment:0 leftString:@"不需要" rightString:@"开启免费电话" rightBlock:^{
            if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
                [UserDefaultsManager setBoolValue:YES forKey:IS_VOIP_ON];
            } else {
                [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_FROM, LOGIN_FROM_LEARN_FREE_CALL), nil];
                [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"click_tip_register"]];
                [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION , TESTFREECALL_CLICK_TIP_REGISTER), nil];
            }
        } leftBlock:nil];
    }
    [DialogUtil showDialogWithContentView:view inRootView:nil];
}

- (void)touchUpInsideAction:(TPUIButton*)button
{
    if (button == [buttons_ objectAtIndex:2]) {
        if (!didSelectedYP) {
            didSelectedYP = YES;
            [button setSkinStyleWithHost:self forStyle:defaultYPStyle];
            if (redPointYP) {
                redPointYP.hidden = YES;
            }
        }


        if (!shouldRespondTo_) {
            return;
        }
    }
    NSUInteger index = [buttons_ indexOfObject:button];
    [self selectButtonAtIndex:index];
}

- (void)touchDownAction:(TPUIButton*)button
{
    if (disable_) {
        return;
    }
    NSUInteger index = [buttons_ indexOfObject:button];
    if (index == 1) {
        [self setDialButtonState:[PhonePadModel getSharedPhonePadModel].phonepad_show ? Fold : UnFold];
    } else {
        [self setDialButtonState:Normal];
    }
    PhonePadModel *sharedModel = [PhonePadModel getSharedPhonePadModel];
	if (index == 1 ) {
		if (button == [buttons_ objectAtIndex:1]) {

			if (userSelectedChannelID !=index) {

            }
            else{

                [sharedModel setPhonePadShowingState:!(sharedModel.phonepad_show)];

            }

		}
	}else if (index == 2){

        [[TouchLifeTabBarAdManager instance] sendCMonitorUrl];
        
        if (usingGroup) {
            if ([usingGroup.sectionType isEqualToString:SECTION_TYPE_MINI_BANNERS]) {
                [UserDefaultsManager setBoolValue:YES forKey:INDEX_REQUEST_MINI_BANNER_TAB_CLICK];
                SectionBase* section =[usingGroup.sectionArray objectAtIndex:0];
                BaseItem* item = [section.items objectAtIndex:0];
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_MINI_BANNER_TAB_ICON_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title", item.title), Pair(@"url", item.ctUrl.url),nil];
            } else if ([usingGroup.sectionType isEqualToString:SECTION_TYPE_FULL_SCREEN_ADS]){
                [UserDefaultsManager setBoolValue:YES forKey:INDEX_REQUEST_FULL_AD_TAB_CLICK];
                SectionBase* section =[usingGroup.sectionArray objectAtIndex:0];
                BaseItem* item = [section.items objectAtIndex:0];
                [item hideClickHiddenInfo];
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FULL_AD_TAB_ICON_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title", item.title), Pair(@"url", item.ctUrl.url),nil];

            }
        }

        if (lastDeleteKeyPressedTime_) {
            double time = [[NSDate date] timeIntervalSinceDate:lastDeleteKeyPressedTime_];
            if (time < 1.0) {
                shouldRespondTo_ = NO;
                return;
            }
            else {
                shouldRespondTo_ = YES;
            }
        } else {
            shouldRespondTo_ = YES;
        }
    }
    userSelectedChannelID = index;
    [self selectButtonAtIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:select_index_in_root_bar object:nil userInfo:@{@"index":@(index)}];
}


- (void)otherTouchesAction:(TPUIButton*)button
{
    [self touchUpInsideAction:button];
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setButtonUnSelect
{

}

-(void)selectTabAtIndex:(NSInteger)index{
    TPUIButton * button = [buttons_ objectAtIndex:index];
    [self touchDownAction:button];
}

- (void)setButtonSelect
{
    //滑动选中按钮
    TPUIButton * button = [buttons_ objectAtIndex:_scrollViewSelectedChannelID];
    [self touchDownAction:button];
}

- (void)onSkinChange{
    int i =0;
    for (UIButton *button in buttons_) {
        if (i == 1) {
            //no need for dial button
            continue;
        }
        [self setButtonEdgeInsets:button];
    }
    [self setDialButtonState:dialButtonState_ force:YES];
}

- (void)disableForAWhile {
    disable_ = YES;
    [self performSelector:@selector(enableClick) withObject:nil afterDelay:0.5];
}

#pragma mark TouchpalsChangeDelegate
- (void)onTouchpalChanges{
    [self refreshVoipOn];
}

- (void)refreshVoipOn{
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSString *numberString = nil;
//        if ([TouchpalMembersManager getTouchpalerArrayCount]>99) {
//            numberString = @"99+";
//        }else{
            numberString = [NSString stringWithFormat:@"%d",[TouchpalMembersManager getTouchpalerFamilyArrayCount]];
//        }
        contactNumberLabel.text = numberString;
        if ( [contactNumberLabel.text length] > 1 ){
            contactNumberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:8];
        }else{
            contactNumberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12];
        }
        
        if (![UserDefaultsManager boolValueForKey:CONTACT_FAMILY_GUIDE_SHOWN defaultValue:NO]) {
            TPUIButton *contactButton = [buttons_ objectAtIndex:0];
            
            CGSize dotSize = CGSizeMake(32, 16);
            CGRect dotFrame = CGRectMake(contactButton.tp_width/2+10, (contactButton.tp_height - dotSize.height) / 4, dotSize.width, dotSize.height);
            if (dotImageView==nil) {
                dotImageView = [[UIImageView alloc] initWithFrame:dotFrame];
                dotImageView.image = [TPDialerResourceManager getImageByColorName:@"tp_color_red_500" withFrame:dotImageView.bounds];
                dotImageView.clipsToBounds = YES;
                dotImageView.layer.cornerRadius = dotSize.height / 2;
                
                UILabel *dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dotFrame.size.width, dotFrame.size.height)];
                dotLabel.backgroundColor = [UIColor clearColor];
                dotLabel.text = @"NEW";
                dotLabel.textColor = [UIColor whiteColor];
                dotLabel.font = [UIFont systemFontOfSize:10];
                dotLabel.textAlignment = NSTextAlignmentCenter;
                [dotImageView addSubview:dotLabel];
                [contactButton addSubview:dotImageView];
                
            }
            dotImageView.hidden = NO;
            contactNumberLabel.hidden = YES;
            
        } else {
            dotImageView.hidden = YES;
            if ([TouchpalMembersManager getTouchpalerFamilyArrayCount]==0) {
                contactNumberLabel.hidden = YES;
            } else {
                NSDate *nowDate = [NSDate date];
                NSDate *oldDate = [UserDefaultsManager dateForKey:CONTACT_FAMILY_GUIDE_CLICK_DATE defaultValue:[NSDate dateWithTimeIntervalSince1970:0]];
                NSTimeInterval interval = [nowDate timeIntervalSinceDate:oldDate];
                if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] != nil
                    && interval > 60*10
                    ) {
                    contactNumberLabel.hidden = NO;
                } else {
                    contactNumberLabel.hidden = YES;
                }
            }
        }
        
    });
}


- (void)enableClick {
    disable_ = NO;
}

/**
 *  usage record the current displayed tab name
 *
 *  @param index the index of the tab will be displayed
 */
- (void) usageRecordCurrentTab:(NSInteger)index {
    NSString *tabName = nil;
    switch (index) {
        case 0: {
            tabName = ENTER_CONTACT_PAGE;
            break;
        }
        case 1: {
            tabName = ENTER_DIAL_PAGE;
            break;
        }
        case 2: {
            tabName = ENTER_FIND_PAGE;
            break;
        }
        default: {
            break;
        }
    }
    if (tabName != nil) {
        [DialerUsageRecord recordpath:PATH_DAILY_REPORT kvs:Pair(tabName, @(1)), nil];
    }
}

@end
