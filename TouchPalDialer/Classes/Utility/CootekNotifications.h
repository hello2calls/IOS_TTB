//
//  CootekNotifications.h
//  TouchPalDialer
//
//  Created by Sendor on 11-10-31.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>

/*APP*/
#define N_INITIAL_DATA_COMPLETED            @"N_INITIAL_DATA_COMPLETED"
#define N_APP_DID_ENTER_BACKGROUND          @"N_APP_DID_ENTER_BACKGROUND"
#define N_INITIAL_LOADVIEW_COMPLETED        @"N_INITIAL_LOADVIEW_COMPLETED"
#define N_JUMP_TO_REGISTER_INDEX_PAGE	    @"N_JUMP_TO_REGISTER_INDEX_PAGE"
#define N_LOCK_TAG_SECOND_TO_FORTH			@"N_LOCK_TAG_SECOND_TO_FORTH"
#define N_APPLICATION_BECOME_ACTIVE         @"N_APPLICATION_BECOME_ACTIVE"
#define N_INITIAL_CONTACT_WAIT              @"N_INITIAL_CONTACT_WAIT"

// system address book
#define N_SYSTEM_CONTACT_DATA_WILL_CHANGE       @"N_SYSTEM_CONTACT_DATA_WILL_CHANGE"
#define N_SYSTEM_CONTACT_DATA_CHANGED           @"N_SYSTEM_CONTACT_DATA_CHANGED"
#define N_PERSON_DATA_CHANGED                   @"N_PERSON_DATA_CHANGED"

/*KEY BOARD*/
#define N_PHONE_PAD_SHOW				@"N_PHONE_PAD_SHOW"
#define N_PHONE_PAD_HIDE				@"N_PHONE_PAD_HIDE"
#define N_HIDE_PHONE_PAD                @"N_HIDE_PHONE_PAD"
#define N_RESTORE_PHONE_PAD             @"N_RESTORE_PHONE_PAD"
#define N_DIALER_INPUT_EMPTY			@"N_DIALER_INPUT_EMPTY"
#define N_DIALER_INPUT_NOT_EMPTY	    @"N_DIALER_INPUT_NOT_EMPTY"
#define N_CLICK_TOKEN_BUSY			    @"N_CLICK_TOKEN_BUSY"
#define N_CLICK_TOKEN_IDLE			    @"N_CLICK_TOKEN_IDLE"
#define N_PHONE_PAD_LANGUAGE_CHANGED	@"N_PHONE_PAD_LANGUAGE_CHANGED"

/* dialer view*/
#define N_CALL_LOG_LIST_CHANGED		     @"N_CALL_LOG_LIST_CHANGED"
#define N_EDIT_NOTIFICATION			     @"N_EDIT_NOTIFICATION"
#define N_DONE_NOTIFICATION			     @"N_DONE_NOTIFICATION"
#define N_CANCEL_CALL_CLICK              @"N_CANCEL_CALL_CLICK"
#define N_DAILER_WILL_APPEAR             @"N_DAILER_WILL_APPEAR"
#define N_KEYBOARD_USED                  @"N_KEYBOARD_USED"
#define N_KEYBOARD_NOT_USED              @"N_KEYBOARD_NOT_USED"

// Settings changed
#define N_SETTINGS_ITEM_CHANGED         @"N_SETTINGS_ITEM_CHANGED"
#define N_CARRIER_CHANGED               @"N_CARRIER_CHANGED"

/*favorite*/
#define N_FAVORITE_DATA_CHANGED			    @"N_FAVORITE_DATA_CHANGED"
#define N_FAVORITE_DATA_DELETE_ID		    @"N_FAVORITE_DATA_DELETE_ID"
#define N_FAVORITE_DATA_DELETE_MODEL		@"N_FAVORITE_DATA_DELETE_MODEL"
#define N_FAVORITE_DELETE_PAGE_CHANGE		@"N_FAVORITE_DELETE_PAGE_CHANGE"
#define N_FAVORITE_PAGE_CHANGED			    @"N_FAVORITE_PAGE_CHANGED"
#define N_FAV_TO_PERSON_DETAIL			    @"N_FAV_TO_PERSON_DETAIL"
#define KEY_FAVORITE_DATA_ONE               @"KEY_FAVORITE_DATA_ONE"
#define KEY_FAVORITE_DElETE_PERSON_ID       @"KEY_FAVORITE_DElETE_PERSON_ID"


