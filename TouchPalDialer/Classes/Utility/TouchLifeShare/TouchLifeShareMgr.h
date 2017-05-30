//
//  TouchLifeShareMgr.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/20.
//
//

#import <Foundation/Foundation.h>

#define INSTANT_BONUS_TYPE_KEY @"instant_bonus_type"
#define INSTANT_BONUS_QUANTITY_KEY @"instant_bonus_quantity"
#define SHARE_BONUS_CONTENT_KEY @"share_bonus_content"
#define SHARE_BONUS_QUANTITY_KEY @"share_bonus_quantity"
#define SHARE_BONUS_HINT_KEY @"share_bonus_hint"
#define NEXT_QUERY_TIME_KEY @"next_update_time"
#define SHARE_MESSAGE_KEY @"share_message"
#define SHARE_TITLE_KEY @"share_title"
#define SHARE_URL_KEY @"share_url"
#define SHARE_IMAGE_URL_KEY @"share_image_url"
#define SHARE_BUTTON_TITLE_KEY @"share_button_title"
#define UI_VERSION @"ui_version"
#define BOX_SHARE_TITLE_KEY @"box_share_title"
#define BOX_SHARE_LIST_KEY @"box_share_list"
#define PACKAGE_ID_KEY @"package_id"

#define SHARE_REQUEST_TARGET_NUMBER @"target_number"
#define SHARE_REQUEST_DURATION @"duration"

#define TOUCHLIFE_SHARE_VERSION @"1"

@interface TouchLifeShare : NSObject

- (NSDictionary *)generateShareRequestParamWithCallNumber:(NSString *)phone callDuration:(NSInteger)dur isVoipCall:(BOOL)isVoipCall;

- (void)checkShareWithRequestParam:(NSDictionary *)param;

//- (void)checkShareWithIsVoipCall:(BOOL)isVoipCall;

- (void)checkShare:(id)paras notifyAuto:(BOOL)notifyAuto;

- (void)notify;

- (void)finishShare;

@property(nonatomic, copy)void(^netOperResultBlock)(BOOL netsuccess);

@end


@interface TouchLifeShareMgr : NSObject

+ (id)instance;

- (TouchLifeShare *)newTouchLifeShare;

- (void)shareWithRef:(NSUInteger)ref;

@end