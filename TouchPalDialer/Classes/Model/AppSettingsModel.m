//
//  AppSettingsModel.m
//  TouchPalDialer
//
//  Created by Sendor on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppSettingsModel.h"
#import "CootekNotifications.h"
#import "PhonePadModel.h"
#import "TPDialerResourceManager.h"
#import "AdvancedCalllog.h"
#import "UserDefaultsManager.h"
#import "ScheduleInternetVisit.h"
#import "EdgeSelector.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"
#import "PJSIPManager.h"
#import "Reachability.h"
#import "LanguageUtil.h"
#import "DefaultUIAlertViewHandler.h"
static AppSettingsModel *instance_ = nil;

@implementation AppSettingsModel
@synthesize listClick;
@synthesize listSwipeLeft;
@synthesize listSwipeRight;
@synthesize secondary_language;
@synthesize language;
@synthesize dial_tone;
@synthesize call_confirm;
@synthesize slide_confirm;
@synthesize format_phone_numbers;
@synthesize display_location;
@synthesize synchronize_profiles;
@synthesize availability;
@synthesize version;
@synthesize date;
@synthesize privacy_tatement;
@synthesize change_log;
@synthesize faq;
@synthesize smart_eye;
@synthesize vibrate_when_connected;
@synthesize vibrate_when_disconnected;
@synthesize isShareToSina;
@synthesize dialerMode;

+(AppSettingsModel *)appSettings
{
    return instance_;
}

