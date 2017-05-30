//
//  VoipUrlUtil.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/8/31.
//
//

#import "VoipUrlUtil.h"
#import "VOIPCall.h"
#import <Intents/Intents.h>
#import "TPCallActionController.h"

#define URL_PREFIX @"touchpal://voip/call?number="

@implementation VoipUrlUtil

+ (NSString *)touchpalUrl:(NSString *)number {
    return [NSString stringWithFormat:@"%@%@",URL_PREFIX,number];
}

+ (BOOL)canCallVoip:(NSString *)url {
    return [url length] > 0 && [url hasPrefix:URL_PREFIX];
}

+ (NSString *)numberFormUrl:(NSString *)url {
    NSString *number = nil;
    if ([url length] > [URL_PREFIX length]) {
        number = [url substringFromIndex:URL_PREFIX.length];
    }
    return number;
}

+ (BOOL)handleOpenURL:(NSURL *)urlRequest {
    NSString *url = [urlRequest absoluteString];
    BOOL canOpen = [VoipUrlUtil canCallVoip:url];
    if (canOpen) {
        NSString *number = [VoipUrlUtil numberFormUrl:url];
        if ([number length] > 0) {
            [[TPCallActionController controller] makeCallWithNumber:number fromOutside:YES];
        }
    }
    return canOpen;
}

+ (BOOL)handleUserActivity:(NSUserActivity *)userActivity {
    NSString *type = [userActivity activityType];
    if ([type isEqualToString:NSStringFromClass([INStartAudioCallIntent class])]) {
        INStartAudioCallIntent *intent = (INStartAudioCallIntent *)[[userActivity interaction] intent];
        NSArray<INPerson *> *contacts = [intent contacts];
        if(contacts != nil && contacts.count > 0) {
            NSString *handle = contacts[0].handle;
            if([handle length] > 0) {
                [[TPCallActionController controller] makeCallWithNumber:handle fromOutside:YES];
            }
            return true;
        }
    }
    return false;
}

@end
