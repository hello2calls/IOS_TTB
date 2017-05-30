//
//  CalleridUpdateInfo.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/11.
//
//

#import <Foundation/Foundation.h>

#define FILE_ID @"id"
#define MAIN_URL @"main_url"
#define MAIN_VERSION @"main_version"
#define UPDATE_URL @"update_url"
#define UPDATE_VERSION @"update_version"

@interface CalleridUpdateInfo : NSObject

@property (nonatomic, copy) NSString *fileId;
@property (nonatomic, copy) NSString *mainUrl;
@property (nonatomic, copy) NSString *mainVersion;
@property (nonatomic, copy) NSString *updateUrl;
@property (nonatomic, copy) NSString *updateVersion;

@end
