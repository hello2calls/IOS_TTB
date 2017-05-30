//
//  ConvertStructUltis.h
//  TouchDataAcess
//
//  Created by Alice on 11-9-5.
//  Copyright 2011 CooTek. All rights reserved.
//

#include "def.h"
#include "IDialRule.h"

#import "RuleModel.h"
#import "ProfileModel.h"
#import "DialMethordModel.h"

using  orlando::IDialRule;
using  orlando::IRuleProfile;
using  orlando::IDialMethod;

class ConvertStructUltis{	
public:
	static RuleModel* setRuleModel(IDialRule *rule);
	static IRuleProfile* setRuleProfile(ProfileModel *profile);
	static IDialRule* setDialRule(RuleModel *rule); 
	static ProfileModel* setProfileModel(IRuleProfile *profile);
	static DialMethordModel* setDialMethordModel(IDialMethod *methord);
	static IDialMethod* setDialMethord(DialMethordModel *methord);
};