+ (void)initialize
{
    [self mergeApplicationSettings];
    instance_ = [[self alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        NSString* appSettingsFilePathName = [AppSettingsModel getAppSettingsDataFileName];
        app_settiings_dict = [[NSMutableDictionary alloc] initWithContentsOfFile:appSettingsFilePathName];
        secondary_language = KeyboardLanguageStandard;
        
        listClick = [[app_settiings_dict objectForKey:APP_SET_KEY_LSIT_ONCLICK] intValue];
        if (listClick != CellListFunctionTypeOnCall && listClick != CellListFunctionTypeShowAllnumbers) {
            [app_settiings_dict setObject: [NSNumber numberWithInt:CellListFunctionTypeOnCall] forKey:APP_SET_KEY_LSIT_ONCLICK];
            listClick = CellListFunctionTypeOnCall;
        }
        listSwipeLeft = [[app_settiings_dict objectForKey:APP_SET_KEY_LSIT_SWIPELEFT] intValue];
        listSwipeRight = [[app_settiings_dict objectForKey:APP_SET_KEY_LSIT_SWIPERIGHT] intValue];
        
        dial_tone = [[app_settiings_dict objectForKey:APP_SET_KEY_DIAL_TONE] boolValue];
        call_confirm = [[app_settiings_dict objectForKey:APP_SET_KEY_CALL_CONFIRM] boolValue];
        slide_confirm = [[app_settiings_dict objectForKey:APP_SET_SLIDE_CONFIRM]boolValue];
        format_phone_numbers = [[app_settiings_dict objectForKey:APP_SET_KEY_FORMAT_PHONE_NUMBERS] boolValue];
        display_location = [[app_settiings_dict objectForKey:APP_SET_KEY_DISPLAY_LOCATION] boolValue];
        synchronize_profiles = [[app_settiings_dict objectForKey:APP_SET_KEY_SYNCHRONIZE_PROFILES] boolValue];
        populate_photos = [[app_settiings_dict objectForKey:APP_SET_KEY_POPULATE_PHOTOS] boolValue];
        availability = [[app_settiings_dict objectForKey:APP_SET_KEY_AVAILABILITY] boolValue];
        reminder_tone = [[app_settiings_dict objectForKey:APP_SET_KEY_REMINDER_TONE] boolValue];
        reminder_vibrate = [[app_settiings_dict objectForKey:APP_SET_KEY_REMINDER_VIBRATE] boolValue];
        smart_eye = [[app_settiings_dict objectForKey:APP_SET_KEY_SMARTEYE] boolValue];
        vibrate_when_connected = [[app_settiings_dict objectForKey:APP_SET_KEY_VIBRATE_WHEN_CONNECTED]boolValue];
        vibrate_when_disconnected = [[app_settiings_dict objectForKey:APP_SET_KEY_VIBRATE_WHEN_DISCONNECTED]boolValue];
        version = [app_settiings_dict objectForKey:APP_SET_KEY_VERSION];
        date = [app_settiings_dict objectForKey:APP_SET_KEY_DATE];
        privacy_tatement = [app_settiings_dict objectForKey:APP_SET_KEY_PRIVACY_STATEMENT];
        change_log = [app_settiings_dict objectForKey:APP_SET_KEY_CHANGE_LOG];
        faq = [app_settiings_dict objectForKey:APP_SET_KEY_FAQ];
        isShareToSina = [[app_settiings_dict objectForKey:APP_SET_KEY_SHARE_TO_SINA] boolValue];
        language = [[app_settiings_dict objectForKey:APP_SET_KEY_MUTI_LANGUAGE ] intValue];
        dialerMode = [[app_settiings_dict objectForKey:APP_SET_KEY_DIALER_MODE] intValue];
        if(dialerMode != DialerModeAlwaysAsk && dialerMode != DialerModeVoip) {
            [app_settiings_dict setObject:[NSNumber numberWithInt:DialerModeNormal] forKey:APP_SET_KEY_DIALER_MODE];
            dialerMode = DialerModeNormal;
        }
    }
    
    return self;
}

- (void)setSecondary_language:(PhonePadLanguage)secondaryLanguage {
    if (secondary_language != secondaryLanguage) {
        secondary_language = secondaryLanguage;
        [app_settiings_dict setObject:[NSNumber numberWithInt:secondary_language] forKey:APP_SET_KEY_SECONDARY_LANGUAGE];
        [self notificateChange:APP_SET_KEY_SECONDARY_LANGUAGE];
    }
}
- (NSString *)actionName:(CellListFunctionType)action{
    NSString *title  = nil;
    switch (action) {
        case CellListFunctionTypeOnCall:
            title = NSLocalizedString(@"Dial",@"打电话");;
            break;
        case CellListFunctionTypeSendSms:
            title = NSLocalizedString(@"send_message",@"发送短信");
            break;
        case CellListFunctionTypeShowAllnumbers:
            title = NSLocalizedString(@"Show all numbers",@"显示所有号码");
            break;
        case CellListFunctionTypeClearLogs:
            title = NSLocalizedString(@"Clear call logs","");
            break;
        default:
            break;
    }
    return title;
}

- (NSString *)DialerModeName:(DialerModeType)mode {
    NSString *title = nil;
    switch (mode) {
        case DialerModeNormal:
            title = NSLocalizedString(@"dialer_mode_normal", "");
            break;
        case DialerModeVoip:
            title = NSLocalizedString(@"dialer_mode_voip", "");
            break;
        default:
            title = NSLocalizedString(@"dialer_mode_ask", "");
    }
    return title;
}

- (NSArray *)allActions{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:CellListFunctionTypeOnCall],[NSNumber numberWithInt:CellListFunctionTypeSendSms],[NSNumber numberWithInt:CellListFunctionTypeShowAllnumbers],[NSNumber numberWithInt:CellListFunctionTypeClearLogs],nil];
}
-(NSArray *)allClickActions{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:CellListFunctionTypeOnCall],[NSNumber numberWithInt:CellListFunctionTypeSendSms],[NSNumber numberWithInt:CellListFunctionTypeShowAllnumbers],nil];
}
- (void)setListClick:(CellListFunctionType)tmplistClick{
    if (listClick != tmplistClick) {
        listClick = tmplistClick;
        [app_settiings_dict setObject:[NSNumber numberWithInt:listClick] forKey:APP_SET_KEY_LSIT_ONCLICK];
        [self notificateChange:APP_SET_KEY_LSIT_ONCLICK];
    }
}
- (void)setListSwipeLeft:(CellListFunctionType)tmplistSwipeLeft{
    if (listSwipeLeft != tmplistSwipeLeft) {
        listSwipeLeft = tmplistSwipeLeft;
        [app_settiings_dict setObject:[NSNumber numberWithInt:listSwipeLeft] forKey:APP_SET_KEY_LSIT_SWIPELEFT];
        [self notificateChange:APP_SET_KEY_LSIT_SWIPELEFT];
    }
}
- (void)setListSwipeRight:(CellListFunctionType)tmplistSwipeRight{
    if (listSwipeRight != tmplistSwipeRight) {
        listSwipeRight = tmplistSwipeRight;
        [app_settiings_dict setObject:[NSNumber numberWithInt:listSwipeRight] forKey:APP_SET_KEY_LSIT_SWIPERIGHT];
        [self notificateChange:APP_SET_KEY_LSIT_SWIPERIGHT];
    }
}

