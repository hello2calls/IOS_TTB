//
//  DebugSupport.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestSupport : NSObject 

+(BOOL) isTestCommand:(NSString*) input;
+(void) executeTestCommand:(NSString*) input;
+(NSString *) logFileAbsolutePath;

@end
