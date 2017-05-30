//
//  UsageConst.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/2/6.
//
//

#ifndef TouchPalDialer_UsageConst_h
#define TouchPalDialer_UsageConst_h

//Noah
#define EXTENTION_PERSONAL_CENTER @"extention_personal_center"
#define EXTENTION_MARKET @"extension_market"
#define EXTENTION_MESSAGE_BOX @"extension_message_box"
#define GUIDEPOINT_VOIP @"voipc2c_menu"
#define GUIDEPOINT_FLOW @"flow"
#define GUIDEPOINT_YELLOWPAGE @"yellowpage"
#define GUIDEPOINT_COUPON @"coupon"
#define GUIDEPOINT_GESTURE @"gesture"
#define GUIDEPOINT_SETTING @"setting"
#define GUIDEPOINT_HELP @"help"
#define GUIDEPOINT_TOUCHPAL_FAN @"fans"

#define GUIDEPOINT_DIALER_MENU @"personal_center"//主开关
#define GUIDEPOINT_WALLET @"wallet"//我的钱包
#define GUIDEPOINT_BACKFEE @"backfee"//零钱
#define GUIDEPOINT_FREE_MINUTE @"free_minute"//免费时长
#define GUIDEPOINT_TRAFFIC @"traffic"//免费流量
#define GUIDEPOINT_CARD @"card"//卡券
#define GUIDEPOINT_MARKET @"market"//活动大厅
#define GUIDEPOINT_REDBAG @"redbag"//邀请好友
#define GUIDEPOINT_SKIN @"skin"//皮肤
#define GUIDEPOINT_IPCALL @"ipcall"//
#define GUIDEPOINT_ANTIHARASS @"antiharass"//骚扰识别
#define GUIDEPOINT_DIALER_SETTING @"dialer_setting" //拨号设置

#define GUIDEPOINT_EXCHANGE @"exchange"//

//personal center
#define PATH_PERSONAL_CENTER @"path_personal_center"
#define CENTER_ENTRANCE @"center_entrance"
#define CENTER_OPERATION_CLICK @"operation_click"
#define CENTER_AUTHCODE_TIMES_CLICK_LOGIN_BACK @"center_authcode_times_click_login_back"
#define CENTER_AUTHCODE_CONTENT_INPUT_LOGIN_BACK @"center_authcode_content_intput_login_back"
#define CENTER_CLICK_GET_AUTHCODE_TYPE @"center_click_get_authcode_type"
#define CENTER_SMS_AUTHCODE_RESULT @"center_sms_authcode_result"
#define CENTER_VOICE_AUTHCODE_RESULT @"center_voice_authcode_result"
#define CENTER_CLICK_VOICE_AUTHCODE @"center_click_voice_authcode"
#define CENTER_CLICK_LOGIN_CONFIRM @"center_click_login_confirm"
#define CENTER_LOGIN_CONFIRM_RESULT @"center_click_confirm_result"
#define CENTER_LOGIN_ORIGIN @"center_login_origin"
#define CENTER_CLICK_LOGOUT_CONFIRM @"center_click_logout_confirm" 

#define USER_INTERNATIONAL_ROAMING @"USER_INTERNATIONAL_ROAMING"

#define KEY_GUIDE_SCREEN @"guide_screen"

//remote notification
#define PATH_REMOTE_NOTIFICATION @"path_remote_notification"
#define CLICK_REMOTE_NOTIFICATION @"click_remote_notification_id"
#define START_APP_WITH_BADGE @"start_app_with_badge"

//Hangup
#define PATH_DISCONNECT_COMMERCIAL @"path_disconnect_commercial"
#define IS_NORMAL_SHOW @"is_normal_show"
#define COMMERCIAL_SHOW @"commercial_show"
#define COMMERCIAL_SHOW_FAIL @"commercial_show_fail"
#define COMMERCIAL_CLICK @"commercial_click"
#define COMMERCIAL_DURATION @"commercial_duration"
#define COMMERCIAL_REQUEST @"commercial_request"
#define COMMERCIAL_ERROR_HAPPENS @"commercial_error_happens"

#define PATH_DIRECT_COMMERCIAL @"path_direct_commercial"

//token api
#define PATH_LOGOUT @"path_logout"
#define POPUP_API @"popup_api"
#define POPUP_TOKEN @"popup_token"
#define POPUP_RESULT @"popup_result"
#define POPUP_RESPONSE @"popup_response"

//login error
#define PATH_SECRET
#define SHOW_STARTUP_GUIDE @"show_startup_guide"
#define SHOW_LOGIN_DIALOG @"show_login_dialog"

