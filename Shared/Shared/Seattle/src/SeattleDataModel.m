//
//  SeattleDataModel.m
//  CallerInfoShow
//
//  Created by Elfe Xu on 13-1-31.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//

#import "SeattleDataModel.h"

@implementation StatisticInfo

@synthesize totalCallerId;
@synthesize recentlyCallerId;
@synthesize recogCallerId;
@synthesize userContribute;
@end

@implementation CloudBlackItem
#define PHONE_BLACKITEM @"phone"
#define ISCONTACT_BLACKITEM @"isContact"

@synthesize phone;
@synthesize isContact;

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.phone = [aDecoder decodeObjectForKey:PHONE_BLACKITEM];
        self.isContact = [[aDecoder decodeObjectForKey:ISCONTACT_BLACKITEM] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:self.isContact forKey:ISCONTACT_BLACKITEM];
    [aCoder encodeObject:self.phone forKey:PHONE_BLACKITEM];
}

@end

@implementation BaseShopInfo

@synthesize shopId;
@synthesize googleMapUrl;
@synthesize location;
@synthesize distance;

@end

@implementation FullShopInfo

@synthesize address;

@end

@implementation SurveyInfo

@synthesize systemName;
@synthesize systemTag;


@end

@implementation CloudCallerIdInfo

@synthesize phone;
@synthesize isVerified;
@synthesize classifyType;
@synthesize shopName;
@synthesize markCount;
@synthesize survey;
@synthesize areaCode;

@end

@implementation DetailLocation

@synthesize countryCode;
@synthesize region;
@synthesize city;
@synthesize district;
@synthesize address;
@synthesize location;
@end

@implementation CloudVersionInfo
@synthesize version;
@synthesize url = url_;
@synthesize description_en_us = description_en_us_;
@synthesize description_zh_cn = description_zh_cn_;
@synthesize description_zh_tw = description_zh_tw_;
@end

@implementation CloudPackageInfo

@synthesize cityID;
@synthesize cityName;
@synthesize mainVersion;
@synthesize mainPath;
@synthesize mainSize;
@synthesize updateVersion;
@synthesize updatePath;
@synthesize updateSize;

@end

@implementation CloudCallLogItem
#define OTHER_PHONE_CALLLOG @"otherPhone"
#define TYPE_CALLLOG        @"type"
#define ISCONTACT_CALLLOG   @"isContact"
#define DATE_CALLLOG        @"date"
#define DURATION_CALLLOG    @"duration"
#define RINGTIME_CALLLOG    @"ringTime"

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.otherPhone = [aDecoder decodeObjectForKey:OTHER_PHONE_CALLLOG];
        self.type = [aDecoder decodeObjectForKey:TYPE_CALLLOG];
        self.isContact = [[aDecoder decodeObjectForKey:ISCONTACT_CALLLOG] boolValue];
        self.date = [[aDecoder decodeObjectForKey:DATE_CALLLOG] longValue];
        self.duration = [[aDecoder decodeObjectForKey:DURATION_CALLLOG] longValue];
        self.ringTime = [[aDecoder decodeObjectForKey:RINGTIME_CALLLOG] longValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.otherPhone forKey:OTHER_PHONE_CALLLOG];
    [aCoder encodeObject:self.type forKey:TYPE_CALLLOG];
    [aCoder encodeObject:@(self.isContact) forKey:ISCONTACT_CALLLOG];
    [aCoder encodeObject:@(self.date) forKey:DATE_CALLLOG];
    [aCoder encodeObject:@(self.duration) forKey:DURATION_CALLLOG];
    [aCoder encodeObject:@(self.ringTime) forKey:RINGTIME_CALLLOG];
}

@end