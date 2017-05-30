//
//  AppSettingsModel.h
//  TouchPalDialer
//
//  Created by Sendor on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define APP_SET_KEY_MUTI_LANGUAGE           @"MutiLanguage"
#define APP_SET_KEY_SECONDARY_LANGUAGE      @"SecondaryLanguage"
#define APP_SET_KEY_DIAL_TONE               @"DialTone"
#define APP_SET_SLIDE_CONFIRM               @"SlideConfirm"
#define APP_SET_KEY_CALL_CONFIRM            @"CallConfirm"
#define APP_SET_KEY_FORMAT_PHONE_NUMBERS    @"FormatPhoneNumbers"
#define APP_SET_KEY_DISPLAY_LOCATION        @"DisplayLocation"
#define APP_SET_KEY_SYNCHRONIZE_PROFILES    @"SynchronizeProfiles"
#define APP_SET_KEY_POPULATE_PHOTOS         @"PopulatePhotos"
#define APP_SET_KEY_AVAILABILITY            @"Availability"
#define APP_SET_KEY_REMINDER_TONE           @"ReminderTone"
#define APP_SET_KEY_REMINDER_VIBRATE        @"ReminderVibrate"
#define APP_SET_KEY_VERSION                 @"Version"
#define APP_SET_KEY_DATE                    @"Date"
#define APP_SET_KEY_PRIVACY_STATEMENT       @"PrivacyStatement"
#define APP_SET_KEY_CHANGE_LOG              @"ChangeLog"
#define APP_SET_KEY_FAQ                     @"FAQ"

#define APP_SET_KEY_SMARTEYE                @"SmartEye"
#define APP_SET_KEY_LSIT_ONCLICK            @"ListOnClick"
#define APP_SET_KEY_LSIT_SWIPELEFT          @"ListSwipeLeft"
#define APP_SET_KEY_LSIT_SWIPERIGHT         @"ListSwipeRight"
#define APP_SET_KEY_VIBRATE_WHEN_CONNECTED  @"VibrateWhenDialConnected"
#define APP_SET_KEY_VIBRATE_WHEN_DISCONNECTED @"VibrateWhenDialDisconnected"
#define APP_SET_KEY_SHARE_TO_SINA           @"ShareToSina"
#define APP_SET_KEY_INTER_ROAMING           @"inter_roaming"
#define APP_SET_KEY_DIALER_MODE             @"DialerMode"

typedef enum tag_PhonePadLanguage {
    KeyboardLanguageStandard,
    KeyboardLanguageGreek,
    KeyboardLanguageHebrew,
    KeyboardLanguageFarsi,
    KeyboardLanguageRussian
}PhonePadLanguage;
typedef enum Language {
    LanguageStandard,
    ChineseSimplified,
    ChineseTraditional,
    English
}Language;

typedef enum{
    CellListFunctionTypeOnCall,
    CellListFunctionTypeSendSms,
    CellListFunctionTypeShowAllnumbers,
    CellListFunctionTypeClearLogs,
}CellListFunctionType;

typedef enum{
    DialerModeAlwaysAsk,
    DialerModeNormal,
    DialerModeVoip
}DialerModeType;

@interface AppSettingsModel : NSObject {
    NSMutableDictionary* __strong app_settiings_dict;
    PhonePadLanguage secondary_language;
    Language language;
    BOOL dial_tone;
    BOOL call_confirm;
    //BOOL slide_confirm;
    BOOL format_phone_numbers;
    BOOL display_location;
    BOOL synchronize_profiles;
    BOOL populate_photos;
    BOOL availability;
    BOOL reminder_tone;
    BOOL reminder_vibrate;
    BOOL smart_eye;
    BOOL vibrate_when_connected;
    BOOL vibrate_when_disconnected;
    NSString __strong *version;
    NSString __strong *date;
    NSString __strong *privacy_tatement;
    NSString __strong *change_log;
    NSString __strong *faq;
    
    CellListFunctionType listClick;
    CellListFunctionType listSwipeLeft;
    CellListFunctionType listSwipeRight;
    DialerModeType dialerMode;
}

@property(nonatomic, assign) PhonePadLanguage secondary_language;
@property(nonatomic, assign) Language language;
@property(nonatomic, assign) CellListFunctionType listClick;
@property(nonatomic, assign) CellListFunctionType listSwipeLeft;
@property(nonatomic, assign) CellListFunctionType listSwipeRight;
@property(nonatomic, assign) BOOL dial_tone;
@property(nonatomic, assign) BOOL call_confirm;
@property(nonatomic, assign) BOOL slide_confirm;
@property(nonatomic, assign) BOOL format_phone_numbers;
@property(nonatomic, assign) BOOL display_location;
@property(nonatomic, assign) BOOL synchronize_profiles;
@property(nonatomic, assign) BOOL populate_photos;
@property(nonatomic, assign) BOOL availability;
@property(nonatomic, assign) BOOL reminder_tone;
@property(nonatomic, assign) BOOL reminder_vibrate;
@property(nonatomic, assign) BOOL smart_eye;
@property(nonatomic, assign) BOOL vibrate_when_connected;
@property(nonatomic, assign) BOOL vibrate_when_disconnected;
@property(nonatomic, retain, readonly) NSString *version;
@property(nonatomic, retain, readonly) NSString *date;
@property(nonatomic, retain, readonly) NSString *privacy_tatement;
@property(nonatomic, retain, readonly) NSString *change_log;
@property(nonatomic, retain, readonly) NSString *faq;
@property(nonatomic, assign) BOOL isShareToSina;
@property(nonatomic, assign) DialerModeType dialerMode;

+ (AppSettingsModel*) appSettings;
+ (void)mergeApplicationSettings;
+ (NSString*)getAppSettingsDataFileNameNoPath;
+ (NSString*)getAppSettingsDataFileName;

- (void)saveToFile;
- (void)notificateChange:(NSString*)key;
- (id) settingValueForKey:(NSString*)key;
- (void)setSettingValue:(id)value forKey:(NSString *)key;
- (NSString *)actionName:(CellListFunctionType)action;
- (NSArray *)allActions;
- (NSArray *)allClickActions;
- (NSString *)DialerModeName:(DialerModeType)mode;

@end