/*SNS*/
#define N_SNS_SYNC_ENABLE_CHANGED               @"N_SNS_SYNC_ENABLE_CHANGED"
#define N_PREPARE_TO_SEND_SMS                   @"N_PREPARE_TO_SEND_SMS"

// Contact all
#define N_REFRESH_CONTACT_DATA_BEGIN         @"N_REFRESH_CONTACT_DATA_BEGIN"
#define N_REFRESH_CONTACT_DATA_END           @"N_REFRESH_CONTACT_DATA_END"
#define N_EXPANDABLE_ROOT_NODE_DATA_CHANGED  @"N_EXPANDABLE_ROOT_NODE_DATA_CHANGED"
#define N_ONCLICK_FILTER_BEGINS              @"N_ONCLICK_FILTER_BEGINS"
#define N_RESTORE_FILTER_ENDS                @"N_RESTORE_FILTER_ENDS"
#define N_CONTACT_BACK_TO_ALL                @"N_CONTACT_BACK_TO_ALL"
#define N_FILTER_CONTACT_NUMBER_CHANGED      @"N_FILTER_CONTACT_NUMBER_CHANGED"
#define N_DONE_CACHE_ALL_THE_CONTACT_DATA    @"N_DONE_CACHE_ALL_THE_CONTACT_DATA"
#define N_CONTACT_SEARCH_RESULT_CHANGED      @"N_CONTACT_SEARCH_RESULT_CHANGED"
#define N_ROOT_BAR_DISABLE_FOR_A_WHILE       @"N_ROOT_BAR_DISABLE_FOR_A_WHILE"
#define N_CONTACT_DETAIL_INIT                @"N_CONTACT_DETAIL_INIT"

#define N_REFRESH_IS_VOIP_ON                 @"N_REFRESH_IS_VOIP_ON"
#define N_VOIP_LOGINOUT_NOTIFICATION         @"N_VOIP_LOGINOUT_NOTIFICATION"
#define N_REFRESH_IS_VOIP_ON_LIST_VIEW       @"N_REFRESH_IS_VOIP_ON_LIST_VIEW"

#define N_REFRESH_ALL_VIEW_CONTROLLER        @"N_REFRESH_ALL_VIEW_CONTROLLER"
// contact KEY
#define KEY_PERSON_CHANGED                   @"KEY_PERSON_CHANGED"
#define KEY_PERSON_DELETED_DETAIL            @"KEY_PERSON_DELETED_DETAIL"
#define KEY_RESULT_LIST_CHANGED              @"KEY_RESULT_LIST_CHANGED"

// Contact group Notifications
#define N_GROUP_SYNCHRONIZING                       @"N_GROUP_SYNCHRONIZING"
#define N_GROUP_SYNCHRONIZED                        @"N_GROUP_SYNCHRONIZED"
#define N_GROUP_MODEL_RELOADED                      @"N_GROUP_MODEL_RELOADED"
#define N_GROUP_MODEL_CHANGED                       @"N_GROUP_MODEL_CHANGED"
#define N_GROUP_MODEL_ADDED                         @"N_GROUP_MODEL_ADDED"
#define N_GROUP_NODE_DELETED                        @"N_GROUP_NODE_DELETED"
#define N_GROUP_MODEL_INDEX_CHANGED                 @"N_GROUP_MODEL_INDEX_CHANGED"
#define N_GROUP_MODEL_REORDERED                     @"N_GROUP_MODEL_REORDERED"
#define N_GROUP_MEMBER_MODEL_RELOADED               @"N_GROUP_MEMBER_MODEL_RELOADED"
#define N_GROUP_MEMBER_MODEL_MEMBERS_CHANGED        @"N_GROUP_MEMBER_MODEL_MEMBERS_CHANGED"
#define N_GROUP_MEMBER_MODEL_MEMBERS_CHECK_CHANGED  @"N_GROUP_MEMBER_MODEL_MEMBERS_CHECK_CHANGED"
#define N_GROUP_MEMBER_MODEL_MEMBERS_CHECKED_ALL    @"N_GROUP_MEMBER_MODEL_MEMBERS_CHECK_CHANGED"
#define N_GROUP_MEMBER_MODEL_MEMBERS_CHECKED_NONE   @"N_GROUP_MEMBER_MODEL_MEMBERS_CHECK_CHANGED"
#define N_PERSON_GROUP_CHANGE                       @"N_PERSON_GROUP_CHANGE"
#define N_SMART_GROUP_NEED_RELOAD                   @"N_SMART_GROUP_NEED_RELOAD"
#define N_INVITING_IN_CONATCT_DETAIL_SUCCEED        @"N_INVITING_IN_CONATCT_DETAIL_SUCCEED"

