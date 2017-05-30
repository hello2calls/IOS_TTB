//
//  AntiharassDataManager.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/18.
//
//

#import <Foundation/Foundation.h>
static NSString * const kCallDirectoryID = @"com.cootek.Contacts.CallDirectoryExtension";
static NSString * const kIntermediaryCallID = @"com.cootek.Contacts.IntermediaryCallExtension";
static NSString * const kFraudCallID = @"com.cootek.Contacts.FraudCallExtension";
static NSString * const kPromoteCallID = @"com.cootek.Contacts.PromoteCallExtension";
static NSString * const kYellowPageCallID = @"com.cootek.Contacts.YellowPageCallExtension";

static NSString * const kCallDirectoryKey = @"CallDirectoryKey";
static NSString * const kIntermediaryKey = @"IntermediaryKey";
static NSString * const kFraudCallKey = @"FraudCallKey";
static NSString * const kPromoteCallKey = @"PromoteCallKey";
static NSString * const kYellowPageCallKey = @"YellowPageCallKey";
@interface AntiharassDataManager : NSObject

+ (instancetype)sharedManager;

- (void)checkUpdateAntiDataInBackground;
- (void)checkUpdateAntiDataInHand;
- (void)downLoadDBZipWithDBIntVersion:(NSInteger)db_version city:(NSString *)city;
+ (void)updateCallExtensionEnableStatus;
+ (BOOL)loadDBWithdbShortName:(NSString *)dbShortName withCity:(NSString *)city;
+ (NSArray *)getdbShortNameArrayShowReloadToExtentionWithExtentionFileInfo;
- (void)saveInfoToExtentionFileWithCity:(NSString *)city;
+ (NSString *)getNowExtentionFileInfoCity;
+ (BOOL)checkIfNowReloadExtention;
+ (void)checkAsyncLoadDBData;
+ (void)resetShouldReloadCountToExtentionCountWhenLuanch;
@end
