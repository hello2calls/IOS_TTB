//
//  SettingsModelCreator.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SettingsModelCreator.h"
#import "GoDetailSettingItemModel.h"
#import "WebPageSettingItemModel.h"
#import "ActionableSettingItemModel.h"
#import "SwitchSettingItemModel.h"
#import "SingleSelectionSettingItemModel.h"
#import "NonOpSettingItemModel.h"
#import "WebPageSettingItemModel.h"
#import "CootekNotifications.h"
#import "UserDefaultKeys.h"
#import "TouchPalVersionInfo.h"
#import "AdvancedCalllog.h"
#import "TPMFMailActionController.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "DefaultLoginController.h"
#import "DateTimeUtil.h"
#import "TPBuildTime.h"

#import "DialerUsageRecord.h"
@interface SettingsCreator() {
    AppSettingsModel*  __strong  appSettingsModel_;
}

-(SettingPageModel*) mainPage;
-(SettingPageModel*) customizeActionsPage;
-(SettingPageModel*) aboutPage;
-(SettingPageModel*) additionalLanguagePage;
-(SettingPageModel*) customizeClickPage;
-(SettingPageModel*) customizeLeftSwipePage;
-(SettingPageModel*) customizeRightSwipePage;

@end

@implementation SettingsCreator

+(SettingsCreator*) creator {
    return [[SettingsCreator alloc] initWithAppSettings:[AppSettingsModel appSettings]];
}

-(id) initWithAppSettings:(AppSettingsModel*) settings {
    self = [super init];
    if(self) {
        appSettingsModel_ = settings;
    }
    return self;
}

-(SettingPageModel*) modelForPage:(SettingPageType) settingPageType {
    switch (settingPageType) {
        case SETTING_PAGE_MAIN:
            return [self mainPage];
        case SETTING_PAGE_CUSTOMIZE_ACTIONS:
            return [self customizeActionsPage];
        case SETTING_PAGE_ABOUT:
            return [self aboutPage];
        case SETTING_PAGE_FEEDBACK:
            return [self feedbackPage];
        case SETTING_PAGE_ADDITIONAL_LANGUAGE:
            return [self additionalLanguagePage];
        case SETTING_PAGE_MUTI_LANGUAGE:
            return [self changeLanguage];
        case SETTING_PAGE_CUSTOMIZE_CLICK:
            return [self customizeClickPage];
        case SETTING_PAGE_CUSTOMIZE_LEFT_SWIPE:
            return [self customizeLeftSwipePage];
        case SETTING_PAGE_CUSTOMIZE_RIGHT_SWIPE:
            return [self customizeRightSwipePage];
        case SETTING_PAGE_GESTURE:
            return [self gestureDial];
        case SETTING_PAGE_SMART_DIAL:
            return [self dialAssistant];
        case SETTING_PAGE_VOIP_CALL:
            return [self voipCall];
        case SETTING_PAGE_DIALER:
            return [self dialerSetting];
        case SETTING_PAGE_DIALER_MODE:
            return [self dialerModeSetting];
        default:
            return nil;
    }
}

