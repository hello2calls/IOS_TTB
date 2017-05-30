//
//  VoipUrlUtil.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/8/31.
//
//

#import <Foundation/Foundation.h>

@interface VoipUrlUtil : NSObject

+ (NSString *)touchpalUrl:(NSString *)number;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (BOOL)handleUserActivity:(NSUserActivity *)userActivity;

@end
