//
//  NumberUtil.h
//  TPDialerAdvanced
//
//  Created by Xu Elfe on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

@interface NumberUtil : NSObject {
}

//号码归一化 
+(NSString *)getNormalizedNumber:(NSString *)number;
//
+(NSString *)getNormalizedNumberAccordingNetwork:(NSString *)number;

+(NSString *)getOriginalNumber:(NSString *)number;

//获取电话号码的归属地
//-(NSString *)getNumberAttrWithPersonInfo:(NSString *)rawNumber withType:(NSInteger)type;
+(NSString *)getNumberAttr:(NSString *)rawNumber withType:(NSInteger)type;

//private:
//初始化号码归属地
+(void)initAttr;
+(void)initNetworkAndSim;

+ (NSString*) removeFormatChars:(NSString*) number;
+ (BOOL) isPhoneNumber:(NSString*) text;

@end