-(SettingPageModel*) mainPage {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    // Section0  mutiLanguaue
    [array addObject: [GoDetailSettingItemModel itemWithTitle:@"Language Setting" PageType:SETTING_PAGE_MUTI_LANGUAGE]];
    SettingSectionModel* section10 = [SettingSectionModel sectionWithItems:array];
    
    
    
    
    
    
    // Section1
    array = [[NSMutableArray alloc] init];
    [array addObject: [GoDetailSettingItemModel itemWithTitle:@"Gesture dialing" PageType:SETTING_PAGE_GESTURE]];
    
    [array addObject: [GoDetailSettingItemModel itemWithTitle:@"Dialing assistant" PageType:SETTING_PAGE_SMART_DIAL]];
    
    SettingSectionModel* section0 = [SettingSectionModel sectionWithItems:array];
    
    array = [[NSMutableArray alloc] init];
    if ([[[UIDevice currentDevice]systemVersion ]floatValue] < 8.0) {
        [array addObject:[SwitchSettingItemModel itemWithTitle:@"Call confirm"
                                                    settingKey:APP_SET_KEY_CALL_CONFIRM
                                                    inSettings:appSettingsModel_
                                                        action:^(BOOL isOn)
                          {
                              if (!isOn && [[UIDevice currentDevice]systemVersion].floatValue < 8.0f) {
                                  [DefaultUIAlertViewHandler showAlertViewWithTitle:@""
                                                                            message:NSLocalizedString(@"Turn off this option will lead to unable to return TouchPal after dialing","")];
                              }
                          }]];
    }
    [array addObject:[SwitchSettingItemModel itemWithTitle:@"Dial tone"
                                                settingKey:APP_SET_KEY_DIAL_TONE
                                                inSettings:appSettingsModel_]];
    [array addObject:[SwitchSettingItemModel itemWithTitle:@"Dial Vibrate"
                                          itemWithSubtitle:(TPScreenWidth() < 350 ? @"Dial Vibrate Subtitle In Iphone 4" : @"Dial Vibrate Subtitle")
                                                settingKey:APP_SET_KEY_VIBRATE_WHEN_CONNECTED
                                                inSettings:appSettingsModel_]];
    SettingSectionModel* section1 = [SettingSectionModel sectionWithItems:array];
    
    // Section 2
    array = [[NSMutableArray alloc] init];
    [array addObject:[SwitchSettingItemModel itemWithTitle:@"Display caller number location in list"
                                                settingKey:APP_SET_KEY_DISPLAY_LOCATION
                                                inSettings:appSettingsModel_]];
    SettingSectionModel* section2 = [SettingSectionModel sectionWithItems:array];

    // Section 3
    array = [NSMutableArray array];
    [array addObject: [GoDetailSettingItemModel itemWithTitle:@"About" PageType:SETTING_PAGE_ABOUT]];
#ifdef DEBUG
    [array addObject:[SwitchSettingItemModel itemWithTitle:@"国际漫游" itemWithSubtitle:nil settingKey:@"inter_roaming" inSettings:appSettingsModel_]];
    
    // 完整版本号，比如 5448
    NSString *debugVersion = [CURRENT_TOUCHPAL_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""];
    debugVersion = [NSString stringWithFormat:@"(DEBUG) %@", debugVersion];
    [array addObject:[NonOpSettingItemModel itemWithTitle:@"版本"  subTitle:nil additionalInfo:debugVersion]];
    
#ifdef TP_DEBUG_BUILD_TIME
    // 编译时刻, 比如 2016-07-14 11:14:22
    NSDate *buildDate = [NSDate dateWithTimeIntervalSince1970:TP_DEBUG_BUILD_TIME];
    NSString *buildTimeString = [DateTimeUtil dateStringByFormat:@"yyyy-MM-dd HH:mm:ss" fromDate:buildDate];
    [array addObject:[NonOpSettingItemModel itemWithTitle:@"编译时刻"  subTitle:nil additionalInfo:buildTimeString]];
    
    // 编译时的分支
    [array addObject:[NonOpSettingItemModel itemWithTitle:@"编译分支"  subTitle:nil additionalInfo:TP_DEBUG_CURRENT_BRANCH]];
    
    // 编译时的commit号
    [array addObject:[NonOpSettingItemModel itemWithTitle:@"编译commit"  subTitle:nil additionalInfo:TP_DEBUG_CURRENT_COMMIT]];
#endif
    
#endif
    
    SettingSectionModel* section3 = [SettingSectionModel sectionWithItems:array];
    
    return [SettingPageModel pageWithTitle:@"Settings" sections:[NSArray arrayWithObjects:section10, section0, section1, section2, section3,  nil] type:SETTING_PAGE_MAIN settings:appSettingsModel_];
}

-(SettingPageModel*) customizeActionsPage {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[SwitchSettingItemModel itemWithTitle:@"Switch to slide on the item"
                                                settingKey:APP_SET_SLIDE_CONFIRM
                                                inSettings:appSettingsModel_]];
    [array addObject:[GoDetailSettingItemModel itemWithTitle:@"Slide left on the item" subTitle:[appSettingsModel_ actionName:appSettingsModel_.listSwipeLeft] PageType:SETTING_PAGE_CUSTOMIZE_LEFT_SWIPE]];
    [array addObject:[GoDetailSettingItemModel itemWithTitle:@"Slide right on the item" subTitle:[appSettingsModel_ actionName:appSettingsModel_.listSwipeRight] PageType:SETTING_PAGE_CUSTOMIZE_RIGHT_SWIPE]];
    
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    [section.monitorKeys addObject:APP_SET_KEY_LSIT_SWIPELEFT];
    [section.monitorKeys addObject:APP_SET_KEY_LSIT_SWIPERIGHT];
    
    return [SettingPageModel pageWithTitle:@"Slide on the item" sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_CUSTOMIZE_ACTIONS settings:appSettingsModel_];
}

