//
//  SeattleSetting.h
//  TestSeattle
//
//  Created by Elfe Xu on 13-1-29.
//  Copyright (c) 2013年 Elfe. All rights reserved.
//

#import "isetting.h"
#import <Foundation/NSUserDefaults.h>
#import "CStringUtils.h"
#import "AdvancedSettingUtility.h"

#define SEATTLE_SETTING_PREFIX @"SEATTLE_SETTING_PREFIX"

class SeattleSetting : public ISetting {
public:
    SeattleSetting() {}
    ~SeattleSetting() {}
    
    virtual void setString(const TPSTRING& key, const TPSTRING& value) {
        NSString *v = CStringUtils::cstr2nsstr(value.c_str());
        NSString *k = [NSString stringWithFormat:@"%@_%@", SEATTLE_SETTING_PREFIX, CStringUtils::cstr2nsstr(key)];
        [AdvancedSettingUtility setAdvancedSetting:k
                                             value:v];
    }
    
    virtual const TPSTRING getString(const TPSTRING& key) {
        NSString *k = [NSString stringWithFormat:@"%@_%@", SEATTLE_SETTING_PREFIX, CStringUtils::cstr2nsstr(key)];
        NSString *v = [AdvancedSettingUtility queryAdvancedSetting:k];
        return CStringUtils::nsstr2cstr(v);
    }
};