//call commercial
#define PATH_AD_UDP @"path_adudp"

//login
// ----- 有组织性的login数据点统计 path ------
#define PATH_LOGIN                          @"path_login"

#define LOGIN_INPUT                         @"login_input"
#define VOIP_OPEN                           @"voip_open"

// ------ start 有组织性的login数据点统计 ------
#define LOGIN_CONFIRM_PRIVACY               @"confirm_privacy"
#define LOGIN_VISIT_PRIVACY                 @"visit_privacy"

#define LOGIN_FROM                          @"login_from"
#define LOGIN_BACK                          @"login_back"

#define LOGIN_ACTIVATE_TYPE                 @"activate_type"

#define LOGIN_FROM_FIRST_CHANCE                 @"first_chance"
#define LOGIN_FROM_SECOND_CHANCE                @"second_chance"
#define LOGIN_FROM_PERSONAL_CENTER_BIND_PHONE   @"personal_center_bind_phone"
#define LOGIN_FROM_PERSONAL_CENTER_FREE_CALL    @"personal_center_free_call"
#define LOGIN_FROM_FIRST_DIAL_RECOMMEND         @"first_dial_recommend"
#define LOGIN_FROM_LEARN_FREE_CALL              @"learn_free_call"
#define LOGIN_FROM_FEEDS_RED_PACKET             @"feeds_red_packet"
#define LOGIN_FROM_TAB_WALLET                   @"tab_wallet"

// 用户输入的手机号码或者验证码
#define LOGIN_USER_INPUT_PHONE_NUMBER           @"user_input_phone_number"
#define LOGIN_USER_INPUT_VERIFY_CODE            @"user_input_verify_code"

// 点击 获取验证码
#define LOGIN_CLICK_TO_GET_VERIFY_CODE          @"click_to_get_verify_code"
#define LOGIN_RESULT_OF_GET_VERIFY_CODE         @"result_of_get_verify_code"

// 点击 提交
#define LOGIN_CLICK_TO_VERIFY_CODE              @"click_to_verify_code"
#define LOGIN_RESULT_OF_VERIFY_CODE             @"result_of_verify_code"

#define LOGIN_LAUNCH_APP                        @"launch_app"
#define LOGIN_GREETING_PAGE                     @"greeting_page"
#define LOGIN_CLICK_FIRST_CHANCE_FREE_CALL      @"click_first_chance_free_call"
#define LOGIN_CLICK_SECOND_CHANCE_FREE_CALL     @"click_second_chance_free_call"
#define LOGIN_CLICK_SECOND_CHANCE_NORMAL_CALL   @"click_second_chance_normal_call"

// ------ end 有组织性的login数据点统计 ------

//push
#define PATH_APPLE_TOKEN @"path_apple_token"
#define GET_APPLE_TOKEN_ERROR @"get_apple_token_error"

//dialer_guide_animation
#define PATH_DIALER_GUIDE_ANIMATION @"path_dialer_guide_animation"
#define DIALER_GUIDE_ANIMATION_ESCAPE_TIMES @"dialer_guide_animation_escape_times"
#define DIALER_GUIDE_ANIMATION_USED_SEARCH @"dialer_guide_animation_used_search"
#define DIALER_GUIDE_ANIMATION_SHOWN_USED_SEARCH @"dialer_guide_animaton_shown_used_search"
#define DIALER_GUIDE_ANIMATION_SHOW_TIMES @"dialer_guide_animation_show_times"

#define DIALER_GUIDE_ANIMATION_ESCAPE_ANIMATION_FINISH @"dialer_guide_animation_escape_animation_finish"
#define DIALER_GUIDE_ANIMATION_ESCAPE_ANIMATION_NOT_FINISH @"dialer_guide_animation_escape_animation_finish_not_finish"
#define DIALER_GUIDE_ANIMATION_USE_SEARCH_TIMES @"dialer_guide_animation_use_search_times"


//path_dialer_guide inapp
#define KEY_DIALER_GUIDE_INAPP @"dialer_guide_inapp"

#define PATH_DIALER_RESULT_SEARCH @"path_dialer_result_search"
#define KEY_START_SEARCH @"start_search"