- (void)setDialerMode:(DialerModeType)tmpDialerMode {
    if(dialerMode != tmpDialerMode) {
        dialerMode = tmpDialerMode;
        [app_settiings_dict setObject:[NSNumber numberWithInt:dialerMode] forKey:
         APP_SET_KEY_DIALER_MODE];
        [self notificateChange:APP_SET_KEY_DIALER_MODE];
    }
}


- (void)setDial_tone:(BOOL)dialTone {
    if (dial_tone != dialTone) {
        dial_tone = dialTone;
        [app_settiings_dict setObject:[NSNumber numberWithBool:dial_tone] forKey:APP_SET_KEY_DIAL_TONE];
        [self notificateChange:APP_SET_KEY_DIAL_TONE];
    }
}

- (void)setCall_confirm:(BOOL)callConfirm {
    if (call_confirm != callConfirm) {
        call_confirm = callConfirm;
        [app_settiings_dict setObject:[NSNumber numberWithBool:call_confirm] forKey:APP_SET_KEY_CALL_CONFIRM];
        [self notificateChange:APP_SET_KEY_CALL_CONFIRM];
    }
}

- (void)setSlide_confirm:(BOOL)slideConfirm{
    if (slide_confirm != slideConfirm) {
        slide_confirm = slideConfirm;
        [app_settiings_dict setObject:[NSNumber numberWithBool:slide_confirm] forKey:APP_SET_SLIDE_CONFIRM];
        [self notificateChange:APP_SET_SLIDE_CONFIRM];
    }
}

- (void)setFormat_phone_numbers:(BOOL)formatPhoneNumbers {
    if (format_phone_numbers != formatPhoneNumbers) {
        format_phone_numbers = formatPhoneNumbers;
        [app_settiings_dict setObject:[NSNumber numberWithBool:format_phone_numbers] forKey:APP_SET_KEY_FORMAT_PHONE_NUMBERS];
        [self notificateChange:APP_SET_KEY_FORMAT_PHONE_NUMBERS];
    }
}

- (void)setDisplay_location:(BOOL)displayLocation {
    if (display_location != displayLocation) {
        display_location = displayLocation;
        [app_settiings_dict setObject:[NSNumber numberWithBool:display_location] forKey:APP_SET_KEY_DISPLAY_LOCATION];
        [self notificateChange:APP_SET_KEY_DISPLAY_LOCATION];
    }
}

- (void)setSynchronize_profiles:(BOOL)synchronizeProfiles {
    if (synchronize_profiles != synchronizeProfiles) {
        synchronize_profiles = synchronizeProfiles;
        [app_settiings_dict setObject:[NSNumber numberWithBool:synchronize_profiles] forKey:APP_SET_KEY_SYNCHRONIZE_PROFILES];
        [self notificateChange:APP_SET_KEY_SYNCHRONIZE_PROFILES];
    }
}

- (void)setPopulate_photos:(BOOL)populatePhotos {
    if (populate_photos != populatePhotos) {
        populate_photos = populatePhotos;
        [app_settiings_dict setObject:[NSNumber numberWithBool:populate_photos] forKey:APP_SET_KEY_POPULATE_PHOTOS];
        [self notificateChange:APP_SET_KEY_POPULATE_PHOTOS];
    }
}

- (void)setLanguage:(Language)tmpLanguage {
        typeof(self) weakSelf = self;
    [LanguageUtil getCurrentLanguage];
    language = tmpLanguage;
    [app_settiings_dict setObject:[NSNumber numberWithInt:language] forKey:APP_SET_KEY_MUTI_LANGUAGE];
    [UserDefaultsManager setIntValue:[UserDefaultsManager intValueForKey:APP_SET_KEY_MUTI_LANGUAGE] forKey:LAST_APP_LANGUAGE];
            [DefaultUIAlertViewHandler showAlertViewWithTitle:@"切换语言需要重新启动通通宝，确认切换？" message:nil okButtonActionBlock:^(){
                [LanguageUtil setCurrentLanguage:language];
                [weakSelf notificateChange:APP_SET_KEY_MUTI_LANGUAGE];
                [UserDefaultsManager setIntValue:language forKey:APP_SET_KEY_MUTI_LANGUAGE];
                exit(0);
            }cancelActionBlock:^{
                [app_settiings_dict setObject:[NSNumber numberWithInt:[UserDefaultsManager intValueForKey:LAST_APP_LANGUAGE]] forKey:APP_SET_KEY_MUTI_LANGUAGE];
            }];
}