-(SettingPageModel*) aboutPage {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[NonOpSettingItemModel itemWithTitle:@"Version" subTitle:nil additionalInfo:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
    [array addObject:[NonOpSettingItemModel itemWithTitle:@"Update date" subTitle:nil additionalInfo:VERSION_DATE]];
    [array addObject:[WebPageSettingItemModel itemWithTitle:@"Privacy statement" url:@"http://www.touchpal.com/privacypolicy_contacts.html"]];
    
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    
    return [SettingPageModel pageWithTitle:@"About" sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_ABOUT settings:appSettingsModel_];
}

-(SettingPageModel*) voipCall {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    SwitchSettingItemModel *voipModel = [SwitchSettingItemModel itemWithTitle:@"voip_open_voip" itemWithSubtitle:@"voip_open_voip_hint" settingKey:IS_VOIP_ON inSettings:appSettingsModel_];
    voipModel.monitorKey = IS_VOIP_ON;
    [array addObject:voipModel];
    
    SwitchSettingItemModel *cellularModel = [SwitchSettingItemModel itemWithTitle:@"voip_allow_cellular_data" itemWithSubtitle:@"voip_allow_cellular_data_sub" settingKey:VOIP_ENABLE_CELL_DATA inSettings:appSettingsModel_];
    cellularModel.followingSettingKeys = @[IS_VOIP_ON];
    cellularModel.monitorKey = VOIP_ENABLE_CELL_DATA;
    [array addObject:cellularModel];
    
    SwitchSettingItemModel *cellularInterModel = [SwitchSettingItemModel itemWithTitle:@"voip_inter_cellular_receiving" itemWithSubtitle:@"voip_inter_cellular_receiving_sub" settingKey:VOIP_INTERNATIONAL_ENABLE_CELL_DATA inSettings:appSettingsModel_];
    cellularInterModel.followingSettingKeys = @[IS_VOIP_ON, VOIP_ENABLE_CELL_DATA];
    [array addObject:cellularInterModel];
    
    SwitchSettingItemModel *callBackAuto = [SwitchSettingItemModel itemWithTitle:@"voip_backcall_on" itemWithSubtitle:@"voip_backcall_on2gor3gMobile" settingKey:VOIP_AUTO_BACK_CALL_ENABLE inSettings:appSettingsModel_];
    callBackAuto.followingSettingKeys = @[IS_VOIP_ON];
    [array addObject:callBackAuto];
    
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    
    SettingPageModel *page = [SettingPageModel pageWithTitle:@"免费电话" sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_VOIP_CALL settings:appSettingsModel_];
    page.cellHeight = VOIP_CELL_HEIGHT;
    return page;
}

-(SettingPageModel*) feedbackPage {
//    NSMutableArray* array = [[NSMutableArray alloc] init];
//    [array addObject: [ActionableSettingItemModel itemWithTitle:@"Feedback_email" actionBlock:^(UIViewController* vc) {
//        NSString* receiver = @"contacts@touchpal.com";
//        NSString* subject = NSLocalizedString(@"TouchPal Contacts Feedback","");
//        UIDevice *device=[UIDevice currentDevice];
//        NSString* message = [NSString stringWithFormat:@"Device Info : %@ \n iOS Info : %@%@\n Version : %@",
//                             device.model,
//                             device.systemName,
//                             device.systemVersion,
//                             CURRENT_TOUCHPAL_VERSION];
//        [[TPMFMailActionController controller] sendEmailToAddress:receiver withSubject:subject withMessage:message presentedBy:vc];
//    }]];
//
//    [array addObject:[WebPageSettingItemModel itemWithTitle:@"FAQ" url:@"http://www.touchpal.com/mtouchpal/faqpages/faqv40iosen.html"]];
//    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
//    [array release];
    [UserDefaultsManager setBoolValue:NO forKey:UMFEEDBACK_NEW_HINT];
    return [SettingPageModel pageWithTitle:@"Feedback" sections:nil type:SETTING_PAGE_FEEDBACK settings:appSettingsModel_];
}

- (SettingPageModel*) gestureDial {
    return [SettingPageModel pageWithTitle:@"Gesture" sections:nil type:SETTING_PAGE_GESTURE settings:appSettingsModel_];
}

- (SettingPageModel*)dialAssistant {
    return [SettingPageModel pageWithTitle:@"DialAssistant" sections:nil type:SETTING_PAGE_SMART_DIAL settings:appSettingsModel_];
}

- (SettingPageModel*) dialerSetting {
    [DialerUsageRecord recordpath:PATH_DIAL_SETTING kvs:Pair(ENTER_DIAL_SETTING, @(1)), nil];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    __block SwitchSettingItemModel *voipModel = [SwitchSettingItemModel itemWithTitle:@"voip_open_voip" itemWithSubtitle:@"voip_open_voip_hint" settingKey:IS_VOIP_ON inSettings:appSettingsModel_ action:nil preAction:nil];
    if(![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        voipModel.preActionBlock = ^(){
            [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"dialer_setting" andLoginSuccessBlock:^{
                voipModel.preActionBlock = nil;
                voipModel = nil;
            }]];
        };
    }
    voipModel.monitorKey = IS_VOIP_ON;
    voipModel.closeAlertStr = @"关闭后将无法再使用免费电话功能，您确定要关闭么？";
    [array addObject:voipModel];
    SettingSectionModel* section1 = [SettingSectionModel sectionWithItems:array];
    
    // Section 2
    array = [[NSMutableArray alloc] init];
    
    [array addObject:[GoDetailSettingItemModel itemWithTitle:NSLocalizedString(@"dialer_mode", "") subTitle: [appSettingsModel_ DialerModeName:appSettingsModel_.dialerMode] PageType:SETTING_PAGE_DIALER_MODE]];
    [array addObject:[GoDetailSettingItemModel itemWithTitle:@"Slide on the item" subTitle:[[AppSettingsModel appSettings]slide_confirm]?NSLocalizedString(@"Opening",""):NSLocalizedString(@"Closing","") PageType:SETTING_PAGE_CUSTOMIZE_ACTIONS]];
    
    [array addObject:[GoDetailSettingItemModel itemWithTitle:@"Click the item"
                                                    subTitle:[appSettingsModel_ actionName:appSettingsModel_.listClick]
                                                    PageType:SETTING_PAGE_CUSTOMIZE_CLICK]];
    SettingSectionModel* section2 = [SettingSectionModel sectionWithItems:array];
    return [SettingPageModel pageWithTitle:NSLocalizedString(@"dialer_setting", @"") sections:[NSArray arrayWithObjects:section1,section2,nil] type:SETTING_PAGE_DIALER settings:appSettingsModel_];
}

- (SettingPageModel*) dialerModeSetting {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    SingleSelectionSettingItemModel * itemAsk = [SingleSelectionSettingItemModel itemWithTitle:NSLocalizedString(@"dialer_mode_ask", "") settingKey:APP_SET_KEY_DIALER_MODE forExpectedValue:[NSNumber numberWithInt:DialerModeAlwaysAsk] inSettings:appSettingsModel_];
    SingleSelectionSettingItemModel* itemVoip = [SingleSelectionSettingItemModel itemWithTitle:NSLocalizedString(@"dialer_mode_voip", "") settingKey:APP_SET_KEY_DIALER_MODE forExpectedValue:[NSNumber numberWithInt:DialerModeVoip] inSettings:appSettingsModel_];
    if(![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] || ![UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        [itemAsk setIsEnabled:NO];
        [itemVoip setIsEnabled:NO];
    }
    [array addObject:itemAsk];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:NSLocalizedString(@"dialer_mode_normal", "") settingKey:APP_SET_KEY_DIALER_MODE forExpectedValue:[NSNumber numberWithInt:DialerModeNormal] inSettings:appSettingsModel_]];
    [array addObject:itemVoip];
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    [section.monitorKeys addObject:APP_SET_KEY_DIALER_MODE];
    return [SettingPageModel pageWithTitle:NSLocalizedString(@"dialer_mode", "") sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_DIALER_MODE settings:appSettingsModel_];
}

