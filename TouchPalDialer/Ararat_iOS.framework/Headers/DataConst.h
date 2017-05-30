//
//  DataConst.h
//  Ararat_iOS
//
//  Created by Cootek on 15/8/19.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#ifndef Ararat_iOS_DataConst_h
#define Ararat_iOS_DataConst_h

typedef enum : NSInteger{
    NCWifi_First = 4,
    NCMobile = 2,
    NCAny = 3,
    NCWifi = 1,
}NetworkConnection;

//SDK version
#define ARARAT_SDK_VERSION                  @"1000"

//Time
#define DEFAULT_CHECK_INTERVAL_TIME         60*60

//Database
#define DATA_CHANNEL_DB_NAME                @"ararat.db"
#define DATA_NAME_PRESENTATION              @"Presentation"
#define DATA_NAME_PRESENTATION_CONF         @"PresentationConf"
#define DATA_CONF_FOR_UPDATE                @"ConfForUpdate"

//request default const
#define CONFIG                              @"config"
#define URLPACK                             @"urlpack"

#define DOMAIN_NAME                         @"domain_name"
#define MODULE_NAME                         @"module_name"
#define CONNECTION                          @"connection"
#define UPDATE_INTERVAL                     @"update_interval"
#define CONF_VERSION                        @"conf_version"

#define SERVICE                             @"service"
#define REQTYPE                             @"reqtype"
#define DATA_NAME                           @"data_name"
#define EXTRA                               @"extra"
#define SDKVERSION                          @"sdkversion"
#define LAST_TIME                           @"lasttime"
#define LOCALE                              @"locale"

#define ENABLE                              @"enable"
#define NAME                                @"name"
#define ASSIGN                              @"assign"
#define VALUE                               @"value"

#define LAST_TIME_REQUEST_SUCCESS           @"LAST_TIME_REQUEST_SUCCESS"

//receive new notification
#define RECEIVE_NEW_FIDS                @"RECEIVE_NEW_FIDS"

#endif
