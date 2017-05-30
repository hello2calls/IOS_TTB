//
//  CallerIDInfoModel.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CallerIDInfoModel.h"
#import "FunctionUtility.h"
#import "PhoneNumber.h"

@implementation CallerIDInfoModel

@synthesize vipID;
@synthesize name;
@synthesize number;
@synthesize callerType;
@synthesize callerIDCacheLevel;
@synthesize versionTime;
@synthesize markCount;
@synthesize surveyInfo;
@synthesize guessedAreaCode;

static NSArray* allKnownCallerTypes;

+ (void)initialize
{    
    allKnownCallerTypes = [[NSArray alloc] initWithObjects:
                           @"house agent",
                           @"insurance",
                           @"financial products",
                           @"headhunting",
                           @"promote sales",
                           @"repair",
                           @"book hotel/airline",
                           @"public services",
                           @"express",
                           @"fraud",
                           @"crank",
                           nil];
}

+ (id)modelWithNumber:(NSString *)number
                 name:(NSString *)name
                 type:(NSString *)type
{
    CallerIDInfoModel* model = [[CallerIDInfoModel alloc] init];
    if(![number hasPrefix:@"+"]){
        number = [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:number];
    }
    model.number = number;
    model.name = name;
    model.callerType = type;
    return model;
}

- (id)init
{
	self = [super init];
	if( self != nil ) {
        self.vipID = 0;
        self.name = @"";
        self.number = @"";
        self.callerType = @"";
        self.versionTime = @"0";
	}
	return self;
}

- (id)initWithCloudData:(CloudCallerIdInfo *)info
{
    self = [super init];
    if (self != nil) {
        self.vipID = 0;
        self.isVerified = info.isVerified;
        self.name = info.shopName;
        self.number = info.phone;
        self.callerType = info.classifyType;
        self.versionTime = @"0";
        self.markCount = [info.markCount integerValue];
        self.surveyInfo = info.survey;
        self.guessedAreaCode = info.areaCode;
        if(self.guessedAreaCode.length > 0){
            self.callerIDCacheLevel = CallerIDQueryGuessAreaCodeLevel;
        }else{
            self.callerIDCacheLevel = CallerIDQueryNetWorkLevel;
        }
    }
    
    return self;
}


- (BOOL) isCallerIdUseful
{
    if(self.name.length > 0) {
        return YES;
    }    
    return [self hasTag];
}

- (BOOL) hasTag
{
    return [[self validCallerType] length] > 0;
}

- (NSString*) localizedTag
{
    NSString* tag = [self validCallerType];
    return NSLocalizedString(tag, @"");
}

-(NSString*) validCallerType
{
    if([callerType length] > 0){
        if ([self.name length] == 0) {
            if([allKnownCallerTypes containsObject:self.callerType]) {
                return self.callerType;
            }
        }
    }
    return @"";
}

- (NSString *)getUsefulString {
    NSString *callerIDString = self.name;
    if([FunctionUtility isNilOrEmptyString:callerIDString]) {
        callerIDString = self.localizedTag;
    }
    return callerIDString;
}

+ (NSString *)knownCallerTypeOrEmpty:(NSString *)callerType
{
    if ([allKnownCallerTypes containsObject:callerType]) {
        return callerType;
    } else {
        return @"";
    }
}

@end
