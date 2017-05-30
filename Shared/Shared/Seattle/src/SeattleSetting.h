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
#import "DialerUsageRecord.h"
#import "NSString+TPHandleNil.h"

class SeattleSetting : public ISetting {
public:
    SeattleSetting() {}
    ~SeattleSetting() {}
    
    virtual void setString(const TPSTRING& key, const TPSTRING& value) {
        NSString *originalKey = CStringUtils::cstr2nsstr(key.c_str());
        NSString *v = CStringUtils::cstr2nsstr(value.c_str());
        
        if ([originalKey isEqualToString:CStringUtils::cstr2nsstr(KEY_TP_COOKIE)]) {
            //key @"seattle_tp_cookie" may include the auth_token
            if ([v rangeOfString:@"auth_token="].location == NSNotFound) {
                // error: do not contain the auth_token
                [DialerUsageRecord recordpath:PATH_AUTH_TOKEN
                                          kvs:Pair(AUTH_TOKEN_ERROR_FORMAT, [NSString nilToEmpty:v]), nil];
                return;
            }
        }
        NSString *k = [NSString stringWithFormat:@"%@_%@", SEATTLE_SETTING_PREFIX, originalKey];
        [[NSUserDefaults standardUserDefaults] setObject:v forKey:k];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    virtual const TPSTRING getString(const TPSTRING& key) {
        NSString *k = [NSString stringWithFormat:@"%@_%@", SEATTLE_SETTING_PREFIX, CStringUtils::cstr2nsstr(key.c_str())];
        NSString *v = [[NSUserDefaults standardUserDefaults] stringForKey:k];
        return CStringUtils::nsstr2cstr(v);
    }
};
