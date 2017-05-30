//
//  CStringUltis.h
//  Untitled
//
//  Created by Alice on 11-8-12.
//  Copyright 2011 CooTek. All rights reserved.
//


#ifndef COMMON_LIB_CSTRING_UTIL_H_
#define COMMON_LIB_CSTRING_UTIL_H_

#include <string>

#define u16string std::basic_string<unsigned short>

class CStringUtils{
public:    
    static NSString* u16str2nsstr(const u16string &str);
    static u16string nsstr2u16str(NSString* str);
    static NSString* cstr2nsstr(const std::string &str);
    static NSString* cstr2nsstr(const char* str);
    static std::string nsstr2cstr(NSString* str);
};

#endif