//
//  IndexData.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-13.
//
//

#ifndef TouchPalDialer_IndexData_h
#define TouchPalDialer_IndexData_h

#import "TouchPalDialerAppDelegate.h"

@interface IndexData : NSObject

#define SECTION_TYPE_SEARCH @"search"
#define SECTION_TYPE_BANNER @"banner"
#define SECTION_TYPE_BANNER_REPLACE @"banner_replace"
#define SECTION_TYPE_ANNOUNCEMENT @"announcement"
#define SECTION_TYPE_ACTIVITY @"activity"
#define SECTION_TYPE_TRACK @"track"
#define SECTION_TYPE_RECOMMEND @"recommend"
#define SECTION_TYPE_RECOMMEND_EXTRA @"extra_recommend"
#define SECTION_TYPE_CATEGORY @"category"
#define SECTION_TYPE_SEPARATOR @"separator"
#define SECTION_TYPE_CATEGORY_BLIST @"category_black_list"
#define SECTION_TYPE_FAVOURITE @"favourite"
#define SECTION_TYPE_COUPON @"coupon"
#define SECTION_TYPE_SUB_BANNER @"sub_banner"
#define SECTION_TYPE_FINDS @"finds"
#define SECTION_TYPE_FIND_NEWS @"news"
#define SECTION_TYPE_MINI_BANNERS @"mini_banner"
#define SECTION_TYPE_FULL_SCREEN_ADS @"full_screen_ad"
#define SECTION_TYPE_MY_PHONE @"my_phone"
#define SECTION_TYPE_NETWORK_ERROR @"network_error"
#define SECTION_TYPE_MY_PROPERTY @"my_property"
#define SECTION_TYPE_MY_TASK_BTN @"my_task_btn"
#define SECTION_TYPE_MY_TASK @"profit"
#define SECTION_TYPE_HOT_CHANNEL @"hot_channel"
#define SECTION_TYPE_ASSET @"asset"
#define SECTION_TYPE_NETWORK_ERR @"newwork_err"
#define SECTION_TYPE_FOOTER @"footer"

#define SECTION_TYPE_PROFIT_CENTER @"profit_center"
#define SECTION_TYPE_AD_CELL @"ad_cell"
#define SECTION_TYPE_LOCAL_SETTINGS @"local_settings"
#define SECTION_TYPE_V6_SECTIONS @"v6_sections"

#define SECTION_TYPE_SEARCH_INDEX 1000
#define SECTION_TYPE_BANNER_INDEX 1010
#define SECTION_TYPE_BANNER_REPLACE_INDEX 1020
#define SECTION_TYPE_NETWORK_ERROR_INDEX 1035
#define SECTION_TYPE_MY_PHONE_INDEX 1040
#define SECTION_TYPE_MY_PROPERTY_INDEX 1050
#define SECTION_TYPE_MINI_BANNERS_INDEX 1055
#define SECTION_TYPE_MY_TASK_INDEX 1060
#define SECTION_TYPE_MY_TASK_BTN_INDEX 1070
#define SECTION_TYPE_HOT_CHANNEL_INDEX 1080
#define SECTION_TYPE_SUB_BANNER_INDEX 1090
#define SECTION_TYPE_RECOMMEND_INDEX 1100
#define SECTION_TYPE_FULL_SCREEN_AD_INDEX 1061
#define SECTION_TYPE_FIND_NEWS_INDEX 1300


// TPD, from V6
#define SECTION_TYPE_TPD_MY_PROPERTY_INDEX (1010)
#define SECTION_TYPE_TPD_PROFIT_CENTER_INDEX (1020)
#define SECTION_TYPE_TPD_MINI_BANNERS_INDEX (1030)
//#define SECTION_TYPE_TPD_AD_CELL_INDEX (1040)
#define SECTION_TYPE_TPD_V6_SECTIONS_INDEX (1040)
#define SECTION_TYPE_TPD_BANNER_INDEX (1050)
#define SECTION_TYPE_TPD_LOCAL_SETTINGS_INDEX (1060)



//not used for now
#define SECTION_TYPE_FINDS_INDEX 1189
#define SECTION_TYPE_CATEGORY_INDEX 1100
#define SECTION_TYPE_FAVOURITE_INDEX 1200
#define SECTION_TYPE_COUPON_INDEX 1300
#define SECTION_TYPE_FOOTER_INDEX 9999
#define SECTION_TYPE_ANNOUNCEMENT_INDEX 9999


@property(nonatomic, retain)NSMutableArray* groupArray;

- (id) initWithJson:(NSDictionary *)json;
- (id) initWithJsonForService:(NSDictionary *)json;
- (id) initFindNewsWithJson:(NSDictionary *)json;
- (id) initNetWorkError;
- (id) initMyPhone;
- (id) initMyProperty;
- (id) initMyTask;
- (id) initHotChannel;
- (id) initMyTaskBtn;
- (id) initBannerReplace;
- (id) initLocalSettings;

- (void) mergeWithOther:(IndexData* )other;
- (void) sortWithIndex;
@end
#endif
