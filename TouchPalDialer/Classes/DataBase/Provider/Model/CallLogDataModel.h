//
//  CallLogDataModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-13.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallerIDInfoModel.h"
#import "SearchResultModel.h"

#define IN_COMMING_CALL @"incoming"
#define OUT_GOING_CALL @"outgoing"

typedef enum {
    CallLogOutgoingType = 0,
    CallLogIncomingType = 1,
    CallLogIncomingMissedType = 2,
    CallLogTestType = 3
}CallLogType;

@interface CallLogDataModel : NSObject<BaseContactsDataSource,BaseCallerIDDataSource, NSCopying>

- (id)initWithShopID:(unsigned long long)shopID
         phoneNumber:(NSString *)number
                name:(NSString *)name
            mainShop:(unsigned long long)mainShop;

- (id)initWithPersonId:(NSInteger) personId
           phoneNumber:(NSString*)phoneNumber
         loadExtraInfo:(BOOL)loadExtraInfo;

- (id)initWithPersonId:(NSInteger) personId
           phoneNumber:(NSString*)phoneNumber
              callType:(CallLogType)type
              duration:(NSInteger)duration
         loadExtraInfo:(BOOL)loadExtraInfo;

- (CloudCallLogItem *)cloudCallLogItem;

+ (NSString *)callTypeString:(CallLogType)type;

@property(nonatomic,assign) NSInteger rowID;
@property(nonatomic,assign) NSInteger personID;
@property(nonatomic,assign) unsigned long long shopID;
@property(nonatomic,assign) unsigned long long mainShopID;
@property(nonatomic,assign) NSInteger callCount;
@property(nonatomic,assign) NSInteger missedCount;
@property(nonatomic,assign) NSInteger callTime;
@property(nonatomic,assign) CallLogType callType;
@property(nonatomic,assign) NSInteger duration;
@property(nonatomic,copy) NSString *city;
@property(nonatomic,copy) NSString *number;
@property(nonatomic,copy) NSString *phoneLabel;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,assign) BOOL ifVoip;
@property(nonatomic,assign) BOOL callFromOutside;

@end
