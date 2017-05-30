//
//  PresentationXMLTag.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/26.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

//XML ETAG
#define PRESENT_FILE_ETAG               @"PRESENT_FILE_ETAG"

//Time
#define DAY_MILLIS                      24 * 60 * 60

//Strategy Attribute
#define STRATEGYTOAST                   @"StrategyToast"
#define STATUSBARQUIETDAYS              @"statusbarQuietDays"
#define STARTUPQUIETDAYS                @"startupQuietDays"
#define TOOLBARQUIETDAYS                @"toolbarQuietDays"

//Feature Group root
#define FEATURE_GROUP_ROOT                      @"messages"

//Feature root
#define FEATURE_ROOT_UPDATE_PROGRAM             @"updateProgram"
#define FEATURE_ROOT_APP_ROMOTE                 @"promoApp"
#define FEATURE_ROOT_NEW_WORDS_UPDATE           @"newWordsUpdate"
#define FEATURE_ROOT_KEYWORDS_APP_PROMOTE       @"keywordAppPromo"
#define FEATURE_ROOT_SENSITIVE_APP_PROMOTE      @"appSensitivePromo"
#define FEATURE_ROOT_SENSITIVE_APP_USAGE        @"appSensitiveUsage"
#define FEATURE_ROOT_PERIODIC_TASKS             @"periodicTask"
#define FEATURE_ROOT_PUSH_EVENT                 @"pushEvent"
#define FEATURE_ROOT_PERSONAL_EVENT             @"personalEvent"
#define FEATURE_ROOT_EXTENSION_PIONT_FEATURE    @"extensionPointFeature"
#define FEATURE_ROOT_TOAST_DRIVEN_FEATURE       @"toastDriven"

//Feature Attributes
#define FEATURE_ATTR_FID                        @"fid"
#define FEATURE_ATTR_LATEST_VERSTION            @"latestVersion"
#define FEATURE_ATTR_INITIAL_PROMPT_DAYS        @"initialPromptDays"
#define FEATURE_ATTR_PROMPT_INTERVAL            @"promptInterval"
#define FEATURE_ATTR_PROMPT_TIMES               @"promptTimes"
#define FEATURE_ATTR_PACKAGE_NAME               @"packageName"
#define FEATURE_ATTR_PACKAGE_OLD_VRESION        @"packageOldVersion"
#define FEATURE_ATTR_KEYWORDS                   @"keywords"
#define FEATURE_ATTR_SENSITIVE_APPS             @"app"
#define FEATURE_ATTR_TIMESTAMP_SETTING_KEY      @"timestampSettingKey"
#define FEATURE_ATTR_DEPENDENCY_SETTING_KEY     @"dependencySettingKey"
#define FEATURE_ATTR_DEPENDENCY_SETTING_TYPE    @"dependencySettingType"
#define FEATURE_ATTR_DEPENDENCY_SETTING_VALUE   @"dependencySettingValue"
#define FEATURE_ATTR_PRIORITY                   @"priority"
#define FEATURE_ATTR_START_DATE                 @"startDate"
#define FEATURE_ATTR_EXPIRED_DATE               @"expiredDate"
#define FEATURE_ATTR_START_HOUR                 @"startHour"
#define FEATURE_ATTR_END_HOUR                   @"endHour"
#define FEATURE_ATTR_START_VERSION              @"startSelfVersion"
#define FEATURE_ATTR_END_VERSION                @"endSelfVersion"
#define FEATURE_ATTR_EXTENSION_POINT            @"extensionPoint"
#define FEATURE_ATTR_EXTENSION_CONDITIONS       @"extensionConditions"

//Toast suffix
#define TOAST_SUFFIX                            @"Toast"

//Toast root
#define TOAST_ROOT_TOOLBAR                      @"toolbarToast"
#define TOAST_ROOT_STATUS_BAR @"statusbarToast"
#define TOAST_ROOT_NEXTWORD @"nextWordToast"
#define TOAST_ROOT_CLOUD_INPUT @"cloudInputToast"
#define TOAST_ROOT_STARTUP @"startupToast"
#define TOAST_ROOT_DUMMY @"dummyToast"
#define TOAST_ROOT_FULLSCREEN @"fullscreenToast"
#define TOAST_ROOT_EXTENSION_STATIC @"extensionStaticToast"
#define TOAST_ROOT_GUIDE_POINTS @"guidePointsToast"
#define TOAST_ROOT_DESKTOP_SHORTCUT @"desktopShortcutToast"
#define TOAST_ROOT_POPUP @"popupToast"
#define TOAST_ROOT_BACKGROUNDIMAGE @"backgroundImageToast"
#define TOAST_ROOT_FRECALLHANGUP @"freecallHangupToast"

//Toast Attributes
#define TOAST_ATTR_ALLOW_CLEAN @"allowClean"
#define TOAST_ATTR_CLICK_CLEAN @"clickClean"
#define TOAST_ATTR_CLEAR_RULE @"clearRule"
#define TOAST_ATTR_NOT_SHOW_AGAIN @"notShowAgain"
#define TOAST_ATTR_ENSURE_NETWORK @"ensureNetwork"
#define TOAST_ATTR_DISPLAY_TITLE @"display"
#define TOAST_ATTR_DISPLAY_SUMMARY @"description"
#define TOAST_ATTR_ACTION_CONFIRM_INFO @"actionConfirm"
#define TOAST_ATTR_IMAGE_URL @"imageUrl"
#define TOAST_ATTR_AUTO_DOWNLOAD_URL @"autoDownloadUrl"
#define TOAST_ATTR_TOAST_TAG @"tag"
#define TOAST_ATTR_TOAST_DURATION @"duration"
#define TOAST_ATTR_DOWNLOAD_STRATEGY @"downloadStrategy"

