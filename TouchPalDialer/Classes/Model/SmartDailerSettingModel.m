//
//  SmartDailerSettingModel.m
//  TouchPalDialer
//
//  Created by Ailce on 12-2-20.
//  Refactored by Leon on 13-3-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SmartDailerSettingModel.h"
#import "DeviceSim.h"
#import "NumberPersonMappingModel.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "OrlandoEngine.h"
#import "CootekNotifications.h"
#import "ContactCacheChangeCommand.h"
#import "PhoneNumber.h"
#import "RuleModel.h"
#import "ProfileModel.h"

static BOOL CachedIsChinaSim_;  // indicates if the value has been cached
static BOOL IsChinaSimCached_;  // the value

@interface SmartDailerSettingModel (){
    PhoneNumber *phoneNumberUtil_;
}
@end

@implementation SmartDailerSettingModel

+ (void)initialize
{
    CachedIsChinaSim_ = NO;
}

+ (SmartDailerSettingModel *)settings
{
    return [[SmartDailerSettingModel alloc] init];
}

+ (BOOL)isChinaSim
{
    if (CachedIsChinaSim_) {
        return IsChinaSimCached_;
    }
    
    [self cacheIsChinaSim];
    
    return IsChinaSimCached_;
}

+ (void)cacheIsChinaSim
{
    SmartDailerSettingModel *settings = [SmartDailerSettingModel settings];
    IsChinaSimCached_ = [settings.simMnc hasPrefix:@"460"];
    CachedIsChinaSim_ = YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        phoneNumberUtil_ = [PhoneNumber sharedInstance];
    }
    return self;
}

// smart dial advice enabled
- (BOOL)isSmartDialAdviceEnabled
{
    return [UserDefaultsManager boolValueForKey:IS_SMART_DAIL_ADVICE];
}

- (void)setSmartDialAdviceEnabled:(BOOL)smartDialAdviceEnabled
{
    [UserDefaultsManager setObject:[NSNumber numberWithBool:smartDialAdviceEnabled] forKey:IS_SMART_DAIL_ADVICE];
    [UserDefaultsManager synchronize];
    if (smartDialAdviceEnabled) {
        [phoneNumberUtil_ setActiveProfile:[self smartDialProfileIDBySim]];
    }
}

// auto dial enabled
- (BOOL)isAutoDialEnabled
{
    return [UserDefaultsManager boolValueForKey:IS_AUTO_DAIL_IP];
}

- (void)setAutoDialEnabled:(BOOL)autoDialEnabled
{
    [UserDefaultsManager setObject:[NSNumber numberWithBool:autoDialEnabled] forKey:IS_AUTO_DAIL_IP];
    [UserDefaultsManager synchronize];
}

// roaming
- (BOOL)isRoaming
{
   return [UserDefaultsManager boolValueForKey:IS_SET_ROMING];
}

- (void)setRoaming:(BOOL)roaming
{
    [UserDefaultsManager setObject:[NSNumber numberWithBool:roaming] forKey:IS_SET_ROMING];
    [UserDefaultsManager synchronize];
    [phoneNumberUtil_ setRoaming:roaming];
}

// resident area code
- (NSString *)residentAreaCode
{
   return [UserDefaultsManager stringForKey:NUMBER_AREA_CODE];
}

- (void)setResidentAreaCode:(NSString *)tmp_area_code
{
    if(![tmp_area_code isEqualToString:[self residentAreaCode]]){
        [UserDefaultsManager setObject:tmp_area_code forKey:NUMBER_AREA_CODE];
        [UserDefaultsManager synchronize];
        SimNormalizedContactCacheChangeCommand *change = [[SimNormalizedContactCacheChangeCommand alloc]
                                                        initWithExecuteAction:^(){
                                                            [phoneNumberUtil_ setAreaCode:tmp_area_code];
                                                        }];
        [NSThread detachNewThreadSelector:@selector(onExecute) toTarget:change withObject:nil];
    }
}

// current carrier
- (NSString *)currentChinaCarrier
{
    NSString* chinaCarrier = [UserDefaultsManager stringForKey:CURRENT_CHINA_CARRIER];
    if (chinaCarrier && [chinaCarrier length] != 0) {
        return chinaCarrier;
    } else {
        NSString *carrierName = @"";
        NSString* str = [[DeviceSim sim] mccMnc];
        if ([str isEqualToString:@"46000"] ||
            [str isEqualToString:@"46002"] ||
            [str isEqualToString:@"46007"]) { // china mobile
            carrierName = @"China Mobile";
        } else if ([str isEqualToString:@"46001"] ||
                  [str isEqualToString:@"46006"]) { // china unicom
            carrierName = @"China Unicom";
        } else if ([str isEqualToString:@"46003"] ||
                  [str isEqualToString:@"46005"] ||
                  [str isEqualToString:@"46099"]) { // china telecom
            carrierName = @"China Telecom";
        }
        return carrierName;
    }
}

