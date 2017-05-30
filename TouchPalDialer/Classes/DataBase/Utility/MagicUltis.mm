//
//  MagicUltis.m
//  Untitled
//
//  Created by Alice on 11-8-11.
//  Copyright 2011 CooTek. All rights reserved.
//
#include "def.h"
#include "Option.h"
#include "Configs.h"
#include "IPhoneNumber.h"
#include "IRules.h"
#include "ICityGroup.h"
#include <list>
#include <fcntl.h>
#include "Utils.h"

#import "MagicUltis.h"
#import "DeviceSim.h"
#import "ConvertStructUltis.h"
#import "Person.h"
#import "NumberPersonMappingModel.h"
#import "AdvancedCalllog.h"
#import "UserDefaultsManager.h"
#import "NSString+PhoneNumber.h"
#import "CStringUtils.h"

using namespace std;
using namespace orlando;

static MagicUltis * SharedInstance_ = nil;
static int cmcc_id_g3 = 46000004;
static int unicom_id_wo3g = 46000104;
static int ctc_id_2 = 46000302;

@interface MagicUltis () {
    FILE *fd;
    NSArray *noSuggestEqual;
    NSArray *noSuggestStart;
    Option *option;
}
@end

@implementation MagicUltis

+ (NSString *)chineseFullPing:(NSString *)chinese {
    if (chinese.length == 0) {
        return nil;
    }
    u16string str = CStringUtils::nsstr2u16str(chinese);
    int len = str.size();
    u16string result;
    for(int i = 0; i < len; ++i){
        u16char_t c = str[i];
        if (Utils::isChineseChar(c)) {
            u16string word;
            Utils::getPinyinByCHS(c, word);
            int wordLen = word.size();
            for(int j = 0; j < wordLen; ++j) {
                result.push_back(word[j]);
            }
        } else {
            result.push_back(c);
        }
    }
    return CStringUtils::u16str2nsstr(result);
}

+ (void)initialize
{
    SharedInstance_ = [[MagicUltis alloc] init];
}

+ (MagicUltis*)instance
{
	return SharedInstance_;
}

- (void)setupOrlandoWithSimMnc:(NSString *)simMnc
                    networkMnc:(NSString *)networkMnc
              residentAreaCode:(NSString *)residentAreaCode
                       roaming:(BOOL)roaming
{
    cootek_log(@"begin setup orlando************");
    option = OptionManager::getInst()->getOption();
    // initNetworkAndSim;
    OperatorInfo sim;
	OperatorInfo network;
	
	//获取SIM
    NSString *areaCode = residentAreaCode;
	if ([areaCode length]>0) {
		sim.AreaCode = (string)[areaCode UTF8String];
	}
    
	NSString *operateCode = simMnc;
	cootek_log(@">>>>>>>>>>>>>SIM OperationCode=%@",operateCode);
    sim.OperatorCode=(string)[operateCode UTF8String];
    
    //获取网络
	NSString *netOper = networkMnc;
	cootek_log(@">>>>>>>>>>>>>netWorkOperationCode=%@",netOper);
	string netOperatorCode = (string)[netOper UTF8String];
	network.OperatorCode = netOperatorCode;
	//设置
	option->setSIM(sim);
	option->setNetwork(network);
    option->setRoaming(roaming);
    
	PhoneNumberFactory::ClearCache();
    
    [AdvancedCalllog addAdvancedSetting:operateCode forKey:ADVANCED_SETTING_SIM_OPERATOR_CODE];
    [AdvancedCalllog addAdvancedSetting:netOper forKey:ADVANCED_SETTING_NETWORK_OPERATOR_CODE];
    
    //init 号码归属地
    [self initAttr];
    
    //init Profile
    [self setupInternalProfile];
    [self setupProfileCustom];
    [self setupProfileBrand];
    
    noSuggestEqual = [[NSArray alloc] initWithObjects:@"13800138000",@"13800100166",@"13800100309",nil];
    noSuggestStart = [[NSArray alloc] initWithObjects:@"1258", @"12520", @"10193", @"11808",
                      @"1259", @"172", @"179", @"197", @"200", @"300", @"400", @"600", @"700", @"800", nil];
    
    
    NSArray* profiles = [[MagicUltis instance] getProfileByOperCode:simMnc];
    if ([profiles count] != 0) {
        NSInteger profileId = ((ProfileModel *)profiles[0]).ID;
        [self setActiveProfile:profileId];
    }
    cootek_log(@"end setup orlando************");
}