- (BOOL)populate_photos {
    if(synchronize_profiles) {
        return [[app_settiings_dict valueForKey:APP_SET_KEY_POPULATE_PHOTOS] boolValue];
    }
    
    return NO;
}

- (void)setAvailability:(BOOL)paraAvailability {
    if ([[app_settiings_dict valueForKey:APP_SET_KEY_AVAILABILITY] boolValue] != paraAvailability) {
        availability = paraAvailability;
        [app_settiings_dict setObject:[NSNumber numberWithBool:paraAvailability] forKey:APP_SET_KEY_AVAILABILITY];
        [self notificateChange:APP_SET_KEY_AVAILABILITY];
    }
}

- (void)setReminder_tone:(BOOL)reminderTone {
    if ([[app_settiings_dict valueForKey:APP_SET_KEY_REMINDER_TONE] boolValue] != reminderTone) {
        reminder_tone = reminderTone;
        [app_settiings_dict setObject:[NSNumber numberWithBool:reminderTone] forKey:APP_SET_KEY_REMINDER_TONE];
        [self notificateChange:APP_SET_KEY_REMINDER_TONE];
    }
}

- (void)setReminder_vibrate:(BOOL)reminderVibrate {
    if ([[app_settiings_dict valueForKey:APP_SET_KEY_REMINDER_VIBRATE] boolValue] != reminderVibrate) {
        reminder_vibrate = reminderVibrate;
        [app_settiings_dict setObject:[NSNumber numberWithBool:reminderVibrate] forKey:APP_SET_KEY_REMINDER_VIBRATE];
        [self notificateChange:APP_SET_KEY_REMINDER_VIBRATE];
    }
}

-(BOOL) reminder_tone {
    if(availability) {
        return [[app_settiings_dict valueForKey:APP_SET_KEY_REMINDER_TONE] boolValue];
    }
    
    return NO;
}

-(BOOL) reminder_vibrate {
    if(availability) {
        return [[app_settiings_dict valueForKey:APP_SET_KEY_REMINDER_VIBRATE] boolValue];
    }
    
    return NO;
}

- (void)setSmart_eye:(BOOL)smartEye{
    if(smart_eye!=smartEye){
        smart_eye = smartEye;
        //设置
        [app_settiings_dict setObject:[NSNumber numberWithBool:smart_eye] forKey:APP_SET_KEY_SMARTEYE];
        [self notificateChange:APP_SET_KEY_SMARTEYE];
        [AdvancedCalllog addAdvancedSetting:[NSNumber numberWithBool:smart_eye] forKey:ADVANCED_SETTING_USE_NETWORK_SMART_EYE];
    }
}

- (BOOL)isShareToSina{
    return [[app_settiings_dict valueForKey:APP_SET_KEY_SHARE_TO_SINA] boolValue];
}

- (void)setIsShareToSina:(BOOL)tmpisShareToSina{
    if(tmpisShareToSina != isShareToSina){
        isShareToSina = tmpisShareToSina;
        [app_settiings_dict setObject:@(isShareToSina)forKey:APP_SET_KEY_SHARE_TO_SINA];
    }
}


- (void)setVibrate_when_connected:(BOOL)vibrateWhenConnected {
    if(vibrate_when_connected!=vibrateWhenConnected){
        vibrate_when_connected = vibrateWhenConnected;
        [app_settiings_dict setObject:[NSNumber numberWithBool:vibrate_when_connected] forKey:APP_SET_KEY_VIBRATE_WHEN_CONNECTED];
        [self notificateChange:APP_SET_KEY_VIBRATE_WHEN_CONNECTED];
    }
}

- (void)setVibrate_when_disconnected:(BOOL)vibrateWhenDisconnected {
    if(vibrate_when_disconnected!=vibrateWhenDisconnected){
        vibrate_when_disconnected = vibrateWhenDisconnected;
        [app_settiings_dict setObject:[NSNumber numberWithBool:vibrate_when_disconnected] forKey:APP_SET_KEY_VIBRATE_WHEN_DISCONNECTED];
        [self notificateChange:APP_SET_KEY_VIBRATE_WHEN_DISCONNECTED];
    }
}

