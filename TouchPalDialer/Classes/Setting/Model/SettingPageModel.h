//
//  SettingPageModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SettingItemModel.h"
#import "AppSettingsModel.h"

typedef enum {
    SETTING_PAGE_MAIN,
    SETTING_PAGE_CUSTOMIZE_ACTIONS,
    SETTING_PAGE_ABOUT,
    SETTING_PAGE_FEEDBACK,
    SETTING_PAGE_GESTURE,
    SETTING_PAGE_SMART_DIAL,
    SETTING_PAGE_ADDITIONAL_LANGUAGE,
    SETTING_PAGE_MUTI_LANGUAGE,
    SETTING_PAGE_CUSTOMIZE_CLICK,
    SETTING_PAGE_CUSTOMIZE_LEFT_SWIPE,
    SETTING_PAGE_CUSTOMIZE_RIGHT_SWIPE,
    SETTING_PAGE_VOIP_CALL,
    SETTING_PAGE_DIALER,
    SETTING_PAGE_DIALER_MODE
} SettingPageType;


@interface SettingPageModel : NSObject
@property (nonatomic, assign) SettingPageType pageType;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, retain) NSArray* sections;
@property (nonatomic, retain) NSMutableArray* monitorKeys;
@property (nonatomic, retain) AppSettingsModel* settings;
@property (nonatomic, assign) CGFloat cellHeight;

+(SettingPageModel*) pageWithTitle:(NSString*) title sections:(NSArray*)sections type:(SettingPageType)pageType settings:(AppSettingsModel*)settings;

-(void) save;

@end

@interface SettingSectionModel : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, retain) NSArray* items;
@property (nonatomic, retain) NSMutableArray* monitorKeys;

+(SettingSectionModel*) sectionWithItems:(NSArray*) items;
+(SettingSectionModel*) sectionWithTitle:(NSString*) title items:(NSArray*)items;


@end