-(BOOL)isInNoSuggestionList:(NSString *)num
{
    if([num length]<7)
        return true;
    for(int i=0;i<[noSuggestEqual count];i++)
    {
        if([num isEqualToString:[noSuggestEqual objectAtIndex:i]])
            return true;
    }
    for(int i=0;i<[noSuggestStart count];i++)
    {
        if([num hasPrefix:[noSuggestStart objectAtIndex:i]])
            return true;
    }
    return false;
}

//拿电话号码规则列表
-(SearchResultModel *)getRulelist:(NSString *)number withRoming:(BOOL)is_roming
{
    if (!number||[number length] == 0) {
		return nil;
	}
	IPhoneNumber *num = PhoneNumberFactory::Create((string)[number UTF8String],is_roming);
	vector<IDialRule*> rules;
	
	NSMutableArray *rule_list=[NSMutableArray arrayWithCapacity:1];
	ProfileManager::getInst()->getSuggestions(num, rules);
	int sugg_list_count=(int)rules.size();
	
	for (int i=0; i<sugg_list_count; i++) {
        RuleModel *m_rule = ConvertStructUltis::setRuleModel(rules[i]);
        m_rule.number = [NSString stringWithUTF8String:rules[i]->getDialString(num,true).c_str()];
        IRuleProfile * profile = NULL;
        switch (m_rule.source) {
            case  DialRuleSource::INTERNAL:
                profile = ProfileManager::getInst()->getProfileInternal();
                break;
            case DialRuleSource::CUSTOM:
                profile = ProfileManager::getInst()->getProfileCustom();
                break;
            default:
                profile = ProfileManager::getInst()->getActiveProfile();
                break;
        }
        m_rule.key = [NSString stringWithUTF8String:rules[i]->getKey(profile).c_str()];
        [rule_list addObject:m_rule];
	}
    SearchResultModel *ruleResult = [[SearchResultModel alloc] init];
    ruleResult.searchKey =  [NSString stringWithUTF8String:num->getNormalizedNumber().c_str()];
    ruleResult.searchResults =  rule_list;
	rules.clear();
    return ruleResult;
}

//获取推荐号码列表
-(NSArray *)getSuggestionsNumber:(NSString *)number
                        autoDial:(BOOL)autoDial
                 smartDialAdvice:(BOOL)smartDialAdvice
                         roaming:(BOOL)roaming
            internationalRoaming:(BOOL)internationalRoaming
{
    if (number == nil || [number length] == 0) {
        return nil;
    }
    
    //处理紧急号码
    if([self isInNoSuggestionList:number]) {
        return  nil;
    }
    
    //是否开启智能拨号规则
    if (!smartDialAdvice) {
        return nil;
    }
    
    SearchResultModel *all_rule_object = [self getRulelist:number withRoming:roaming];
    if ([all_rule_object.searchKey hasPrefix:@"+"]) {
        NSMutableArray *all_rule_list = all_rule_object.searchResults;
        NSArray *condinate_list = [self getAutoCondinatelist:all_rule_list withSmart:YES];
        int count = [condinate_list count];
        if (!roaming && count == 0) {
            return nil;
        }
        if (count == 1 && autoDial && !internationalRoaming) {
            return condinate_list;
        }
        //if in roaming state, the number being called likely to be the number that is in in the area of SIM area
        if (roaming) {
            SearchResultModel *all_rule_object_book = [self getRulelist:number withRoming:NO];
            if ([all_rule_object.searchKey isEqualToString:all_rule_object_book.searchKey] && count == 0) {
                return nil;
            }
            if (all_rule_object_book.searchResults&&[all_rule_object_book.searchResults count]>0) {
                [all_rule_list addObjectsFromArray:all_rule_object_book.searchResults];
            }
        }
        return [self getAutoShowlist:all_rule_list withSmart:YES withOriginalNumber:number];
    } else {
        if (roaming) {
            SearchResultModel *all_rule_object_book = [self getRulelist:number withRoming:NO];
            if ([all_rule_object_book.searchKey hasPrefix:@"+"]) {
                NSMutableArray *all_rule_list = all_rule_object_book.searchResults;
                return [self getAutoShowlist:all_rule_list withSmart:YES withOriginalNumber:number];
            }
        }
    }
    
	return nil;
}