//group KEY
#define KEY_GROUP_MODEL_CHANGED         @"KEY_GROUP_MODEL_CHANGED"
#define KEY_GROUP_MODEL_INDEX           @"KEY_GROUP_MODEL_INDEX"
#define KEY_GROUP_PERSON_ID             @"KEY_GROUP_ID"
#define KEY_GROUP_NODE_DELETED          @"KEY_GROUP_NODE_DELETED"

/*DETAIL*/
#define N_CURRENT_PERSON_DATA_CHANGED   @"N_CURRENT_PERSON_DATA_CHANGED"


//Gesture
#define N_GESTURE_ITEM_SELECTED         @"N_GESTURE_ITEM_SELECTED"
#define N_GESTURE_PERSON_SELECTED       @"N_GESTURE_PERSON_SELECTED"
#define N_GESTURE_UN_RECOGNIZER         @"N_GESTURE_UN_RECOGNIZER"
#define N_GESTURE_PERSON_RECOGNIZER     @"N_GESTURE_PERSON_RECOGNIZER"
#define N_GESTURE_HIDE_UNREGN_BAR       @"N_GESTURE_HIDE_UNREGN_BAR"
#define N_UN_RECOGNIZER_EXIT_BAR        @"N_UN_RECOGNIZER_EXIT_BAR"
#define N_GESTURE_SETTING_CHNAGE        @"N_GESTURE_SETTING_CHNAGE"
#define N_GESTURE_NOGESTURE             @"N_GESTURE_NOGESTURE"
#define N_GESTURE_SETTING_CLOSE         @"N_GESTURE_SETTING_CLOSE"
#define N_GESTURE_SETTING_OPEN          @"N_GESTURE_SETTING_OPEN"

//callertell

#define N_YELLOW_LOG_CHNAGED                  @"N_YELLOW_LOG_CHNAGED"
#define	N_CALL_LOG_CHANGED                    @"N_CALL_LOG_CHANGED"
#define N_UPDATE_CITYS_DATA_FINISH            @"N_UPDATE_CITYS_DATA_FINISH"
#define N_AUTOCHECK_CITYS_UPDATE              @"N_AUTOCHECK_CITYS_UPDATE"
#define N_AUTOCHECK_MARKET_EVENT_UPDATE       @"N_AUTOCHECK_MARKET_EVENT_UPDATE"
#define N_APP_EXIT_YELLOW_PAGE                @"N_APP_EXIT_YELLOW_PAGE"
#define N_DOWNLOAD_DATA_SUCCESS               @"N_DOWNLOAD_DATA_SUCCESS"
#define N_DOWNLOAD_DATA_FAIL                  @"N_DOWNLOAD_DATA_FAIL"
#define N_DOWNLOAD_DATA_PROGRESS              @"N_DOWNLOAD_DATA_PROGRESS"
#define N_DID_CALLERIDS_CHANGED               @"N_DID_CALLERIDS_CHANGED"
#define N_CALLERTELL_UGC_TAG_SUCCESS          @"N_CALLERTELL_UGC_TAG_SUCCESS"
#define N_HAS_LOAD_CITY_DATA                  @"N_HAS_LOAD_CITY_DATA"
#define N_HINT_BUTTON_CLICK                   @"N_HINT_BUTTON_CLICK"

//rootTabBar
#define N_SHOW_ROOT_TAB_BAR                   @"N_SHOW_ROOT_TAB_BAR"
#define N_HIDE_ROOT_TAB_BAR                   @"N_HIDE_ROOT_TAB_BAR"

//scrollview
#define N_STARTING_SCROLLING                  @"N_STARING_SCROLLING"