#define TOAST_ATTR_SHOW_LOGO @"showLogo"

#define TOAST_ATTR_GUIDE_POINT_ID @"guidePointId"
#define TOAST_ATTR_EXTENSION_POINT @"extensionPoint"

#define TOAST_ATTR_FULLSCREEN_FILE_PATH @"filePath"
#define TOAST_ATTR_FULLSCREEN_SHOW_PATH @"showPath"

#define TOAST_ATTR_IMAGE_TYPE @"imageType"
#define TOAST_ATTR_START_TIME @"startTime"
#define TOAST_ATTR_END_TIME @"endTime"

#define TOAST_ATTR_TYPE @"type"

// File path postfix
#define POSTFIX_FILE_PATH_ZIP @".zip"
#define POSTFIX_FILE_PATH_HTML @".htm"

// Fullscreen toast
#define FULLSCREEN_URL_NAME @"index.htm"

//Action root
#define ACTION_ROOT @"action"

//Action Attributes
#define ACTION_ATTR_TYPE @"action"
#define ACTION_ATTR_AUTO_START @"autoStart"
#define ACTION_ATTR_URL @"url"
#define ACTION_ATTR_DOWNLOAD_CONFIRM @"downloadConfirm"
#define ACTION_ATTR_NON_WIFI_REMINDER @"nonWiFiReminder"
#define ACTION_ATTR_PAUSABLE @"pausable"
#define ACTION_ATTR_CANCELABLE @"cancelable"
#define ACTION_ATTR_AUTO_INSTALL @"autoInstall"
#define ACTION_ATTR_NEED_INSTALL @"needInstall"
#define ACTION_ATTR_CLEAN_ACKNOWLEDGE @"cleanAcknowledge"
#define ACTION_ATTR_REQUEST_TOKEN @"requestToken"
#define ACTION_ATTR_APP_NAME @"appName"
#define ACTION_ATTR_SETTING_NAME @"name"
#define ACTION_ATTR_ONLY_FOR_DEFAULT @"onlyForDefault"

#define ACTION_ATTR_TITLE @"title"
#define ACTION_ATTR_INTENT @"intent"
#define ACTION_ATTR_DATA @"data"
#define ACTION_ATTR_PACKAGE_NAME @"packageName"

#define ACTION_ATTR_PROCESS_MODLUE @"processMoudle"

#define ACTION_ATTR_EXECUTE_TYPE @"type"
#define ACTION_ATTR_EXECUTE_FID @"fid"
#define ACTION_ATTR_TOAST_TYPE @"toastType"

#define EXECTUE_TYPE_SHOW @"show"
#define EXECTUE_TYPE_EXECUTE @"execute"

//Action Values
#define ACTION_TYPE_DOWNLOAD_IN_STATUS @"downloadInStatus"
#define ACTION_TYPE_LAUNCH_WEB_VIEW @"launchWebView"
#define ACTION_TYPE_LAUNCH_LOCAL_APP @"launchLocalApp"
#define ACTION_TYPE_LAUNCH_APP_INSTALLER @"launchAppInstaller"
#define ACTION_TYPE_CHANGE_LOCAL_SETTINGS @"changeLocalSettings"
#define ACTION_TYPE_HANDLE_DOWNLOADED_FILE @"downloadInBackground"
#define ACTION_TYPE_DUMMY @"dummy"
#define ACTION_TYPE_EXECUTE_SOME_TOAST @"executeOther"
#define ACTION_LOCAL_PAGE_NAME @"localPageName"

#define SETTING_TYPE_BOOLEAN @"bool"
#define SETTING_TYPE_LONG @"long"
#define SETTING_TYPE_INT @"integer"
#define SETTING_TYPE_STRING @"string"
#define SETTING_TYPE_BOOLEANARRAY @"boolsArray"
#define SETTING_TYPE_LONGARRAY @"longsArray"
#define SETTING_TYPE_INTARRAY @"integersArray"
#define SETTING_TYPE_STRINGARRAY @"stringsArray"
#define GUIDE_POINTS_GROUP @"guidePoints"
#define GUIDE_POINT_NODE @"guidePoint"

#define GUIDE_POINT_ATTR_ID @"id"
#define GUIDE_POINT_ATTR_TYPE @"type"
#define GUIDE_PIONT_ATTR_DISMISS_RULE @"dismissRule"
#define GUIDE_POINT_ATTR_HOLDER_SHOW_CONDITION @"holderShowConditions"
#define GUIDE_POINT_ATTR_SELF_SHOW_CONDITION @"selfShowConditions"
#define GUIDE_PIONT_ATTR_EXTENSION_ID @"extensionPointId"

//action type
#define ACTION_TYPE_EXCEPTION -1
#define ACTION_TYPE_NONE 0
#define ACTION_TYPE_INSTALL_FINISHED 1
#define ACTION_TYPE_DOWNLOAD_FINISHED 2
#define ACTION_TYPE_DOWNLOAD_STARTED 3
#define ACTION_TYPE_LOCAL_PAGE_LAUNCHED 4
#define ACTION_TYPE_LOCAL_PAGE_QUIT 5
#define ACTION_TYPE_WEBPAGE_LOADED 6
#define ACTION_TYPE_WEBPAGE_OPENED 7
#define ACTION_TYPE_HOST_APP_CLOSED 8
#define ACTION_TYPE_TOAST_CLICKED 9
#define ACTION_TYPE_TOAST_CLOSED 10
#define ACTION_TYPE_TOAST_CLEANED 11
#define ACTION_TYPE_INSTALL_STARTED 12
#define ACTION_TYPE_SETTINGS_CHANGED 13
#define ACTION_TYPE_DOWNLOAD_HANDLED 14

