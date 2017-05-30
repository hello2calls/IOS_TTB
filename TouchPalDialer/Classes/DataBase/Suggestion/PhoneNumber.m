//
//  PhoneNumber.m
//  TouchDataAcess
//
//  Created by Alice on 11-9-5.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "PhoneNumber.h"
#import "DeviceSim.h"
#import "FunctionUtility.h"
#import "MagicUltis.h"

@interface PhoneNumber () {
    MagicUltis *_magic;
}

@end

@implementation PhoneNumber

static PhoneNumber *SharedInstance_ = nil;

+ (PhoneNumber*)sharedInstance
{
    return SharedInstance_;
}

+ (NSString *)getNormalizedNumber:(NSString *)number {
   return [[self sharedInstance] getNormalizedNumber:number];
}

+ (NSString *)getCNnormalNumber:(NSString *)number {
    return [[self sharedInstance] getCNnormalNumber:number];
}

+ (void)setupOrlandoWithSimMnc:(NSString *)simMnc
                    networkMnc:(NSString *)networkMnc
              residentAreaCode:(NSString *)residentAreaCode
                       roaming:(BOOL)roaming
{
    @synchronized(self) {
        SharedInstance_ = [[PhoneNumber alloc] init];
    }
    [SharedInstance_ setupOrlandoWithSimMnc:simMnc
                      networkMnc:networkMnc
                residentAreaCode:residentAreaCode
                         roaming:roaming];
}

- (void)setupOrlandoWithSimMnc:(NSString *)simMnc
                    networkMnc:(NSString *)networkMnc
              residentAreaCode:(NSString *)residentAreaCode
                       roaming:(BOOL)roaming{
    [_magic setupOrlandoWithSimMnc:simMnc
                        networkMnc:networkMnc
                  residentAreaCode:residentAreaCode
                           roaming:roaming];

}

- (id)init {
    self = [super init];
    if (self) {
        _magic = [MagicUltis instance];
    }
    return self;
}


- (NSString *)getCNnormalNumber:(NSString *)number {
    return [_magic getCNnormalNumber:number];
}

//获取国家代号
- (NSString *)getSimCountryName
{
	return [_magic getSimCountryName];
}

//获取归一化电话号码
- (NSString *)getNormalizedNumber:(NSString *)rawNumber
{
	return [_magic getNormalizedNumber:rawNumber];
}

- (NSString *)getNormalizedNumberAccordingNetwork:(NSString *)rawNumber
{
    return [_magic getNormalizedNumberAccordingNetwork:rawNumber];
}

- (NSString *)getAttrAreacodeByNumber:(NSString *)number
{
    return [_magic getAttrAreacodeByNumber:number];
}

- (NSString *)getOriginalNumber:(NSString *)number
{
    return [_magic getOriginalNumber:number];
}

//获取电话号码的归属地
- (NSString *)getNumberAttribution:(NSString *)rawNumber
{
	if([rawNumber length] > 2) {
		NSString *attr = [_magic getNumberAttr:rawNumber withType:attr_type_normal];
    
		if ([attr isEqualToString:@"Local"]) {
			return NSLocalizedString(@"Local","");
		} else if([attr isEqualToString:@"Local service"]) {
            return NSLocalizedString(@"Local service", @"");
        } else{
			return attr;
		}
	} else {
		return nil;
	}
}

- (NSString *)getNumberAttribution:(NSString *)rawNumber
                          withType:(NSInteger)type
{
	if([rawNumber length]>2)
	{
		
          NSString *attr=[_magic getNumberAttr:rawNumber withType:type];
		if ([attr isEqualToString:@"Local"]) {
			return NSLocalizedString(@"Local","");
		}else if([attr isEqualToString:@"Local service"]) {
            return NSLocalizedString(@"Local service", @"");
        }else {
			return attr;
		}
	}else {
		return nil;
	}
}

- (NSString *)getNumberAttribution_WithOutConsideringPersonExist:(NSString *)rawNumber
                                                        withType:(NSInteger)type
{
	if([rawNumber length]>2) {
        NSString *attr=[_magic getNumberAttr_WithOutConsidertingPersonExist:rawNumber withType:type];
		if ([attr isEqualToString:@"Local"]) {
			return NSLocalizedString(@"Local","");
		} else if([attr isEqualToString:@"Local service"]) {
            return NSLocalizedString(@"Local service", @"");
        } else {
			return attr;
		}
	} else {
		return nil;
	}
}

- (NSArray *)getProfileByOperCode:(NSString *)opera_code
{
	return [_magic getProfileByOperCode:opera_code];
}

//拿到profile的规则列表
- (NSArray *)getRulesByProfileId:(NSInteger)profile_id
{
    return [_magic getProfileByRule:profile_id];
}

//get当前活动的profile
- (ProfileModel *)getActiveProfile
{
	return [_magic getActiveProfile];
}

//设置当前活动的profile
- (void)setActiveProfile:(NSInteger)profile_id
{
	return [_magic setActiveProfile:profile_id];
}

- (ProfileModel *)getProfile:(NSInteger)profile_id
{
    return [_magic getProfile:profile_id];
}

//添加profile
- (void)addProfile:(ProfileModel *)profile
{
	[_magic addProfile:profile];
}

//删除profile
- (void)removeProfile:(ProfileModel *)profile
{
	[_magic removeProfile:profile];
}

- (void)setAreaCode:(NSString *)areaCode
{
    [_magic setAreaCode:areaCode];
}

- (void)setRoaming:(BOOL)roaming
{
     [_magic setRoaming:roaming];
}

- (BOOL)getRoaming
{
   return [_magic getRoaming];
}

- (NSString *)getCountryNameOf2Chars:(NSString *)mnc
{
    return [_magic getCountryCodeByMnc:mnc];
}

- (NSString *)getMainOperateByMnc:(NSString *)mnc
{
     return [_magic getMainOperateByMnc:mnc];
}

- (NSString *)getAreaCountryInfo
{
    return [_magic getAreaCountryInfo];
}

//获取推荐号码列表
- (NSArray *)getSuggestionsNumber:(NSString *)number
                         autoDial:(BOOL)autoDial
                  smartDialAdvice:(BOOL)smartDialAdvice
                          roaming:(BOOL)roaming
             internationalRoaming:(BOOL)internationalRoaming
{
    return [_magic getSuggestionsNumber:number
                                              autoDial:autoDial
                                       smartDialAdvice:smartDialAdvice
                                               roaming:roaming
                                  internationalRoaming:internationalRoaming];
}

- (void)setSimOperationCode:(NSString *)simcode
{
    return [_magic setSimOperationCode:simcode];
}

- (void)setNetworkOperationCode:(NSString *)networkcode
{
    return [_magic setNetworkOperationCode:networkcode];
}

- (NSString *)getMccByCountryCodeWithLeadingPlus:(NSString *)countryCode
{
    return [_magic getMccByCountryCode:countryCode];
}

- (BOOL)isCNSim {
    return [[self getSimCountryName] isEqual:@"cn"];
}
@end