-(NSArray *)getAutoShowlist:(NSArray *)all_rule_list
                  withSmart:(BOOL)is_smart
         withOriginalNumber:(NSString *)originalnumber
{
    BOOL start_with_add = NO;
    if ([originalnumber hasPrefix:@"+"]) {
        start_with_add = YES;
    }
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *number_list = [NSMutableArray arrayWithCapacity:1];
    if (all_rule_list) {
        for (RuleModel *rule in all_rule_list) {
            BOOL c1 = rule.source != DialRuleSource::INTERNAL &&
                      [UserDefaultsManager boolValueForKey:rule.key defaultValue:rule.isEnable];
            BOOL c2 = is_smart &&
                      rule.source == DialRuleSource::INTERNAL &&
                      ![rule.number.digitNumber isEqualToString:originalnumber.digitNumber];
            BOOL c3 = [rule.name isEqualToString:@"Direct Call"];
            if (c1||c2||c3) {
                if (![number_list containsObject:rule.number]) {
                    if (start_with_add == YES && rule.dailruleType == DialRuleType::DOMESTIC) {
                        continue;//原号码时以＋开头的，不加国内电话号码
                    }
                    [list addObject:rule];
                    [number_list addObject:rule.number];
                }
            }
        }
    }
    return list;
}

-(NSArray *)getAutoCondinatelist:(NSArray *)all_rule_list withSmart:(BOOL)is_smart
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *number_list = [NSMutableArray arrayWithCapacity:1];
    if (all_rule_list) {
        for (RuleModel *rule in all_rule_list) {
            if ((is_smart && rule.source != DialRuleSource::INTERNAL)
                && [UserDefaultsManager boolValueForKey:rule.key defaultValue:rule.isEnable]) {
                if (![number_list containsObject:rule.number]) {
                    [list addObject:rule];
                    [number_list addObject:rule.number];
                }
            }
        }
    }
    return list;
}

//根据运营商拿profile
-(NSArray *)getProfileByOperCode:(NSString *)opera_code
{
	NSMutableArray *oper_profile_list=[[NSMutableArray alloc] init];
	vector<IRuleProfile*> profiles;
	ProfileManager::getInst()->getProfilesByOperateCode((string)[opera_code UTF8String],profiles);
	int profile_count=(int)profiles.size();
	for (int i=0; i<profile_count; i++) {
		IRuleProfile *temp=profiles[i];
		ProfileModel *profile=ConvertStructUltis::setProfileModel(temp);
		[oper_profile_list addObject:profile];
	}
    return oper_profile_list;
}

//根据国家号拿profile
-(NSArray *)getProfileByCountryCode:(NSString *)country_code
{
	NSMutableArray *country_profile_list=[[NSMutableArray alloc] init];
	vector<IRuleProfile*> profiles;
	ProfileManager::getInst()->getProfileByCountry([country_code intValue],profiles);
	int profile_count=(int)profiles.size();
	for (int i=0; i<profile_count; i++) {
		IRuleProfile *temp=profiles[i];
		ProfileModel *profile=ConvertStructUltis::setProfileModel(temp);
		[country_profile_list addObject:profile];
	}
    return country_profile_list;
}