//antiharass
#define PATH_ANTIHARASS @"path_antiharass"
#define PATH_TODAY_WIDGET @"path_today_widget"
#define ANTIHARASS_SHOW_TODAY_WDIGET_ANIMATION @"antiharass_show_today_widget_animation"
#define ANTIHARASS_TODAY_WIDGET_USED @"antiharass_today_widget_used"
#define ANTIHARASS_TODAY_WIDGET_USED_TIMES @"antiharass_today_widget_used_times"
#define ANTIHARASS_TODAY_WIDGET_UPDATEVIEW_SHOW_TIMES @"antiharass_today_widget_updateview_show_times"
#define ANTIHARASS_TODAY_WIDGET_ANIMATION_SHOWN_FINISH @"antiharass_today_widget_animation_shown_finish"

#define ANTIHARASS_WANT_TO_CLOSE_UPDATE_IN_WIFI @"antiharass_want_to_close_updat_in_wifi"





#define ANTIHARASS_FIRST_START_CANCEL @"antiharass_first_start_cancel"
#define ANTIHARASS_FIRST_START_OK @"antiharass_first_start_ok"
#define ANTIHARASS_GUIDE_VIEW_CANCEL @"antiharass_guide_view_cancel"
#define ANTIHARASS_GUIDE_VIEW_OK @"antiharass_guide_view_ok"
#define ANTIHARASS_GUIDE_PAGE_SHOW_TIME @"antiharass_guide_page_show_time"
#define ANTIHARASS_CHOOSE_CITY_PAGE_SHOW_TIME @"antiharass_choose_city_page_show_time"
#define ANTIHARASS_CHOOSE_CITY_PAGE_PRESS_BACK @"antiharass_choose_city_page_press_back"
#define ANTIHARASS_CHOOSE_CITY_PAGE_FIRST_USED_SHOW_TIME @"antiharass_choose_city_page_first_used_show_time"
#define ANTIHARASS_CHOOSE_CITY_PAGE_FIRST_USED_PRESS_BACK @"antiharass_choose_city_page_first_used_press_back"
#define ANTIHARASS_CHOOSE_CITY_PAGE_CHOOSE_CITY @"antiharass_choose_city_page_choose_city"
#define ANTIHARASS_CHOOSE_CITY_PAGE_FIRST_USED_CHOOSE_CITY @"antiharass_choose_city_page_first_used_choose_city"
#define ANTIHARASS_PRESS_UPDATE_BUTTON @"antiharass_press_update_button"
#define ANTIHARASS_START_AND_UPDATE_SUCCESS @"antiharass_start_and_update_success"
#define ANTIHARASS_REMOVE_ADDRESSBOOK_SUCCESS @"antiharass_remove_addressbook_success"
#define ANTIHARASS_UPDATE_IS_NEWEST @"antiharass_update_is_newest"
#define ANTIHARASS_ON_SWITCH_PRESSED @"antiharass_on_switch_pressed"
#define ANTIHARASS_REMOVE_CONFIRM_PRESS_CANCEL @"antiharass_remove_confirm_press_cancel"
#define ANTIHARASS_REMOVE_CONFIRM_PRESS_OK @"antiharass_remove_confirm_press_ok"
#define ANTIHARASS_NO_NETWORK_PRESS_CANCEL @"antiharass_no_network_press_cancel"
#define ANTIHARASS_NO_NETWORK_PRESS_OK @"antiharass_no_network_press_ok"
#define ANTIHARASS_GPRS_VIEW_PRESS_CANCEL @"antiharass_gprs_view_press_cancel"
#define ANTIHARASS_GPRS_VIEW_PRESS_OK @"antiharass_gprs_view_press_ok"
#define ANTIHARASS_NETWORK_ERROR_PRESS_CANCEL @"antiharass_network_error_press_cancel"
#define ANTIHARASS_NETWORK_ERROR_PRESS_RETRY @"antiharass_network_error_press_retry"
#define ANTIHARASS_FAILED_VIEW_PRESS_TIME @"antiharass_failed_view_press_time"

#define ANTIHARASS_OPENED_FROM @"antiharass_opened_from"
#define ANTIHARASS_CLICK_DOT_TYPE @"antiharass_click_dot_type"
#define ANTIHARASS_CLICK_FAQ @"antiharass_click_faq"
#define ANTIHARASS_CHOOSED_CITY @"antiharass_choosed_city"
#define ANTIHARASS_NETWORK_ERROR_TYPE @"antiharass_network_error_type"
#define ANTIHARASS_NETWORK_ERROR_CODE @"antiharass_network_error_code"

//skin
#define PATH_SKIN @"path_skin"
#define SKIN_ENTRANCE @"skin_entrance"
#define SKIN_DOWNLOAD @"skin_download"
#define SKIN_CLICK @"skin_click"
#define SKIN_USAGE @"skin_usage"
#define SKIN_CHECK @"skin_check"