-(SettingPageModel*) additionalLanguagePage {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Default" settingKey:APP_SET_KEY_SECONDARY_LANGUAGE forExpectedValue:[NSNumber numberWithInt:KeyboardLanguageStandard] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Greek" settingKey:APP_SET_KEY_SECONDARY_LANGUAGE forExpectedValue:[NSNumber numberWithInt:KeyboardLanguageGreek] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Hebrew" settingKey:APP_SET_KEY_SECONDARY_LANGUAGE forExpectedValue:[NSNumber numberWithInt:KeyboardLanguageHebrew] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Persian" settingKey:APP_SET_KEY_SECONDARY_LANGUAGE forExpectedValue:[NSNumber numberWithInt:KeyboardLanguageFarsi] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Russian" settingKey:APP_SET_KEY_SECONDARY_LANGUAGE forExpectedValue:[NSNumber numberWithInt:KeyboardLanguageRussian] inSettings:appSettingsModel_]];
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    [section.monitorKeys addObject:APP_SET_KEY_SECONDARY_LANGUAGE];
    return [SettingPageModel pageWithTitle:@"Secondary language" sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_ADDITIONAL_LANGUAGE settings:appSettingsModel_];}

-(SettingPageModel*) changeLanguage {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"跟随系统" settingKey:APP_SET_KEY_MUTI_LANGUAGE forExpectedValue:[NSNumber numberWithInt:LanguageStandard] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"简体中文" settingKey:APP_SET_KEY_MUTI_LANGUAGE forExpectedValue:[NSNumber numberWithInt:ChineseSimplified] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"繁体中文" settingKey:APP_SET_KEY_MUTI_LANGUAGE forExpectedValue:[NSNumber numberWithInt:ChineseTraditional] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"English" settingKey:APP_SET_KEY_MUTI_LANGUAGE forExpectedValue:[NSNumber numberWithInt:English] inSettings:appSettingsModel_]];
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    [section.monitorKeys addObject:APP_SET_KEY_MUTI_LANGUAGE];
    return [SettingPageModel pageWithTitle:@"Language Setting" sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_MUTI_LANGUAGE settings:appSettingsModel_];
}