- (id) settingValueForKey:(NSString*)key {
    if ([key isEqualToString:APP_SET_KEY_POPULATE_PHOTOS]) {
        return [NSNumber numberWithBool:self.populate_photos];
    }else if ([key isEqualToString:APP_SET_KEY_REMINDER_TONE]) {
        return [NSNumber numberWithBool:self.reminder_tone];
    }else if ([key isEqualToString:APP_SET_KEY_REMINDER_VIBRATE]) {
        return [NSNumber numberWithBool:self.reminder_vibrate];
    }else if ([key isEqualToString:IS_VOIP_ON]) {
        return [UserDefaultsManager objectForKey:IS_VOIP_ON];
    }else if ([key isEqualToString:VOIP_AUTO_BACK_CALL_ENABLE]) {
        return [UserDefaultsManager objectForKey:VOIP_AUTO_BACK_CALL_ENABLE];
    }else if ([key isEqualToString:VOIP_INTERNATIONAL_ENABLE_CELL_DATA]) {
        return [UserDefaultsManager objectForKey:VOIP_INTERNATIONAL_ENABLE_CELL_DATA];
    }else if ([key isEqualToString:APP_SET_KEY_INTER_ROAMING]) {
        return [UserDefaultsManager objectForKey:APP_SET_KEY_INTER_ROAMING];
    }else if ([key isEqualToString:VOIP_ENABLE_CELL_DATA]) {
        return [UserDefaultsManager objectForKey:VOIP_ENABLE_CELL_DATA];
    }else if ([key isEqualToString:ANTIHARASS_IS_ON]) {
        return [UserDefaultsManager objectForKey:ANTIHARASS_IS_ON];
    }else if ([key isEqualToString:ANTIHARASS_AUTOUPDATEINWIFI_ON]) {
        return [UserDefaultsManager objectForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON];
    }else if ([key isEqualToString:CALL_DIRECTORY_EXTENSION_AUTHORIZATION]) {
        return [UserDefaultsManager objectForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION];
    }else if([key isEqualToString:CALL_DIRECTORY_EXTENSION_AUTO_UPDATE]) {
        return [UserDefaultsManager objectForKey:CALL_DIRECTORY_EXTENSION_AUTO_UPDATE];
    }
    
    return [app_settiings_dict valueForKey:key];
}