- (void)setCurrentChinaCarrier:(NSString *)currentChinaCarrier
{
    [UserDefaultsManager setObject:currentChinaCarrier forKey:CURRENT_CHINA_CARRIER];
    [UserDefaultsManager synchronize];
    if ([currentChinaCarrier isEqualToString:@"China Mobile"]) {
        [self setSimMnc:@"46000"];
        [self setNetworkMnc:@"46000"];
    } else if([currentChinaCarrier isEqualToString:@"China Unicom"]) {
        [self setSimMnc:@"46001"];
        [self setNetworkMnc:@"46001"];
    } else if([currentChinaCarrier isEqualToString:@"China Telecom"]) {
        [self setSimMnc:@"46003"];
        [self setNetworkMnc:@"46003"];
    }
}

- (void)setSimMncWithNonHeadingPlusCountryCode:(NSString *)countryCode
{
    NSString *mcc = [phoneNumberUtil_ getMccByCountryCodeWithLeadingPlus:[NSString stringWithFormat:@"+%@",countryCode]];
    NSString *mnc;
    if([mcc isEqualToString:@"310"] || [mcc isEqualToString:@"311"]) {
        mnc =  @"000";
    } else {
        mnc = @"00";
    }
    NSString *fullMnc = [NSString stringWithFormat:@"%@%@",mcc,mnc];
    self.simMnc = fullMnc;
    self.networkMnc = fullMnc;
}

// sim full mnc
- (NSString *)simMnc
{
    NSString *mnc = [UserDefaultsManager stringForKey:CURRENT_SIM_MNC];
    if ([mnc length] > 0) {
        return mnc; 
    } else {
        mnc = [[DeviceSim sim] mccMnc];
        if ([mnc length] > 0 && ![mnc hasPrefix:@"00"] && ![mnc hasPrefix:@"65535"]) {
            return mnc;
        } else {
            return [self mccMncByPreferredLanguage];
        }
    }
}

- (void)setSimMnc:(NSString *)mnc
{
    if (mnc == nil || [mnc length] == 0) {
        return;
    }
    
    NSString *currentSimMnc = [UserDefaultsManager stringForKey:CURRENT_SIM_MNC];
    if ([mnc isEqualToString:currentSimMnc]) {
        return;
    }
    
    [UserDefaultsManager setObject:mnc forKey:CURRENT_SIM_MNC];
    [UserDefaultsManager synchronize];
    
    SimNormalizedContactCacheChangeCommand *change = [[SimNormalizedContactCacheChangeCommand alloc]
                                                    initWithExecuteAction:^(){
                                                        [[OrlandoEngine instance] clearCityGroups];
                                                        [phoneNumberUtil_ setSimOperationCode:mnc];
                                                        [phoneNumberUtil_ setActiveProfile:[self smartDialProfileIDBySim]];
                                                    }];
    //make networkMnc synchronized with simMnc, since we cannot get network mnc now.
    [self setNetworkMnc:mnc];
    [NSThread detachNewThreadSelector:@selector(onExecute) toTarget:change withObject:nil];
    [SmartDailerSettingModel cacheIsChinaSim];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_CARRIER_CHANGED object:nil userInfo:nil];

}

// network full mnc
- (NSString *)networkMnc
{
    NSString *mnc = [UserDefaultsManager stringForKey:CURRENT_NETWORK_MNC];
    if ([mnc length] > 0) {
        return mnc;
    } else {
        mnc = [[DeviceSim sim] mccMnc];
        if ([mnc length] > 0 && ![mnc hasPrefix:@"00"]) {
            return mnc;
        } else {
            return [self mccMncByPreferredLanguage];
        }
    }
}

- (void)setNetworkMnc:(NSString *)mnc
{
    [UserDefaultsManager setObject:mnc forKey:CURRENT_NETWORK_MNC];
    [UserDefaultsManager synchronize];
    if ([mnc length] == 0) {
        mnc = [[DeviceSim sim] mccMnc];
    }
    [phoneNumberUtil_ setNetworkOperationCode:mnc];
}

- (NSString *)countryNameWithTwoCharsBySim
{
    return [phoneNumberUtil_ getCountryNameOf2Chars:[self simMnc]];
}