//号码归一化
-(NSString *)getNormalizedNumber:(NSString *)number
{
	if (!number) {
		return @"";
	}
    number = [number digitNumber];
	IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],false);
	string temp=inumber->getNormalizedNumber();
	NSString *international=[NSString stringWithUTF8String:temp.c_str()];
	return international;
}

- (NSString *)getCNnormalNumber:(NSString *)number {
    if (number.length==0) {
        return nil;
    }
    number = [number mutableCopy];
    number = [number digitNumber];
    IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],false);
    string temp = inumber->getCNnormalNumber();
    return [NSString stringWithUTF8String:temp.c_str()];
}

-(NSString *)numberAfterRemoveAreaCode:(NSString *)number
{
	if (!number) {
		return @"";
	}
    number = [number digitNumber];
	IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],false);
	string temp=inumber->getLocaNumberWithoutAreaCode();
	NSString *shortNumber=[NSString stringWithUTF8String:temp.c_str()];
	return shortNumber;
}

-(NSString *)getNormalizedNumberAccordingNetwork:(NSString *)number
{
	if (!number) {
		return @"";
	}
    number = [number digitNumber];
	IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],true);
	string temp=inumber->getNormalizedNumberWithoutAreacode();
	NSString *international=[NSString stringWithUTF8String:temp.c_str()];
	return international;
}

-(NSString *)getOriginalNumber:(NSString *)number
{
    number = [number digitNumber];
    IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],false);
    if ( [number hasPrefix:@"400"] || [number hasPrefix:@"800"] ){
        NSString *normalnumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [number length])];
        return normalnumber;
    }
    string temp=inumber->getLocaNumberWithoutAreaCode();
    return [NSString stringWithUTF8String:temp.c_str()];
}