- (void)setSettingValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:APP_SET_KEY_SECONDARY_LANGUAGE]) {
        self.secondary_language = [value intValue]; 
    }else if ([key isEqualToString:APP_SET_KEY_DIAL_TONE]) {
        self.dial_tone = [value boolValue];
    }else if ([key isEqualToString:APP_SET_KEY_CALL_CONFIRM]) {
        self.call_confirm = [value boolValue];
    }else if ([key isEqualToString:APP_SET_KEY_FORMAT_PHONE_NUMBERS]) {
        self.format_phone_numbers = [value boolValue];
    }else if ([key isEqualToString:APP_SET_KEY_DISPLAY_LOCATION]) {
        self.display_location = [value boolValue];
    }else if ([key isEqualToString:APP_SET_KEY_SYNCHRONIZE_PROFILES]) {
        self.synchronize_profiles = [value boolValue];
    }else if ([key isEqualToString:APP_SET_KEY_POPULATE_PHOTOS]) {
        self.populate_photos = [value boolValue];
    }else if ([key isEqualToString:APP_SET_KEY_AVAILABILITY]) {
        self.availability = [value boolValue];
    }else if ([key isEqualToString:APP_SET_KEY_REMINDER_TONE]) {
        self.reminder_tone = [value boolValue];
    }else if ([key isEqualToString:APP_SET_KEY_REMINDER_VIBRATE]) {
        self.reminder_vibrate = [value boolValue];
    }else if([key isEqualToString:APP_SET_KEY_SMARTEYE]){
        self.smart_eye = [value boolValue];
    }else if([key isEqualToString:APP_SET_KEY_LSIT_ONCLICK]) {
        self.listClick = (CellListFunctionType) [value intValue];
    }else if([key isEqualToString:APP_SET_KEY_LSIT_SWIPELEFT]) {
        self.listSwipeLeft = (CellListFunctionType) [value intValue];
    }else if([key isEqualToString:APP_SET_KEY_LSIT_SWIPERIGHT]) {
        self.listSwipeRight = (CellListFunctionType) [value intValue];
    }else if([key isEqualToString:APP_SET_KEY_VIBRATE_WHEN_CONNECTED]) {
        self.vibrate_when_connected = [value boolValue];
    }else if([key isEqualToString:APP_SET_KEY_VIBRATE_WHEN_DISCONNECTED]) {
        self.vibrate_when_disconnected = [value boolValue];
    }else if([key isEqualToString:APP_SET_SLIDE_CONFIRM]){
        self.slide_confirm = [value boolValue];
        [DialerUsageRecord recordpath:PATH_DIAL_SETTING kvs:Pair(OPENED_RIGET_LEFT,[NSNumber numberWithBool:self.slide_confirm]), nil];
    }else if([key isEqualToString:IS_VOIP_ON]) {
        [UserDefaultsManager setObject:value forKey:IS_VOIP_ON];
        if([UserDefaultsManager boolValueForKey:IS_VOIP_ON defaultValue:NO]) {
            self.dialerMode = DialerModeAlwaysAsk;
        }else {
            self.dialerMode = DialerModeNormal;
        }
        [ScheduleInternetVisit checkVoipConfigFiles:YES];
        [FunctionUtility writeDefaultKeyToDefaults:@"group.com.cootek.Contacts" andObject:[NSString stringWithFormat:@"%d",[UserDefaultsManager boolValueForKey:IS_VOIP_ON defaultValue:NO]] andKey:@"isVoipOn"];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_IS_VOIP_ON object:nil];
            [self notificateChange:key];
        });
    }else if([key isEqualToString:VOIP_AUTO_BACK_CALL_ENABLE]) {
        [UserDefaultsManager setObject:value forKey:VOIP_AUTO_BACK_CALL_ENABLE];
    }else if([key isEqualToString:APP_SET_KEY_INTER_ROAMING]) {
        [UserDefaultsManager setObject:value forKey:APP_SET_KEY_INTER_ROAMING];
    }else if ([key isEqualToString:VOIP_ENABLE_CELL_DATA] ||
              [key isEqualToString:VOIP_INTERNATIONAL_ENABLE_CELL_DATA]){
        [UserDefaultsManager setObject:value forKey:key];
        [PJSIPManager checkInit];
     
        [self notificateChange:key];
    }else if([key isEqualToString:ANTIHARASS_IS_ON]) {
        [UserDefaultsManager setObject:value forKey:ANTIHARASS_IS_ON];
    }
    else if([key isEqualToString:ANTIHARASS_AUTOUPDATEINWIFI_ON]) {
        [UserDefaultsManager setObject:value forKey:ANTIHARASS_AUTOUPDATEINWIFI_ON];
    }else if([key isEqualToString:APP_SET_KEY_MUTI_LANGUAGE]) {
        self.language = [value intValue];
    }else if([key isEqualToString:APP_SET_KEY_DIALER_MODE]) {
        self.dialerMode = (DialerModeType)[value intValue];
    }
    [self saveToFile];
}

+ (void)mergeApplicationSettings {
    NSError *error = nil;
    NSFileManager *fileManager  = [NSFileManager defaultManager];

    // load new app settings
    NSString* resourceSettingsFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[AppSettingsModel getAppSettingsDataFileNameNoPath]];
    NSMutableDictionary *newAppSettingsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:resourceSettingsFileName];

    // load old settings
    NSString* appSettingsFilePathName = [AppSettingsModel getAppSettingsDataFileName];
    if ([fileManager fileExistsAtPath:appSettingsFilePathName]) {
        NSDictionary *oldAppSettiingsDict = [NSDictionary dictionaryWithContentsOfFile:appSettingsFilePathName];
        // merge
        [newAppSettingsDict addEntriesFromDictionary:oldAppSettiingsDict];
        // delete old files
        [fileManager removeItemAtPath:appSettingsFilePathName error:&error];
    }
    // save
    if (![newAppSettingsDict writeToFile:appSettingsFilePathName atomically:YES]) {
        cootek_log(@"Failed to write to file");
    }

}

+ (NSString*)getAppSettingsDataFileNameNoPath {
    return @"appSettingsData.plist";
}

+ (NSString*) getAppSettingsDataFileName {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [paths objectAtIndex:0];
	return  [documentPath stringByAppendingPathComponent:[AppSettingsModel getAppSettingsDataFileNameNoPath]];
}

-(void)saveToFile {
    if (![app_settiings_dict writeToFile:[AppSettingsModel getAppSettingsDataFileName] atomically:YES]) {
        cootek_log(@"Failed to write to file");
    }
}

- (void)notificateChange:(NSString*)key {
    [[NSNotificationCenter defaultCenter] postNotificationName:N_SETTINGS_ITEM_CHANGED object:key];
}

@end

