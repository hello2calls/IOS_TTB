//
//  MagicUltis.h
//  Untitled
//
//  Created by Alice on 11-8-11.
//  Copyright 2011 CooTek. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DialMethordModel.h"
#import "ProfileModel.h"
#import "RuleModel.h"
#import "SmartDailerSettingModel.h"
#import "SearchResultModel.h"

@interface MagicUltis : NSObject

+ (MagicUltis *)instance;

+ (NSString *)chineseFullPing:(NSString *)chinese;

- (void)setupOrlandoWithSimMnc:(NSString *)simMnc
                    networkMnc:(NSString *)networkMnc
              residentAreaCode:(NSString *)residentAreaCode
                       roaming:(BOOL)roaming;

- (BOOL)isInNoSuggestionList:(NSString *)num;
- (NSString *)getSimCountryName;
- (NSString *)getAttrAreacodeByNumber:(NSString *)number;
- (NSString *)getCountryCodeByMnc:(NSString *)mnc;
- (NSString *)getMainOperateByMnc:(NSString *)mnc;
- (NSString *)getMccByCountryCode:(NSString *)countryCode;

//号码归一化
-(NSString *)getNormalizedNumber:(NSString *)number;
- (NSString *)getCNnormalNumber:(NSString *)number;
-(NSString *)numberAfterRemoveAreaCode:(NSString *)number;
-(NSString *)getNormalizedNumberAccordingNetwork:(NSString *)number;
-(NSString *)getOriginalNumber:(NSString *)number;
//获取电话号码的归属地
-(NSString *)getNumberAttr:(NSString *)rawNumber withType:(NSInteger)type;
-(NSString *)getNumberAttr_WithOutConsidertingPersonExist:(NSString *)rawNumber withType:(NSInteger)type;

//获取推荐号码列表
-(NSArray *)getSuggestionsNumber:(NSString *)number
                        autoDial:(BOOL)autoDial
                 smartDialAdvice:(BOOL)smartDialAdvice
                         roaming:(BOOL)roaming
            internationalRoaming:(BOOL)internationalRoaming;

//拿电话号码规则列表
-(SearchResultModel *)getRulelist:(NSString *)number withRoming:(BOOL)is_roming;
-(NSArray *)getAutoCondinatelist:(NSArray *)all_rule_list withSmart:(BOOL)is_smart;
-(NSArray *)getAutoShowlist:(NSArray *)all_rule_list withSmart:(BOOL)is_smart withOriginalNumber:(NSString *)originalnumber;

//获取当前活动的profile
-(ProfileModel *)getActiveProfile;
//设置当前活动的profile
-(void)setActiveProfile:(NSInteger)profile_id;
-(ProfileModel *)getProfile:(NSInteger)profile_id;
//根据运营商拿profile
-(NSArray *)getProfileByOperCode:(NSString *)opera_code;
//根据国家号拿profile
-(NSArray *)getProfileByCountryCode:(NSString *)country_code;
//拿到profile的规则列表
-(NSArray *)getProfileByRule:(NSInteger)profile_id;
//添加profile
-(void)addProfile:(ProfileModel *)profile;
//删除profile
-(void)removeProfile:(ProfileModel *)profile;
//setting
- (void)setAreaCode:(NSString *)areaCode;
- (void)setRoaming:(BOOL)is_roaming;
- (BOOL)getRoaming;
- (NSString *)getAreaCountryInfo;
- (void)setSimOperationCode:(NSString *)simcode;
- (void)setNetworkOperationCode:(NSString *)networkcode;
@end