- (BOOL)isInternationalRoaming
{
    if ([self isRoaming]) {
        NSString *simCountry =[phoneNumberUtil_ getCountryNameOf2Chars:[self simMnc]];
        NSString *netCountry =[phoneNumberUtil_ getCountryNameOf2Chars:[self networkMnc]];
        if (![simCountry isEqualToString:netCountry]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)smartDialProfileIDBySim
{
    NSString *operationCode = [self simMnc];
    NSArray *profileArray = [phoneNumberUtil_ getProfileByOperCode:operationCode];
    if ([profileArray count] != 0) {
        return ((ProfileModel *)profileArray[0]).ID;
    }
    return -1;
}

- (NSArray *)smartDialProfileRulesBySim
{
    NSInteger profile_id = [self smartDialProfileIDBySim];
    return  [phoneNumberUtil_ getRulesByProfileId:profile_id];
}

// Helpers
- (void)reportEnabledVoipRulesToAnalyticManager
{
    if([SmartDailerSettingModel isChinaSim] && [self isSmartDialAdviceEnabled]) {
        NSArray* rules = [self smartDialProfileRulesBySim];
        for (RuleModel* r in rules) {
            if(r.isEnable) {
                ;
            }
        }
    }
}

- (NSString *)mccMncByPreferredLanguage
{
    NSString *mccmnc;
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *preferredLang = [languages objectAtIndex:0];
    if ([[preferredLang uppercaseString] isEqualToString:@"EN"]) {
        mccmnc = [[self countryMccByCountryNameOfTwoChars:[preferredLang uppercaseString]] stringByAppendingString:@"000"];
    } else {
        mccmnc = [[self countryMccByCountryNameOfTwoChars:[preferredLang uppercaseString]] stringByAppendingString:@"00"];
    }
	return mccmnc;
}

- (NSString *)countryMccByCountryNameOfTwoChars:(NSString *)countryName
{
	NSString *countyCodeOperationCode;
	if ([countryName isEqualToString:@"US"]||[countryName isEqualToString:@"EN"]) {
		countyCodeOperationCode=@"310";
	}else if ([countryName isEqualToString:@"CN"]||[countryName isEqualToString:@"ZH-HANS"]) {
		countyCodeOperationCode=@"460";
	}else if ([countryName isEqualToString:@"TW"]||[countryName isEqualToString:@"ZH-HANT"]){
		countyCodeOperationCode=@"466";
	}else if ([countryName isEqualToString:@"HK"]){
		countyCodeOperationCode=@"454";
	}else if ([countryName isEqualToString:@"MO"]){
		countyCodeOperationCode=@"455";
	}else if ([countryName isEqualToString:@"GB"]||[countryName isEqualToString:@"EN-GB"]){
		countyCodeOperationCode=@"234";
	}else if ([countryName isEqualToString:@"FR"]){
		countyCodeOperationCode=@"208";
	}else if ([countryName isEqualToString:@"DE"]){
		countyCodeOperationCode=@"262";
	}else if ([countryName isEqualToString:@"SE"]){
		countyCodeOperationCode=@"240";
	}else if ([countryName isEqualToString:@"FI"]){
		countyCodeOperationCode=@"244";
	}else if ([countryName isEqualToString:@"DK"]){
		countyCodeOperationCode=@"238";
	}else if ([countryName isEqualToString:@"ES"]){
		countyCodeOperationCode=@"214";
	}else if ([countryName isEqualToString:@"IT"]){
		countyCodeOperationCode=@"222";
	}else if ([countryName isEqualToString:@"PT"]||[countryName isEqualToString:@"PT-PT"]){
		countyCodeOperationCode=@"268";
	}else if ([countryName isEqualToString:@"NO"]){
		countyCodeOperationCode=@"242";
	}else if ([countryName isEqualToString:@"BE"]){
		countyCodeOperationCode=@"206";
	}else if ([countryName isEqualToString:@"AR"]){
		countyCodeOperationCode=@"722";
	}else if ([countryName isEqualToString:@"BR"]){
		countyCodeOperationCode=@"724";
	}else if ([countryName isEqualToString:@"GR"]){
		countyCodeOperationCode=@"202";
	}else if ([countryName isEqualToString:@"CH"]){
		countyCodeOperationCode=@"228";
	}else if ([countryName isEqualToString:@"RU"]){
		countyCodeOperationCode=@"250";
	}else {
		countyCodeOperationCode=@"";
	}
	return countyCodeOperationCode;
}

@end