//Noah
#define N_NOAH_LOAD_CONFIG_SUCCESS            @"N_NOAH_LOAD_CONFIG_SUCCESS"
#define N_RAINBOW_ACTIVATE_SUCCESS            @"N_RAINBOW_ACTIVATE_SUCCESS"
#define N_NOAH_LOAD_LOCAL                     @"N_NOAH_LOAD_LOCAL"
//SelectView
#define N_SHOW_INDICATOR                      @"N_SHOW_INDICATOR"
#define N_DISMISS_INDICATOR                   @"N_DISMISS_INDICATOR"

//Index
#define N_ZIP_DEPLOY_SUCCESS                  @"N_ZIP_DEPLOY_SUCCESS"
#define N_TOAST_DOWNLOAD_PROGRESS             @"N_TOAST_DOWNLOAD_PROGRESS"
#define N_INDEX_REQUEST_SUCCESS               @"N_INDEX_REQUEST_SUCCESS"
#define N_INDEX_REQUEST_FAILED                @"N_INDEX_REQUEST_FAILED"
#define N_INDEX_REQUEST_SERVER_FAILED         @"N_INDEX_REQUEST_SERVER_FAILED"
#define N_SELECTED_YELLOWPAGE                 @"N_SELECTED_YELLOWPAGE"
#define N_UNSELECTED_YELLOWPAGE               @"N_UNSELECTED_YELLOWPAGE"
#define N_COUPON_REQUEST_SUCCESS              @"N_COUPON_REQUEST_SUCCESS"
#define N_COUPON_REQUEST_FAILED               @"N_COUPON_REQUEST_FAILED"
#define N_COUPON_REQUEST_IGNORE               @"N_COUPON_REQUEST_IGNORE"
#define N_INDEX_JSON_REQUEST_SUCCESS          @"N_INDEX_JSON_REQUEST_SUCCESS"
#define N_INDEX_JSON_REQUEST_FAILED           @"N_INDEX_JSON_REQUEST_FAILED"
#define N_SELECTED_SERVICE                    @"N_SELECTED_SERVICE"
#define N_WEATHER_REQUEST_SUCCESS             @"N_WEATHER_REQUEST_SUCCESS"
#define N_WEATHER_REQUEST_FAILED              @"N_WEATHER_REQUEST_FAILED"
#define N_INDEX_FONT_REQUEST_SUCCESS          @"N_INDEX_FONT_REQUEST_SUCCESS"
#define N_INDEX_FONT_REQUEST_FAILED          @"N_INDEX_FONT_REQUEST_FAILED"
#define N_SERVICE_BOTTOM_REQUEST_SUCCESS              @"N_SERVICE_BOTTOM_REQUEST_SUCCESS"
#define N_MINI_BANNER_REQUEST_SUCCESS              @"N_MINI_BANNER_REQUEST_SUCCESS"
#define N_MINI_BANNER_REQUEST_FAILED               @"N_MINI_BANNER_REQUEST_FAILED"

//fuwuhao
#define N_PUBLIC_NUMBER_UPDATE				@"N_PUBLIC_NUMBER_UPDATE"

//Feeds
#define N_FEEDS_REFRESH             @"N_FEEDS_REFRESH"
#define N_FEEDS_REFRESH_FROMOTHER @"N_FEEDS_REFRESH_FROMOTHER"

//Touchapaler
#define N_REFRESH_TOUCHPAL_NODE_ALERT         @"N_REFRESH_TOUCHPAL_NODE_ALERT"

//personalcenter
#define N_REFRESH_PERSONAL_INFO                 @"N_REFRESH_PERSONAL_INFO"


//engine
#define N_ENGINE_INIT @"N_ENGINE_INIT"

#define PERSONAL_IMAGE_REFRESH @"PERSONAL_IMAGE_REFRESH"

#define DIALOG_DISMISS @"DIALOG_DISMISS"

//scroll view button
#define N_SCROLL_ENABLE @"N_SCROLL_ENABLE"
#define KEY_SCROLL @"KEY_SCROLL"

//antiharass
#define N_ANTIHARASS_SWTICH_CHANGE @"N_ANTIHARASS_SWTICH_CHANGE"
#define N_ANTIHARASS_VIEW_REFRESH @"N_ANTIHARASS_VIEW_REFRESH"