//dial
#define PATH_DIAL @"path_dial"
#define DIAL_TYPE_KEY @"dial_type_key"
#define DIAL_NOMAL_CALL @"dial_normal_call"
#define DIAL_VOIP_CALL @"dial_voip_call"
#define DIAL_VOIP_INCOMING @"dial_voip_incoming"

//guide
#define PATH_GUIDE @"path_guide"
#define SHOULD_SHOW_ANTIHARASS_GUIDE @"should_show_antiharass_guide"
#define ANTIHARASS_GUIDE_SKIPPED @"antiharass_guide_skipped"
#define ANTIHARASS_GUIDE_CLICKED @"antiharass_guide_clicked"
#define VIEW_APPEARED @"view_appeared"

//activate
#define PATH_ACTIVATE @"path_activate"
#define ACTIVATE_TYPE @"activate_type"
#define ACTIVATE_UMENG @"activate_umeng"


#define  DIALER_GUIDE @"dialer_guide"

//network info

#define PATH_NETWORK_INFO @"path_network_info"
#define INFO_REQUEST @"info_request"
#define INFO_RESPONSE @"info_response"

//启动识别粘贴板
#define PATH_PASTEBOARD_OPERATE @"path_pasteboard_operate"
#define PASTEBOARD_AFTER_DO_YES_OPERATE @"pasteboard_after_do_yes_operate"
//骚扰号码库更新提示
#define PATH_ANTIHARASS_UPDATEVIEW @"path_antiharass_updatview"
#define UPDATEVIEW_IN_APP @"updatview_in_app"
#define UPDATEVIEW_IN_TODAY @"updatview_in_today"

//wifi自动更新按钮
#define ANTIHARASS_AUTOUPDATE_WIFI @"antiharass_antoupdate_wifi"

//陌生号码联系人详情
#define PATH_UNKONW_PERSON @"path_unknow_person"
#define PERSON_DETAIL @"person_detail"

//数据库更新的时候 观看秘籍
#define PATH_TODAYWIDGETANIMATION @"path_todaywidgetanimation"
#define CLOSE_AND_RE_READ @"close_and_re_read"
#define SHOW_AND_TOAST_SHOW @"show_and_toast_show"




//voip call
#define PATH_APPLICATION_TERMINATE  @"path_application_terminate"
#define PATH_VOIP_CALL_DIRECT_DIAL  @"path_voip_call_direct"
#define PATH_VOIP_CALL_DIRECT_RING  @"path_voip_call_direct_ring"
#define PATH_VOIP_CALL_DIRECT_CONNECT  @"path_voip_call_direct_connect"

#define PATH_VOIP_CALLBACK_INCOMINGCALL  @"path_voip_callback_incomingcall"
#define PATH_VOIP_SWITCH_CALLBACK  @"path_voip_switch_callback"
#define PATH_VOIP_SWITCH_CALLBACK_SUCCESS @"path_voip_switch_callback_success"
#define KEY_CALLID  @"callId"
#define KEY_CALLTYPE  @"type"
#define KEY_COUNT  @"count"
#define KEY_ERROR  @"error"

#define PATH_CALL_ERROR @"path_call_error"


// feedback
#define TYPE_FEEDBACK @"app_feedback"
#define PATH_FEEDBACK @"path_feedback"


#define PATH_RIVAL_APPS @"path_rival_apps"
#define RIVAL_APPS @"rival_apps"
#define RIVAL_APPS_PLIST_VERSION @"rival_apps_plist_version"

#define PATH_REAL_TIME_ACTIVATE @"path_real_time_activate"
#define REAL_TIME_ACTIVATE_TYPE @"real_time_activate_type"

//path_vip  iOS V5370
#define PATH_VIP @"path_vip"
#define KEY_ACTION @"ACTION"
#define CLICK_PERSONAL_CENTER @"click_personal_center"
#define FREE_GET @"free_get"
#define LEARN_MORE @"learn_more"
#define GET_VIP @"get_vip"
#define RENEWAL @"renewal"

#define VIP_DIRECTLY_CALL @"directly_call"
#define VIP_CALL_BACK @"call_back"
#define VIP_AD_ID @"ad_id"
#define VIP_REDIAL @"redial"
#define VIP_CALL_TYPE @"call_type"
#define VIP_ACTION @"action"
#define VIP_ACTION_QUIT @"quit"
#define VIP_ACTION_CONTINUE @"continue"

#define VIP_DATA_ERROR @"vip_data_error"

