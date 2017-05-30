//
//  PushProvider.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/7/18.
//
//

#import <Foundation/Foundation.h>


#define IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface PushProvider : NSObject

+ (PushProvider *)instance;

@end