//获取电话号码的长归属地
-(NSString *)getNumberAttr:(NSString *)rawNumber withType:(NSInteger)type
{
	rawNumber = [rawNumber digitNumber];
    if (!rawNumber||[rawNumber isEqualToString:@""]) {
		return @"";
	}
    //to decide whether the number is in Address book
    Boolean in_Address_book = false;
    NSInteger personID =[NumberPersonMappingModel queryContactIDByNumber:rawNumber];
    if(personID>0){
        in_Address_book = true;
    }
    IPhoneNumber *number= PhoneNumberFactory::Create((string)[rawNumber UTF8String],!in_Address_book);
	NSString *attr = [NSString stringWithUTF8String:number->getAttr(type).c_str()];
    attr = [attr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return attr;
}

-(NSString *)getNumberAttr_WithOutConsidertingPersonExist:(NSString *)rawNumber withType:(NSInteger)type
{
	rawNumber = [rawNumber digitNumber];
    if (!rawNumber||[rawNumber isEqualToString:@""]) {
		return @"";
	}
    IPhoneNumber *number= PhoneNumberFactory::Create((string)[rawNumber UTF8String],true);
	NSString *attr = [NSString stringWithUTF8String:number->getAttr(type).c_str()];
    attr = [attr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return attr;
}

//拿到profile的规则列表
-(NSArray *)getProfileByRule:(NSInteger)profile_id
{
    if (profile_id > 0) {
        NSMutableArray *rules =[NSMutableArray arrayWithCapacity:1];
        IRuleProfile *profile = ProfileManager::getInst()->getProfileById(profile_id);
        if(profile == NULL){return nil;}
        ProfileModel *m_profile = ConvertStructUltis::setProfileModel(profile);
        NSArray *rule_list = m_profile.rule_list;
        int ruleCount = [rule_list count];
        for (int i=0; i<ruleCount; i++) {
            int rule_id = [[rule_list objectAtIndex:i] intValue];
            IDialRule* tmpRule = profile->getRuleById(rule_id);
            RuleModel *rule =ConvertStructUltis::setRuleModel(tmpRule);
            rule.key = [NSString stringWithUTF8String:tmpRule->getKey(profile).c_str()];
            //[UserDefaultItemList addUserDefaultItem:[UserDefaultItem itemWithKey:rule.key boolValue:rule.isEnable]];
            [rules addObject:rule];
        }
        return rules;
    }
    return nil;
}

//根据ID获取profile
-(ProfileModel *)getProfile:(NSInteger)profile_id
{
    if (profile_id > 0) {
        IRuleProfile *profile = ProfileManager::getInst()->getProfileById(profile_id);
        if (profile == NULL) {
            return nil;
        }
        return ConvertStructUltis::setProfileModel(profile);
    }
    return nil;
}

//获取当前活动的profile
-(ProfileModel *)getActiveProfile
{
    IRuleProfile *profile = ProfileManager::getInst()->getActiveProfile();
    return ConvertStructUltis::setProfileModel(profile);
}
//设置当前活动的profile
-(void)setActiveProfile:(NSInteger)profile_id
{
    ProfileManager::getInst()->setActiveProfile(profile_id);
}

- (NSString *)getSimCountryName
{
    OperatorInfo sim = option->getSIM();
    string countryC = sim.Country;
    NSString *country = [NSString stringWithUTF8String:countryC.c_str()];
    return [country lowercaseString];
}

//添加profile
-(void)addProfile:(ProfileModel *)profile
{
	IRuleProfile *m_profile=ConvertStructUltis::setRuleProfile(profile);
	ProfileManager::getInst()->addProfile(m_profile);
}

//删除profile
-(void)removeProfile:(ProfileModel *)profile
{
	IRuleProfile *m_profile=ConvertStructUltis::setRuleProfile(profile);
	ProfileManager::getInst()->removeProfile(m_profile);
}

//初始化号码归属地
- (void)initAttr
{
	NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"numberAttr.img"];
	fd = fopen([filePath UTF8String],"r");
	option ->initAttrImage((void *)fd);
}

- (void)setAreaCode:(NSString *)areaCode
{
    OperatorInfo sim = option->getSIM();
    if ([areaCode length] > 0) {
        sim.AreaCode = (string)[areaCode UTF8String];
    }else{
        sim.AreaCode = (string)[@"" UTF8String];
    }
    option->setSIM(sim);
    PhoneNumberFactory::ClearCache();
}

- (void)setRoaming:(BOOL)is_roaming
{
    option->setRoaming(is_roaming);
    PhoneNumberFactory::ClearCache();
}
- (BOOL)getRoaming
{
    return option->isRoaming();
}

- (NSString *)getAreaCountryInfo
{
    OperatorInfo sim = option->getSIM();
    string countryC = sim.Country;
    IPhoneRule *rule = PhoneRuleManager::getInst()->getPhoneRule(countryC);
    string countryCodeC = rule->getCountryCode();
    NSString *countryCode = [NSString stringWithUTF8String:countryCodeC.c_str()];
    NSString *country = [NSString stringWithUTF8String:countryC.c_str()];
    if ([countryCode length] > 0) {
        return [NSString stringWithFormat:@"%@(+%@)",country,countryCode];
    }else{
        return country;
    }
}

- (NSString *)getMccByCountryCode:(NSString *)countryCode
{
    IPhoneRule *rule = PhoneRuleManager::getInst()->getPhoneRuleFromNormailzedNumber([countryCode UTF8String]);
    string countryCodeC = rule->getMainMCC();
    NSString *mcc = [NSString stringWithUTF8String:countryCodeC.c_str()];
    return mcc;
}

- (NSString *)getCountryCodeByMnc:(NSString *)mnc
{
    IPhoneRule *rule = PhoneRuleManager::getInst()->getPhoneRuleFromMNC([mnc UTF8String]);
    string countryCodeC = rule->getCountryName();
    NSString *countryCode = [NSString stringWithUTF8String:countryCodeC.c_str()];
    return countryCode;
}

- (NSString *)getAttrAreacodeByNumber:(NSString *)number
{
	if (!number) {
		return @"";
	}
	IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],false);
	string temp=inumber->getAttrMappedAreaCode();
	NSString *areacode=[NSString stringWithUTF8String:temp.c_str()];
	return areacode;
}