//activate
#define N_ACTIVATE_SUCCESS @"N_ACTIVATE_SUCCESS"

#define N_APP_ACTIVE_SHWO_PASTEBOARD   @"N_APP_ACTIVE_SHWO_PASTEBOARD"

#define scrollToDismissFar   @"scrollToDismissFar"
#define SHOULD_REFRESH_PC_HEADVIEW   @"SHOULD_REFRESH_PC_HEADVIEW"
#define  SHOULD_REFRESH_VIPINFO @"SHOULD_REFRESH_VIPINFO"

//voip privilege ad
#define N_VOIP_PRIVILEGE_AD_DATA_READY @"N_VOIP_PRIVILEGE_AD_DATA_READY"
#define N_VOIP_PRIVILEGE_AD_TO_SHOW @"n_voip_privilege_ad_to_show"
#define REFRESH_INFOCONTROLLER_WITHPRIVILEGE @"REFRESH_INFOCONTROLLER_WITHPRIVILEGE"
#define N_VOIP_ACCOUNT_INFO_CHANGED @"n_voip_account_info_changed"

//launch ad
#define N_LAUNCH_AD_MATERIAL_PIC_DOWNLOADED @"n_launch_ad_material_pic_downloaded"

// contact transfer
#define N_REFRESH_SPECIAL_CONTACT_NODE @"n_refresh_special_contact_node"
#define N_CONTACT_TRANSFER_CONTACTS_RELOADED @"n_contact_transfer_contacts_reloaded"
#define N_CONTACT_TRANSFER_CONTACTS_RELOADING @"n_contact_transfer_contacts_reloading"

//hanguptime
#define N_REMOVE_HANGUP_TIMER @"remove_hangup_Timer"

#define N_AD_READY_FOR_SHOW @"adReadyForShow"
#define N_WEB_NO_AD @"adWebNoAd"
#define N_LAUNCH_AD_FINISH @"launchAdFinish"

#define N_CALLEXTENSION_STATUS_REFRESH @"N_CALLEXTENSION_STATUS_REFRESH"
#define N_DOWNLOAD_DB_FILE_FAIL @"N_DOWNLOAD_DB_FILE_FAIL"

// v6 property row viw
#define N_UPDATE_WELCOME_ANIMATION @"n_update_welcome_animation"
#define N_TOP_TAB_CHANGE_NOTI @"n_top_tab_change_noti"


typedef enum {
    ContactChangeTypeAdd,
    ContactChangeTypeDelete,
    ContactChangeTypeModify,
}ContactChangeType;

typedef enum {
    ContactChangeTypeAddToGroup,
    ContactChangeTypeDeleteFromGroup,
}ContactGroupChangeType;

@interface NotiPersonChangeData : NSObject {
    NSInteger person_id;
    ContactChangeType change_type;
    NSString* display_name;
}
@property(nonatomic, readonly) NSInteger person_id;
@property(nonatomic, readonly) ContactChangeType change_type;
@property(nonatomic, retain) NSString* display_name;

- (id)initWithPersonId:(NSInteger)personId
            changeType:(ContactChangeType)changeType;

- (id)initWithPersonId:(NSInteger)personId
            changeType:(ContactChangeType)changeType
           displayName:(NSString*)displayName;
@end



@interface NotiGroupChangeData : NSObject {
    NSInteger group_index;
    ContactChangeType change_type;
}
@property(nonatomic, readonly) NSInteger group_index;
@property(nonatomic, readonly) ContactChangeType change_type;

- (id)initWithGroupIndex:(NSInteger)groupIndex
              changeType:(ContactChangeType)changeType;
@end


@interface NotiPersonGroupChangeData : NSObject {
    NSInteger groupID;
    NSInteger personID;
    ContactGroupChangeType change_type;
}
@property(nonatomic, readonly) NSInteger groupID;
@property(nonatomic, readonly) NSInteger personID;
@property(nonatomic, readonly) ContactGroupChangeType change_type;

- (id)initWithGroupContact:(NSInteger)m_groupID
              withPersonID:(NSInteger)m_personID
                changeType:(ContactGroupChangeType)m_changeType;
@end