-(SettingPageModel*) customizeClickPage {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Dial" settingKey:APP_SET_KEY_LSIT_ONCLICK forExpectedValue:[NSNumber numberWithInt:(int)CellListFunctionTypeOnCall] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Show all numbers" settingKey:APP_SET_KEY_LSIT_ONCLICK forExpectedValue:[NSNumber numberWithInt:(int)CellListFunctionTypeShowAllnumbers] inSettings:appSettingsModel_]];
    
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    [section.monitorKeys addObject:APP_SET_KEY_LSIT_ONCLICK];

    return [SettingPageModel pageWithTitle:@"Click the item" sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_CUSTOMIZE_CLICK settings:appSettingsModel_];
}
-(SettingPageModel*) customizeLeftSwipePage {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Dial" settingKey:APP_SET_KEY_LSIT_SWIPELEFT forExpectedValue:[NSNumber numberWithInt:(int)CellListFunctionTypeOnCall] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Send message" settingKey:APP_SET_KEY_LSIT_SWIPELEFT forExpectedValue:[NSNumber numberWithInt:(int)CellListFunctionTypeSendSms] inSettings:appSettingsModel_]];
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    [section.monitorKeys addObject:APP_SET_KEY_LSIT_SWIPELEFT];
    
    return [SettingPageModel pageWithTitle:@"Slide left on the item" sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_CUSTOMIZE_LEFT_SWIPE settings:appSettingsModel_];
}
-(SettingPageModel*) customizeRightSwipePage {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Dial" settingKey:APP_SET_KEY_LSIT_SWIPERIGHT forExpectedValue:[NSNumber numberWithInt:(int)CellListFunctionTypeOnCall] inSettings:appSettingsModel_]];
    [array addObject:[SingleSelectionSettingItemModel itemWithTitle:@"Send message" settingKey:APP_SET_KEY_LSIT_SWIPERIGHT forExpectedValue:[NSNumber numberWithInt:(int)CellListFunctionTypeSendSms] inSettings:appSettingsModel_]];
    SettingSectionModel* section = [SettingSectionModel sectionWithItems:array];
    [section.monitorKeys addObject:APP_SET_KEY_LSIT_SWIPERIGHT];
    
    return [SettingPageModel pageWithTitle:@"Slide right on the item" sections:[NSArray arrayWithObject:section] type:SETTING_PAGE_CUSTOMIZE_RIGHT_SWIPE settings:appSettingsModel_];
}

@end