#define PATH_TASK_REQUEST  @"path_task_request"
#define VIP_TASK_REQUEST_RESULT @"task_request_result"

//iOS V5380
#define PATH_REGISTER_GUIDE_VIEW @"path_register_guide_view"
#define CLICK_COIN_REGISTER @"click_coin_register"
#define CLICK_COIN_NORMAL @"click_coin_normal"
#define CLICK_VS_REGISTER @"click_vs_register"
#define COIN_LOGIN_SUCCESS @"coin_login_success"
#define VS_LOGIN_SUCCESS @"vs_login_success"

#define PATH_INAPP_TESTFREECALL_GUDIE @"path_inapp_testfreecall_guide"
#define UNREGESTER_CLICK @"unregester_click"
#define UNREGESTER_CLICK_TESTFREECALL @"unregester_click_testfreecall"
#define REGESTER_CLICK @"regester_click"
#define REGESTER_CLICK_TESTFREECALL @"regester_click_testfreecall"
#define TESTFREECALL_CLICK_TIP_REGISTER @"testfreecall_click_tip_register"
#define TESTFREECALL_TIP_LOGIN_SUCCESS @"testfreecall_tip_login_success"
#define TESTFREECALL @"testFreeCall"



#define PATH_CALL_REGISTER @"path_call_regist"
#define BEFORECALL_SHOW @"beforecall_show"
#define AFTERCALL_SHOW @"aftercall_show"
#define LONGCALL_SHOW  @"longcall_show"
#define BEFORECALL_LOGIN_SUCCESS @"beforecall_login_success"
#define AFTERCALL_LOGIN_SUCCESS @"aftercall_login_success"
#define LONGCALL_LOGIN_SUCCESS  @"longcall_login_success"

//iOS V5400
#define INTERNATIONAL_CALL_PATH @"international_call_path"
#define KEY_JOIN @"JOIN"


//for A/B test
#define NOTAPPEAR @"notappear"
#define APPEAR @"appear"
#define OK @"ok"
#define NOT @"not"

// contact transfer
#define PATH_CONTACT_TRANSFER @"path_contacts_shift"
#define CONTACT_TRANSFER_ENTRANCE_CLICK @"contacts_shift_entrance_click"
#define CONTACT_TRANSFER_SEND_CLICK @"contacts_shift_send_click"
#define CONTACT_TRANSFER_RECEIVE_CLICK @"contacts_shift_receive_click"
#define CONTACT_TRANSFER_SEND_CONNECTION @"contacts_shift_send_connection"
#define CONTACT_TRANSFER_SEND_CONNECT_SUCCESS @"contacts_shift_send_connect_success"
#define CONTACT_TRANSFER_SEND_CONNECT_FAILED @"contacts_shift_send_connect_failed"
#define CONTACT_TRANSFER_SEND_SUCCESS @"contacts_shift_send_success"
#define CONTACT_TRANSFER_SEND_FAILED @"contacts_shift_send_failed"
#define CONTACT_TRANSFER_RECEIVE_CONNECTION @"contacts_shift_receive_connection"
#define CONTACT_TRANSFER_RECEIVE_CONNECT_SUCCESS @"contacts_shift_receive_connect_success"
#define CONTACT_TRANSFER_RECEIVE_CONNECT_FAILED @"contacts_shift_receive_connect_failed"
#define CONTACT_TRANSFER_RECEIVE_SUCCESS @"contacts_shift_receive_success"
#define CONTACT_TRANSFER_RECEIVE_FAILED @"contacts_shift_receive_failed"
#define CONTACT_TRANSFER_RETRY_INSERT_SUCCESS @"contacts_shift_retry_insert_success"
#define CONTACT_TRANSFER_RETRY_INSERT_FAILED @"contacts_shift_retry_insert_failed"
#define CONTACT_TRANSFER_INSERT_SUCCESS @"contacsts_shift_insert_success"
#define CONTACT_TRANSFER_INSERT_FAILED @"contacts_shift_insert_failed"
#define CONTACT_TRANSFER_TIMEOUT @"contacts_shift_timeout"
#define CONTACT_TRANSFER_WRONG_CONTACT_COUNTS @"contacts_shift_wrong_contact_counts"
#define CONTACT_TRANSFER_WRONG_CONTENT_FORMAT @"contacts_shift_wrong_contact_format"
#define CONTACT_TRANSFER_NO_SECURITY @"contacts_shift_no_security"
#define CONTACT_TRANSFER_UNKNOWN_WRONG @"contacts_shift_unknown_wrong"
#define CONTACT_TRANSFER_ERROR_INTERRUPT @"contacts_shift_error_interrupt"
#define CONTACT_TRANSFER_INSERT_TIME @"contacts_shift_insert_time"

