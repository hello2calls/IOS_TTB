//
//  BasicUtil.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BasicUtil.h"

@implementation NSObject (BasicUtil)

-(NSNumber*) hashValue {
    return [NSNumber numberWithUnsignedInteger:[self hash]];
}

@end

@implementation BasicUtil 

+(BOOL) object:(id)obj1 equalTo:(id)obj2 {
    if(obj1 == nil && obj2 == nil) {
        return YES;
    }
    
    if(obj1 == nil || obj2 == nil) {
        // Only one of them is nil, not equal
        return NO;
    }
    
    if([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]]) {
        NSString* str1 = (NSString*) obj1;
        NSString* str2 = (NSString*) obj2;
        return [str1 isEqualToString:str2];
    }
    
    if([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]]) {
        NSNumber* num1 = (NSNumber*) obj1;
        NSNumber* num2 = (NSNumber*) obj2;
        return [num1 isEqualToNumber:num2];
    }
        
    return [obj1 isEqual:obj2];
}

+(NSString*) urlEncode:(NSString*) src
{
    if(src == nil) 
    {
        src = @"";
    }
    
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                 (CFStringRef)[src mutableCopy], 
                                                                 NULL, 
                                                                 CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), 
                                                                 kCFStringEncodingUTF8)) 
            ;
}

@end

