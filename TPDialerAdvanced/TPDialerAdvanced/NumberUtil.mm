//
//  NumberUtil.mm
//  TPDialerAdvanced
//
//  Created by Xu Elfe on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NumberUtil.h"
#include "Option.h"
#include "Configs.h"
#include "IPhoneNumber.h"
#include "IRules.h"
#include "ICityGroup.h"
#include "def.h"
#include <list>
#include <fcntl.h>
#include "TPDialerAdvanced.h"
#import "AdvancedSettingKeys.h"
#import "Util.h"
#import "ContactEngine.h"
#import "AdvancedSettingUtility.h"
#import <sqlite3.h>

@implementation NumberUtil

using namespace std;
using namespace orlando;

static Option *option;
static FILE* fd;
static BOOL isNumberAttrInitialized;


+ (void)initialize {
    option = OptionManager::getInst()->getOption();
    [self initNetworkAndSim];
    [self initAttr];
}

//号码归一化
+(NSString *)getNormalizedNumber:(NSString *)number
{
    return [self getNormalizedNumberPrivate:number accordingToNetwork:NO];
}

+(NSString *)getNormalizedNumberAccordingNetwork:(NSString *)number
{
    return [self getNormalizedNumberPrivate:number accordingToNetwork:YES];
}

+(NSString *)getNormalizedNumberPrivate:(NSString *)number accordingToNetwork:(BOOL)accordingToNetwork
{
    cootek_log_function;
	if (number == nil || [number length] == 0) {
		return @"";
	}
    
    if(!isNumberAttrInitialized) {
        cootek_log(@"Error: the number attr is not initialized.");
        return @"";
    }
    
    number = [NumberUtil removeFormatChars:number];
    
	IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],accordingToNetwork);
	string temp=inumber->getNormalizedNumber();
	NSString *international=[NSString stringWithUTF8String:temp.c_str()];
    
    cootek_log(@"%@", international);
    return international;
}


+(NSString *)getOriginalNumber:(NSString *)number{
    cootek_log_function;
    
    if(!isNumberAttrInitialized) {
        cootek_log(@"Error: the number attr is not initialized.");
        return @"";
    }
    
    IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],false);
    string temp=inumber->getLocaNumberWithoutAreaCode(); 
    return [NSString stringWithUTF8String:temp.c_str()];
}

+(NSString *)getNumberAttr:(NSString *)rawNumber withType:(NSInteger)type
{
    cootek_log_function;
	if (!rawNumber||[rawNumber isEqualToString:@""]) {
		return @"";		
	}
    
    if(!isNumberAttrInitialized) {
        cootek_log(@"Error: the number attr is not initialized.");
        return @"";
    }
    
    IPhoneNumber *number= PhoneNumberFactory::Create((string)[rawNumber UTF8String],true);
	NSString *attr = [NSString stringWithUTF8String:number->getAttr(type).c_str()];
    attr = [attr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([attr isEqualToString:@"Local"] || [attr isEqualToString:@"Local service"]) {
        return NSLocalizedStringFromTable(attr, @"TPDialerAdvanced", @"");
    } else {
        return attr;
    }
}

//初始化号码归属地
+(void)initAttr
{
    cootek_log_function;
	NSString* filePath = [AdvancedSettingUtility numberAttributePath];
    if(filePath != nil) {
        fd = fopen([filePath UTF8String],"r");
        if(fd != NULL) {
            option ->initAttrImage((void *)fd);
            isNumberAttrInitialized = YES;
        } else {
            NSLog(@"there is no attr image available.");
        }
    }
}

//初始化网络
+(void)initNetworkAndSim{
    cootek_log_function;
	NSString* simOpearteCode = [TPDialerAdvanced querySetting:ADVANCED_SETTING_SIM_OPERATOR_CODE];
    if(simOpearteCode != nil && [simOpearteCode length] > 0) {
        OperatorInfo sim; 
        sim.OperatorCode  = (string)[simOpearteCode UTF8String];
        option->setSIM(sim);
    }
    
    NSString* netOpearteCode = [TPDialerAdvanced querySetting:ADVANCED_SETTING_NETWORK_OPERATOR_CODE];
    if(netOpearteCode != nil && [netOpearteCode length] > 0) {
        OperatorInfo network; 
        network.OperatorCode  = (string)[netOpearteCode UTF8String];
        option->setNetwork(network);
    }
}

+(void)deinitAttr{
    cootek_log_function;
    
    if(!isNumberAttrInitialized || fd == NULL) {
        cootek_log(@"Error: the number attr is not initialized.");
        return;
    }
    
	Option* option = OptionManager::getInst()->getOption();
	option->deinitAttrImage();
	fclose(fd);
	fd = NULL;
}

// remove format chars in the number.
+ (NSString*) removeFormatChars:(NSString*) number {
    cootek_log_function;
    NSArray* ignoreChars = [NSArray arrayWithObjects:@"-", @" ", @"(", @")", nil];
    NSString* result = number;
    for(NSString* toIgnore in ignoreChars) {
        result = [result stringByReplacingOccurrencesOfString:toIgnore withString:@""];
    }
    return result;
}

// whether a string is a valid phone number.
+ (BOOL) isPhoneNumber:(NSString*) text {
    cootek_log_function;
    NSCharacterSet *alphaNums = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
    return [alphaNums isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:text]];
}

@end