#define PATH_INVITE_PAGE    @"path_invite_page"
// calllog empty
#define PATH_CALLLOG_EMPTY @"path_calllog_empty"
#define CALLLOG_EMPTY_CLICK_LEARN @"calllog_empty_click_learn"
#define CALLLOG_EMPTY_CLICK_SKIN @"calllog_empty_click_skin"
#define CALLLOG_EMPTY_CLICK_KEY_PAD @"calllog_empty_click_key_pad"

//广告数据点排查


#define ADRESOURCE_NOT_READY @"adresource_not_ready"
#define ADRESOURCE_READY @"adresource_ready"

#define HUNGUP_NORMAL @"hangup_normal"
#define AD_SHOW @"ad_show"
#define AD_UN_TU @"ad_un_tu"
#define AD_POSITION @"ad_position"
#define AD_CLICK @"ad_click"
#define P2P @"p2p"
#define C2C @"c2c"

#define PATH_DAILY_REPORT @"path_daily_report"
#define ENTER_PERSONAL_CENTER @"enter_personal_center"
#define ENTER_CONTACT_PAGE @"enter_contact_page"
#define ENTER_DIAL_PAGE @"enter_dial_page"
#define ENTER_FIND_PAGE @"enter_find_page"
#define ENTER_FUWUHAO @"enter_fuwuhao"

#define PATH_RATE_NEW @"path_rate_new"

#define PATH_AUTH_TOKEN @"path_auth_token"
#define AUTH_TOKEN_ERROR_FORMAT @"auth_token_error_format"

#define PATH_RELOGIN @"path_relogin"
#define RELOGIN_FROM_PJCORE @"relogin_from_pjcore"
#define RELOGIN_FROM_SEATTLE @"relogin_from_seattle"
#define RELOGIN_FROM_BACK_CALL @"relogin_from_back_call"

#define API_ERROR_LOGOUT_INFO @"api_error_logout_info"

//回拨挂断之后挂断界面数据点
#define PATH_CALLBACK_HANGUP_CHECK @"path_callback_hangup_check" 
#define CALLBACK_HANGU_STATUS @"callback_hangup_status"

#define PATH_INTERNATIONWEB_CHECK @"path_internationweb_check"
#define NATIVE_CLICK_PASTE @"native_click_paste"
#define NATIVE_CLICK_EXCHANGE @"native_click_exchenge"

#define WEB_CLICK_PASTE @"native_click_paste"
#define WEB_CLICK_EXCHANGE @"native_click_exchenge"



#define PATH_DIAL_SETTING @"path_dial_setting"
#define ENTER_DIAL_SETTING @"enter_dial_setting"
#define ENTER_RIGET_LEFT_SETTING @"enter_riget_left_setting "
#define OPENED_RIGET_LEFT @"opened_riget_left"

#define PATH_LONG_PRESS  @"path_long_press"
#define KEY_CONTACT_ACTION @"contact_action"
#define KEY_CALLLOG_ACTION @"calllog_action"

#define PATH_KEYBOARD @"path_keyboard"
#define BOARD_TYPE @"board_type"

////FEEDS相关数据点
//path
#define PATH_FEEDS @"path_feeds"
//module
#define FEEDS_MODULE @"native"
//guaji相关
#define FEEDS_CLICK_FROM_DIALER @"click_news_feeds_from_dialer"
#define FEEDS_CLICK_GUAJI_RED_PACKET @"click_news_feeds_guaji_redpacket"
#define FEEDS_CANCEL_GUAJI_RED_PACKET @"cancel_news_feeds_guaji_redpacket"


//Feeds list
#define FEEDS_SHOW_WELCOME @"feeds_show_welcome"
#define FEEDS_SHOW_RED_PACKET_LIST @"show_news_feeds_redpacket_list"
#define FEEDS_CLICK_RED_PACKET_LIST @"click_news_feeds_redpacket_list"
#define FEEDS_START_PULL_REFRESH @"pull_refresh_feeds_list"

//Feeds detail
#define FEEDS_SHOW_RED_PACKET_DETAIL @"show_news_feeds_redpacket_detail"
#define FEEDS_CLICK_RED_PACKET_DETAIL @"click_news_feeds_redpacket_detail"