- (NSString *)getMainOperateByMnc:(NSString *)mnc
{
    IPhoneRule *rule = PhoneRuleManager::getInst()->getPhoneRuleFromMNC([mnc UTF8String]);
    string operateCodeC = rule->getMainOperateCode([mnc UTF8String]);
    NSString *operateCode = [NSString stringWithUTF8String:operateCodeC.c_str()];
    return operateCode;
}

- (void)setSimOperationCode:(NSString *)simcode
{
    if ([simcode length]>0) {
        OperatorInfo sim = option->getSIM();
        sim.OperatorCode = (string)[simcode UTF8String];
        //设置
        option->setSIM(sim);
        PhoneNumberFactory::ClearCache();
        [AdvancedCalllog addAdvancedSetting:simcode forKey:ADVANCED_SETTING_SIM_OPERATOR_CODE];
    }
}

- (void)setNetworkOperationCode:(NSString *)networkcode
{
    if ([networkcode length]>0) {
        OperatorInfo network = option->getNetwork();
        network.OperatorCode = (string)[networkcode UTF8String];
        //设置
        option->setNetwork(network);
        [AdvancedCalllog addAdvancedSetting:networkcode forKey:ADVANCED_SETTING_NETWORK_OPERATOR_CODE];
    }else{
        OperatorInfo sim = option->getSIM();
        option->setNetwork(sim);
    }
    PhoneNumberFactory::ClearCache();
}

//初始化内部拨号
-(void)setupInternalProfile
{
	//创建profile
	ProfileMeta* meta = ProfileManager::getInst()->createMeta("Default", "Generic", "Internal profile", "Stony");
	IRuleProfile* profile = ProfileManager::getInst()->createProfile(meta);
	//profile规则1－直接拨号
	int id = 1;
	IDialMethod* method = ProfileManager::getInst()->createMethod("", "{ORIGINMAINPART}");
    IDialRule* rule = ProfileManager::getInst()->createRule("Direct Call", "Direct Call", Roaming::ROAMING_ANY, Destination::DESTINATION_ANY);
	rule->setDialMethod(method);
	rule->setType(DialRuleType::DIRECT);
	rule->setId(IRuleProfile::INTERNAL_RULE_DIRECT_DIAL);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
	//profile规则2－国内电话格式
	method = ProfileManager::getInst()->createMethod("", "{NATIONAL}");
	rule = ProfileManager::getInst()->createRule("Domestic Call", "Domestic Call", Roaming::ROAMING_DOMESTIC_AND_HOME, Destination::DESTINATION_DOMESTIC);
	rule->setDialMethod(method);
	rule->setType(DialRuleType::DOMESTIC);
	rule->setId(IRuleProfile::INTERNAL_RULE_DOMESTIC_CALL);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    //profile规则3-国际电话格式
	method = ProfileManager::getInst()->createMethod("", "{INTERNATIONAL}");
	rule = ProfileManager::getInst()->createRule("IDD Call", "IDD Call", Roaming::ROAMING_ANY, Destination::DESTINATION_ANY);
	rule->setDialMethod(method);
	rule->setType(DialRuleType::E164);
	rule->setId(IRuleProfile::INTERNAL_RULE_INTERNATIONAL_CALL);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    //添加profile
	profile->setId(IRuleProfile::ID_INTERNAL);
	ProfileManager::getInst()->addProfile(profile);
}

//初始化自定义profile
-(void)setupProfileCustom
{
	//创建自定义profile
	ProfileMeta* meta = ProfileManager::getInst()->createMeta("Custom", "Generic", "Custom profile", "Stony");
	IRuleProfile* profile = ProfileManager::getInst()->createProfile(meta);
	
	//初始化自定义profile的规则
	
	//添加profile
	profile->setId(IRuleProfile::ID_CUSTOM);
	ProfileManager::getInst()->addProfile(profile);
}

