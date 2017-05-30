//
//  CallLogDataModel.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-13.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "CallLogDataModel.h"
#import "ContactCacheDataManager.h"
#import "BasicUtil.h"
#import "AppSettingsModel.h"
#import "TouchPalDialerAppDelegate.h"
#import "NSString+PhoneNumber.h"
#import "TouchPalMembersManager.h"

@implementation CallLogDataModel

@synthesize rowID = _rowID;
@synthesize shopID = _shopID;
@synthesize mainShopID = _mainShopID;
@synthesize city = _city;
@synthesize personID = _personID;
@synthesize number = _number;
@synthesize phoneLabel = _phoneLabel;
@synthesize name = _name;
@synthesize callTime = _callTime;
@synthesize callCount = _callCount;
@synthesize callType = _callType;
@synthesize duration = _duration;
@synthesize callerID = callerID_;
@synthesize missedCount;

- (id)init
{
	self = [super init];
	if( self != nil ) {
		self.personID = -1;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone{
    CallLogDataModel *model = [[[self class] alloc] init];
    model.rowID = self.rowID;
    model.shopID = self.shopID;
    model.city = self.city;
    model.personID = self.personID;
    model.number = self.number;
    model.phoneLabel = self.phoneLabel;
    model.name = self.name;
    model.callTime = self.callTime;
    model.callCount = self.callCount;
    model.callType = self.callType;
    model.duration = self.duration;
    model.callerID = self.callerID;
    model.missedCount = self.missedCount;
    return model;
}

- (id)initWithPersonId:(NSInteger)personId
           phoneNumber:(NSString*)phoneNumber
              callType:(CallLogType)type
              duration:(NSInteger)duration
         loadExtraInfo:(BOOL)loadExtraInfo
{
    self = [self init];
    self.shopID = 0;
    self.mainShopID = 0;
    self.personID = personId;
    self.number = [phoneNumber formatPhoneNumber];
    self.phoneLabel = @"";
    self.name = @"";
    _callType = type;
    _duration= duration;
    if(loadExtraInfo && personId > 0) {
        self.name= [[ContactCacheDataManager instance] contactCacheItem:personId].fullName;
    }
    self.ifVoip = ([TouchpalMembersManager isNumberRegistered:_number] == 1);
    return self;
}
- (id)initWithShopID:(unsigned long long)shopID
         phoneNumber:(NSString *)number
                name:(NSString *)name
            mainShop:(unsigned long long)mainShop
{
    self = [self init];
    self.personID = -1;
    self.shopID = shopID;
    self.mainShopID = mainShop;
    self.number = [number formatPhoneNumber];
    self.phoneLabel = @"";
    self.name = name;
    return self;
}
- (id)initWithPersonId:(NSInteger)personId
           phoneNumber:(NSString*)phoneNumber
         loadExtraInfo:(BOOL)loadExtraInfo
{
    return [self initWithPersonId:personId
                      phoneNumber:phoneNumber
                         callType:CallLogOutgoingType
                         duration:0
                    loadExtraInfo:loadExtraInfo];
}

- (CallLogDataModel *)copy
{
	CallLogDataModel *call_log = [[CallLogDataModel alloc] init];
    call_log.personID = self.personID;
    call_log.shopID = self.shopID;
    call_log.mainShopID = self.mainShopID;
    call_log.city = self.city;
    call_log.number = self.number;
    call_log.rowID = self.rowID;
    call_log.callTime = self.callTime;
    call_log.callCount = self.callCount;
    call_log.phoneLabel = self.phoneLabel;
    call_log.name = self.name ;
    call_log.callType = self.callType;
    call_log.ifVoip = self.ifVoip;
    return call_log;
}

- (CallerIDInfoModel *)callerID
{
    return callerID_;
}


- (CloudCallLogItem *)cloudCallLogItem
{
    CloudCallLogItem *item = [[CloudCallLogItem alloc] init];
    item.otherPhone = self.number;
    item.type = [CallLogDataModel callTypeString:self.callType];
    item.isContact = self.personID > 0;
    item.date = self.callTime;
    if(self.callType!= CallLogIncomingMissedType){
        item.duration = self.duration;
        item.ringTime = -1;
    }else{
        item.duration =0;
        item.ringTime = self.duration;
    }
    return item;
}

+ (NSString *)callTypeString:(CallLogType)type
{
    if(type == CallLogIncomingType || type == CallLogIncomingMissedType){
        return IN_COMMING_CALL;
    }else if (type == CallLogOutgoingType){
        return OUT_GOING_CALL;
    }else{
        return OUT_GOING_CALL;
    }
}
@end
