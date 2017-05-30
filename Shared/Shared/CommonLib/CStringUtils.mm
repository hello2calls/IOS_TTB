//
//  CStringUltis.m
//  Untitled
//
//  Created by Alice on 11-8-12.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "CStringUtils.h"
#import "log.h"

NSString * CStringUtils::u16str2nsstr(const u16string &str) {
    if (str.size() == 0) {
        return @"";
    }
    NSString * result = [[NSString alloc] initWithCharacters:str.c_str()
                                                      length:str.size()];
    //cootek_log(@"result: %@", result);
    return result;
}

u16string CStringUtils::nsstr2u16str(NSString* str) {
    u16string result;
    if (str == nil) {
        return result;
    }
    int length = [str length];
    unichar* buffer = new unichar[length];
    NSRange range;
    range.location = 0;
    range.length = length;
    [str getCharacters:buffer
                 range:range];
    for (int i = 0; i < length; i++) {
        result.push_back(buffer[i]);
    }
    delete [] buffer;
    return result;
}

NSString * CStringUtils::cstr2nsstr(const std::string &str) {
    return CStringUtils::cstr2nsstr(str.c_str());
}

NSString * CStringUtils::cstr2nsstr(const char* str) {
    if (str == NULL || strcmp(str,"")==0) {
        return @"";
    }
    NSString * result = [NSString stringWithCString:str
                                           encoding:NSUTF8StringEncoding];
    //cootek_log(@"result: %@", result);
    return result;
}

std::string CStringUtils::nsstr2cstr(NSString* str) {
    if (str == nil || str.length == 0) {
        std::string empty;
        return empty;
    }
    std::string ret([str UTF8String]);
    return ret;
}