//
//  ConvertStructUltis.m
//  TouchDataAcess
//
//  Created by Alice on 11-9-5.
//  Copyright 2011 CooTek. All rights reserved.
//


#include "ConvertStructUltis.h"	

using  orlando::ProfileMeta;
using  orlando::string; 
using  orlando::ProfileManager;
using  orlando:: vector;

ProfileModel* ConvertStructUltis::setProfileModel(IRuleProfile *profile)
{
    if (profile == NULL || profile->getMeta() == NULL) {
        return nil;
    }
    ProfileModel *m_profile=[[ProfileModel alloc] init];
	//ID
	m_profile.ID=profile->getId();
	//Name
	ProfileMeta *temp=profile->getMeta();
	string tmp_brand=temp->_brand;
	m_profile.name=[NSString stringWithUTF8String:tmp_brand.c_str()];
	//rule
    vector<IDialRule *> rules = profile->_rules;
    unsigned long rule_count = rules.size();
    for (int i=0; i<rule_count; i++) {
        [m_profile.rule_list addObject:[NSNumber numberWithInt:rules[i]->getId()]];         
    }    
	return m_profile;
}
IRuleProfile* ConvertStructUltis::setRuleProfile(ProfileModel *profile)
{
    //目前占时不用
	//IRuleProfile *m_profile=ProfileManager::getInst()->createProfile()
	return nil;
}
RuleModel* ConvertStructUltis::setRuleModel(IDialRule *rule)
{
    if (rule == NULL) {
        return nil;
    }
	RuleModel *m_rule=[[RuleModel alloc] init];
	m_rule.ID=rule->getId();
	m_rule.name=[NSString stringWithUTF8String:rule->getName().c_str()];
	m_rule.description=[NSString stringWithUTF8String:rule->getDescription().c_str()];
	m_rule.romaingType=(int)rule->getRoamingType();
	m_rule.destinationType=(int)rule->getDestinationType();
	m_rule.destinationPattern=[NSString stringWithUTF8String:rule->getDestinationPattern().c_str()];
	m_rule.isEnable=rule->isEnable();
	m_rule.dailruleType=(int)rule->getType();
    m_rule.source = (int)rule->getSource();
	//方法
	m_rule.dialMethod=setDialMethordModel(rule->getDialMethod());
	return m_rule;
}
IDialRule* ConvertStructUltis::setDialRule(RuleModel *rule)
{
	
	IDialRule* m_rule = ProfileManager::getInst()->createRule((string)[rule.name UTF8String], 
															  (string)[rule.description UTF8String], 
															   orlando::Roaming(rule.romaingType),
															   orlando::Destination(rule.destinationType));
	m_rule->setId((int)rule.ID);
	m_rule->setType((int)rule.dailruleType);
    m_rule->setEnable(rule.isEnable);
	m_rule->setDialMethod(setDialMethord(rule.dialMethod));
	return m_rule;

}
IDialMethod* ConvertStructUltis::setDialMethord(DialMethordModel *methord)
{
	IDialMethod* method = ProfileManager::getInst()->createMethod((string)[methord.ServiceNumber UTF8String],
																  (string)[methord.TransformFormat UTF8String]);
	method->Id = (int)methord.Id;
	return method;
}
DialMethordModel* ConvertStructUltis::setDialMethordModel(IDialMethod *methord)
{
    if (methord == NULL) {
        return nil;
    }
	DialMethordModel *m_methord=[[DialMethordModel alloc] init];
	m_methord.Id=methord->Id;
	m_methord.ServiceNumber=[NSString stringWithUTF8String:methord->ServiceNumber.c_str()];
	m_methord.TransformFormat=[NSString stringWithUTF8String:methord->TransformFormat.c_str()];
	return m_methord;
}