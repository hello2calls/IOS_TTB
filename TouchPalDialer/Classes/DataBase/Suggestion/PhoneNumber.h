//
//  PhoneNumber.h
//  TouchDataAcess
//
//  Created by Alice on 11-9-5.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "ProfileModel.h"

#define attr_type_normal 1
#define attr_type_short 3

@interface PhoneNumber : NSObject
//获取实例
+ (PhoneNumber *)sharedInstance;

+ (NSString *)getNormalizedNumber:(NSString *)number;

+ (NSString *)getCNnormalNumber:(NSString *)number;

+ (void)setupOrlandoWithSimMnc:(NSString *)simMnc
                    networkMnc:(NSString *)networkMnc
              residentAreaCode:(NSString *)residentAreaCode
                       roaming:(BOOL)roaming;

//获取推荐号码列表
- (NSArray *)getSuggestionsNumber:(NSString *)number
                         autoDial:(BOOL)autoDial
                  smartDialAdvice:(BOOL)smartDialAdvice
                          roaming:(BOOL)roaming
             internationalRoaming:(BOOL)internationalRoaming;

//获取归一化电话号码
- (NSString *)getNormalizedNumber:(NSString *)rawNumber;

- (NSString *)getNormalizedNumberAccordingNetwork:(NSString *)rawNumber;

- (NSString *)getAttrAreacodeByNumber:(NSString *)number;

- (NSString *)getOriginalNumber:(NSString *)number;

//获取电话号码的归属地
- (NSString *)getNumberAttribution:(NSString *)rawNumber;

- (NSString *)getNumberAttribution:(NSString *)rawNumber
                          withType:(NSInteger)type;
- (NSString *)getNumberAttribution_WithOutConsideringPersonExist:(NSString *)rawNumber
                                                        withType:(NSInteger)type;
//获取国家代号
- (NSString *)getSimCountryName;

- (NSString *)getCountryNameOf2Chars:(NSString *)mnc;

- (NSString *)getMainOperateByMnc:(NSString *)mnc;

- (NSString *)getMccByCountryCodeWithLeadingPlus:(NSString *)countryCode;

//获取当前活动的profile
-(ProfileModel *)getActiveProfile;

//设置当前活动的profile
-(void)setActiveProfile:(NSInteger)profile_id;

-(ProfileModel *)getProfile:(NSInteger)profile_id;

//根据运营商拿profile
-(NSArray *)getProfileByOperCode:(NSString *)opera_code;

//拿到profile的规则列表
-(NSArray *)getRulesByProfileId:(NSInteger)profile_id;

//添加profile
-(void)addProfile:(ProfileModel *)profile;

//删除profile
-(void)removeProfile:(ProfileModel *)profile;

//setting
- (void)setAreaCode:(NSString *)areaCode;

- (void)setRoaming:(BOOL)roaming;

- (BOOL)getRoaming;

- (NSString *)getAreaCountryInfo;

- (void)setSimOperationCode:(NSString *)simcode;

- (void)setNetworkOperationCode:(NSString *)networkcode;

- (NSString *)getCNnormalNumber:(NSString *)number;

- (BOOL)isCNSim;

@end