//Feeds sign
#define FEEDS_SIGN_SHOW @"show_feeds_sign"
#define FEEDS_SIGN_CLOSED_BY_CLOSE_BTN @"feeds_sign_closed_by_close_btn"
#define FEEDS_SIGN_CLOSED_BY_OK_BTN @"feeds_sign_closed_by_ok_btn"


//common feeds
#define FEEDS_DISPLAY_OPEN_RED_PACKET @"display_news_feeds_open_redpacket"
#define FEEDS_CLICK_SHOW_RED_PACKET @"click_news_feeds_show_redpacket"
#define FEEDS_CANCEL_SHOW_RED_PACKET @"cancel_news_feeds_show_redpacket"
#define FEEDS_CLICK_OPEN_RED_PACKET @"click_news_feeds_open_redpacket"
#define FEEDS_CANCEL_OPEN_RED_PACKET @"cancel_news_feeds_open_redpacket"
#define FEEDS_CLICK_NEWS_LOGIN_BAR @"click_news_login_bar"

//feeds icon
#define FEEDS_ICON_CLICKED @"click_feeds_icon"
#define FEEDS_ICON_SHOWED @"show_feeds_icon"

//feeds refresh
#define FEEDS_START_REFRESH @"feeds_start_refresh"

//
#define REFRESH_FROM_APP_ACTIVE "app_activie_refresh_feeds"

//feeds refresh
#define FEEDS_REFRESH_LOAD_SUCCESS @"load_success_feeds_refresh"

//feeds refresh bar
#define FEEDS_REFRESH_BAR_LOAD_SUCCESS @"load_success_feeds_refresh_bar"
#define FEEDS_REFRESH_BAR_CLICK_SUCCESS @"click_success_feeds_refresh_bar"

#define PATH_PERFORMANCE @"path_performance"

#define PERFORMANCE_MAIN_ENTRY @"performance_main_entry"

#define PERFORMANCE_WILL_FINISH_LAUNCH @"performance_will_finish_launch"
#define PERFORMANCE_DID_FINISH_LAUNCH @"performance_did_finish_launch"
#define PERFORMANCE_WILL_ENTER_FOREGROUND @"performance_will_enter_foreground"
#define PERFORMANCE_DID_ENTER_FOREGROUND @"performance_did_enter_foreground"

#define PERFORMANCE_DID_BECOME_ACTIVE @"performance_did_become_active"

#define PERFORMANCE_DAILER_VIEW_DID_APPEAR @"performance_dailer_view_did_appear"
#define PERFORMANCE_DAILER_KEYBOARD_DID_SHOW @"performance_dailer_keyboard_did_show"

//commercialSkin
#define PATH_COMMERCIAL_SKIN @"path_commercial_skin"
#define DOWNLOAD_SKIN     @"download_skin"
#define SHOW_SKIN        @"show_skin"
#define USE_SKIN         @"use_skin"

//scancard
#define PATH_SCANCARD @"path_scancard"
#define CONTACT_SCANCARD_ENTRANCE_CLICK @"contacts_scancard_entrance_click"
#define CONTACT_SCANCARD_CAMERA_CLICK @"contacts_scancard_camera_click"
#define CONTACT_SCANCARD_ACCESS_SUCCESS @"contacts_scancard_access_success"
#define CONTACT_SCANCARD_ACCESS_FAIL @"contacts_scancard_access_fail"
#define CONTACT_SCANCARD_SUCCESS @"contacts_scancard_success"
#define CONTACT_SCANCARD_FAIL @"contacts_scancard_fail"
#define CONTACT_SCANCARD_SUCCESS_WITH_NO_NAME_AND_NUMBER @"contacts_scancard_success_with_no_name_and_number"
#define CONTACT_SCANCARD_TIMEOUT @"contacts_scancard_timeout"

//亲情号
#define PATH_FAMILY_NUMBER @"path_family_number"
#define CONTACT_CLICK_FAMILY @"contact_click_family"

// real time custom event
#define PATH_CUSTOM_EVENT  @"path_custom_event"
#define CUSTOM_EVENT_NAME  @"event_name"
#define CUSTOM_EVENT_VALUE @"event_value"

/// custom event - file download
#define CUSTOM_EVENT_FILE_DOWNLOAD_SIZE @"event_file_download_size"
#define CUSTOM_EVENT_FILE_DOWNLOAD_PATH @"store_path"
#define CUSTOM_EVENT_FILE_DOWNLOAD_TAG @"file_tag"