//初始化品牌运营商的profile
-(void)setupProfileBrand
{
    //中国移动
    [self setupChinaMobile];
    //中国联通
    [self setupChinaUnicom];
    //中国电信
    [self setupChinaTelecom];
}

//移动套餐合集
-(void)setupChinaMobile
{
    ProfileMeta* meta = ProfileManager::getInst()->createMeta("China Mobile", "All", "G3&G2", "Liangxiu");
	meta->add("46000");
	meta->add("46002");
	meta->add("46007");
	meta->add("46020");
    
    IRuleProfile* profile = ProfileManager::getInst()->createProfile(meta);
	
	//profile的规则编号
	int id = 1;
    //3G rules
    
    IDialRule* rule = ProfileManager::getInst()->createRule("12593 International", "12593 International call",
                                                            Roaming::ROAMING_DOMESTIC_AND_HOME, Destination::DESTINATION_CROSS_INTERNATIONAL);
	IDialMethod* method = ProfileManager::getInst()->createMethod("12593", "{I}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("12593 Domestic", "12593 Domestic call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_CROSS_DOMESTICLY);
	method = ProfileManager::getInst()->createMethod("12593", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("12593 Domestic Roaming", "12593 Domestic Roaming call",
                                                 Roaming::ROAMING_DOMESTIC, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("12593", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("12593 Home", "12593 Home call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_HOME);
	method = ProfileManager::getInst()->createMethod("12593", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
	
    //we can't detect whether the iphone is in international roaming, so now add call back item, to in case be in international roaming.
    //when some day we can, let the download item be effective and remove this item.
    rule = ProfileManager::getInst()->createRule("**139* Call Back", "**139* USSD Call Back for International Roaming",
                                                 Roaming::ROAMING_DOMESTIC, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("**139*", "{G}#");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("**139* Call Back", "**139* USSD Call Back for International Roaming",
                                                 Roaming::ROAMING_INTERNATIONAL, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("**139*", "{G}#");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("17951 International", "17951 International call",
                                                 Roaming::ROAMING_DOMESTIC_AND_HOME, Destination::DESTINATION_CROSS_INTERNATIONAL);
    method = ProfileManager::getInst()->createMethod("17951", "{I}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("17951 Domestic", "17951 Domestic call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_CROSS_DOMESTICLY);
	method = ProfileManager::getInst()->createMethod("17951", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    //use the max id as the id of this profile
    profile->setId(cmcc_id_g3);
    ProfileManager::getInst()->addProfile(profile);
}

//联通套餐合集
- (void) setupChinaUnicom
{
    ProfileMeta* meta = ProfileManager::getInst()->createMeta("China Unicom", "All", "wo 3G&LuyiTong", "Liangxiu");
	meta->add("46001");
    meta->add("46006");
	IRuleProfile* profile = ProfileManager::getInst()->createProfile(meta);
	
	//profile的规则编号
	int id = 1;
    IDialRule*  rule = ProfileManager::getInst()->createRule("10193 International", "10193 International call",
                                                             Roaming::ROAMING_DOMESTIC_AND_HOME, Destination::DESTINATION_CROSS_INTERNATIONAL);
	IDialMethod*  method = ProfileManager::getInst()->createMethod("10193", "{I}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("10193 Domestic", "10193 Domestic call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_CROSS_DOMESTICLY);
	method = ProfileManager::getInst()->createMethod("10193", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("10193 Domestic Roaming", "10193 Domestic Roaming call",
                                                 Roaming::ROAMING_DOMESTIC, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("10193", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("10193 Home", "10193 Home call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_HOME);
	method = ProfileManager::getInst()->createMethod("10193", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    //we can't detect whether the iphone is in international roaming, so now add call back item, to in case be in international roaming.
    //when some day we can, let the download item be effective and remove this item.
    rule = ProfileManager::getInst()->createRule("**100* Call Back", "**100* USSD Call Back for International Roaming", Roaming::ROAMING_DOMESTIC, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("**100*", "{G}#");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("**100* Call Back", "**100* USSD Call Back for International Roaming", Roaming::ROAMING_INTERNATIONAL, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("**100*", "{G}#");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("17911 International", "17911 International call",
                                                 Roaming::ROAMING_DOMESTIC_AND_HOME, Destination::DESTINATION_CROSS_INTERNATIONAL);
	method = ProfileManager::getInst()->createMethod("17911", "{I}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("17911 Domestic", "17911 Domestic call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_CROSS_DOMESTICLY);
	method = ProfileManager::getInst()->createMethod("17911", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    profile->setId(unicom_id_wo3g);
	ProfileManager::getInst()->addProfile(profile);
}

//中国电信合集
- (void)setupChinaTelecom
{
    ProfileMeta* meta = ProfileManager::getInst()->createMeta("China Telecom", "All", "eSurfing", "Alice");
	meta->add("46003");
    meta->add("46005");
    meta->add("46099");
	IRuleProfile* profile = ProfileManager::getInst()->createProfile(meta);
	
	//profile的规则编号
	int id = 1;
    IDialRule*  rule = ProfileManager::getInst()->createRule("11808 International", "11808 International call",
                                                             Roaming::ROAMING_DOMESTIC_AND_HOME, Destination::DESTINATION_CROSS_INTERNATIONAL);
	IDialMethod*  method = ProfileManager::getInst()->createMethod("11808", "{I}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    
    rule = ProfileManager::getInst()->createRule("11808 Domestic", "11808 Domestic call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_CROSS_DOMESTICLY);
	method = ProfileManager::getInst()->createMethod("11808", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("11808 Domestic Roaming", "11808 Domestic Roaming call",
                                                 Roaming::ROAMING_DOMESTIC, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("11808", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("11808 Home", "11808 Home call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_HOME);
	method = ProfileManager::getInst()->createMethod("11808", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
    //we can't detect whether the iphone is in international roaming, so now add call back item, to in case be in international roaming.
    //when some day we can, let the download item be effective and remove this item.
    rule = ProfileManager::getInst()->createRule("**133* Call Back", "**133* USSD Call Back for International Roaming",
                                                 Roaming::ROAMING_DOMESTIC, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("**133*", "{G}#");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
	rule = ProfileManager::getInst()->createRule("**133* Call Back", "**133* USSD Call Back for International Roaming",
                                                 Roaming::ROAMING_INTERNATIONAL, Destination::DESTINATION_DOMESTIC);
	method = ProfileManager::getInst()->createMethod("**133*", "{G}#");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
	rule->setEnable(true);
	rule->setId(id++);
	profile->addRule(rule);
    
    rule = ProfileManager::getInst()->createRule("17909 International", "17909 International call",
                                                 Roaming::ROAMING_DOMESTIC_AND_HOME, Destination::DESTINATION_CROSS_INTERNATIONAL);
	method = ProfileManager::getInst()->createMethod("17909", "{I}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
	
    rule = ProfileManager::getInst()->createRule("17909 Domestic", "17909 Domestic call",
                                                 Roaming::ROAMING_HOME_ONLY, Destination::DESTINATION_CROSS_DOMESTICLY);
    method = ProfileManager::getInst()->createMethod("17909", "{D}");
	rule->setDialMethod(method);
	rule->setType(DialRuleType::VOIP);
    rule->setEnable(false);
	rule->setId(id++);
	profile->addRule(rule);
    
	profile->setId(ctc_id_2);
	ProfileManager::getInst()->addProfile(profile);
}

- (void)clearCache
{
	PhoneNumberFactory::ClearCache();
    Option *tmpOption = OptionManager::getInst()->getOption();
	tmpOption->deinitAttrImage();
	fclose(fd);
	fd = 0;
}

- (void)dealloc
{
	[self clearCache];
}

@end
