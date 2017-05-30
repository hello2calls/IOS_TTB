//
//  BasicUtil.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef TouchPalDialer_BasicUtil_h
#define TouchPalDialer_BasicUtil_h

#define SAFE_CFRELEASE_NULL(x) if(x) \
{\
CFRelease(x); \
x = NULL; \
}

#define SAFE_CLOSE_DATABASE(x) if(x) \
{ \
sqlite3_close(x); \
x = NULL; \
}

#define SAFE_RELEASE_QUEUE(x) if(x) \
{\
dispatch_release(x); \
x = NULL; \
}

#endif


@interface NSObject (BasicUtil)
-(NSNumber*) hashValue;
@end

@interface BasicUtil : NSObject 

+(BOOL) object:(id)obj1 equalTo:(id)obj2;
+(NSString*) urlEncode:(NSString*) src;

@end