//open screen ad
#define PATH_STARTUP_COMMERCIAL_CUSTOM_EVENT @"path_startup_commercial_custom_event"
#define STARTUP_COMMERCIAL_CUSTOM_EVENT_STEP_NAME @"startup_commercial_custom_event_step_name"
#define STARTUP_COMMERCIAL_CUSTOM_EVENT_STEP_VALUE @"startup_commercial_custom_event_step_value"
#define STARTUP_COMMERCIAL_CUSTOM_EVENT_CAN_SHOW @"startup_commercial_custom_event_can_show"

#define PATH_FEEDS_VIDEO                        @"path_feeds_video"
#define FEEDS_VIDEO_ID                          @"video_id"
#define FEEDS_VIDEO_PLAYED_COUNT                @"played_count"
#define FEEDS_VIDEO_DISPLAYED_COUNT             @"displayed_count"
#define FEEDS_VIDEO_CLICKED                     @"video_clicked"
// 视频播放的百分比。比如，播放了一半，比率为0.50
#define FEEDS_VIDEO_PLAYED_PERCENTAGE           @"played_percentage"
//挂断界面直拨/回拨第一次关闭按钮
#define PATH_HANGUP_CUSTOM_EVENT @"path_hangup_custom_event"
#define PATH_HANGUP_BACKCALL_CUSTOM_EVENT @"path_hangup_backcall_custom_event"

//联系人
#define PATH_CONTACT_VERSIONSiXLATER                        @"path_contact_versonsixlater"
#define PATH_CONTACT_VERSIONSiXLATER_LONGGESTURE            @"path_contact_versonsixlater_longgesture"
#define PATH_CONTACT_VERSIONSiXLATER_CITYCLICK              @"path_contact_versonsixlater_cityclick"
#define PATH_CONTACT_VERSIONSiXLATER_COMPANYCLICK           @"path_contact_versonsixlater_companyclick"
#define PATH_CONTACT_VERSIONSiXLATER_SEARCHVIEWCLICK        @"path_contact_versonsixlater_searchviewclick"
#define PATH_CONTACT_VERSIONSiXLATER_SEARCHINPUT            @"path_contact_versonsixlater_searchinput"
#define PATH_CONTACT_VERSIONSiXLATER_SEARCHSUCCESS          @"path_contact_versonsixlater_searchsuccess"
#define PATH_CONTACT_VERSIONSiXLATER_SUPERSEARCHCLICK       @"path_contact_versonsixlater_supersearchclick"

//熊猫
#define PATH_ASSISTANT                          @"path_assistant"
#define PATH_ASSISTANT_INDEXONE                 @"path_assistant_indexone"
#define PATH_ASSISTANT_INDEXTWO                 @"path_assistant_indextwo"
#define PATH_ASSISTANT_INDEXTHREE               @"path_assistant_indexthree"
#define PATH_ASSISTANT_INDEXFOUR                @"path_assistant_indexfour"
#define PATH_ASSISTANT_INDEXFIVE                @"path_assistant_indexfive"
#define PATH_ASSISTANT_INDEXSIX                 @"path_assistant_indexsix"
#define PATH_ASSISTANT_end                      @"path_assistant_end"

//bibi
#define PATH_BIBI_ICON_SHOW                   @"path_bibi_icon_show"
#define PATH_BIBI_ICON_CLICK                  @"path_bibi_icon_click"
#define PATH_BIBI_GUIDE_SHOW                  @"path_bibi_guide_show"
#define PATH_BIBI_GUIDE_CLICK                 @"path_bibi_guide_click"
#define PATH_BIBI_CALL                        @"path_bibi_call"
#define KEY_CALL                              @"call_type"
#define VALUE_BIBI                            1
#define VALUE_FREE                            2
#define VALUE_NORMAL                          3
#define VALUE_CANCEL                          4

#pragma mark 防骚扰
#define PATH_ANTIHARASS_MASK_SHOW                          @"path_assistant_mask_show"
#define PATH_ANTIHARASS_MASK_CLICK                          @"path_assistant_mask_click"
#define PATH_ANTIHARASS_GUIDE_GO_SETTING                          @"path_assistant_guide_go_setting"
#define PATH_ANTIHARASS_SYSTEM_ENABLE                          @"path_assistant_system_enable"
#define PATH_ANTIHARASS_AUTO_UPDATE                          @"path_assistant_auto_update"

#pragma mark 发现页面
#define PATH_DISCOVER_SUB_PAGE                          @"path_discover_sub_page"


#pragma mark 个人中心页面
#define PATH_PERSON_CENTER_BANNER_MINI                          @"path_person_center_banner_mini"
#define PATH_PERSON_CENTER_BANNER                          @"path_person_center_banner"

#endif

