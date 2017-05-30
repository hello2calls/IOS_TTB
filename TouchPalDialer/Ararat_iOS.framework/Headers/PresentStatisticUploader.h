//
//  PresentStatisticUploader.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/15.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentStatistic.h"
#define TYPE_CLICK @"CLICK"
#define TYPE_SHOW @"SHOW"
#define TYPE_DISMISS @"DISMISS"

#define TYPE_DOWNLOAD @"DOWNLOAD"
#define TYPE_INSTALL @"INSTALL"

#define SUBTYPE_START @"START"
#define SUBTYPE_FINISH @"FINISH"
#define SUBTYPE_HANDLED @"HANDLED"

#define TYPE_WEBPAGE @"WEBPAGE"
#define SUBTYPE_OPENED @"OPENED"
#define SUBTYPE_LOADED @"LOADED"

#define TYPE_LOCALPAGE @"LOCALPAGE"
#define SUBTYPE_LAUNCHED @"LAUNCHED"

#define DISMISS_TOASTCLICKED @"TOASTCLICKED"
#define DISMISS_TOASTCLOSED @"TOASTCLOSED"
#define DISMISS_TOASTCLEANED @"TOASTDCLEANED"
#define DISMISS_PAGEOPENED @"PAGEOPENED"
#define DISMISS_PAGELOADED @"PAGELOADED"
#define DISMISS_FINISHINSTALLED @"FINISHINSTALLED"
#define DISMISS_FINISHDOWNLOAD @"FINISHDOWNLOAD"
#define DISMISS_STARTDOWNLOAD @"STARTDOWNLOAD"
#define DISMISS_APPLAUNCHED @"APPLAUNCHED"
#define DISMISS_APPLAUNCH_NOAPP @"APPLAUNCH_NOAPP"


@interface PresentStatisticUploader : NSObject

+ (void)saveFeature:(NSString *)feature
          Timestamp:(long long)timestamp
               Type:(NSString *)type
            SubType:(NSString *)subType;
+ (void)saveService:(NSString *)serviceId
          MessageId:(NSString *)messageId
          Timestamp:(long long)timestamp
     MessageVersion:(NSInteger)version;
+ (NSString *)getSubType:(int)value;

@end
