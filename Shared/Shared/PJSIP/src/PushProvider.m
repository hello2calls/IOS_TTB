//
//  PushProvider.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/7/18.
//
//

#import "PushProvider.h"
#import <PushKit/PushKit.h>
#import "UserDefaultsManager.h"
#import "PJSIPManager.h"


@interface PushProvider ()<PKPushRegistryDelegate>
{
    PKPushRegistry *_push;
}

@end

@implementation PushProvider

PushProvider *instance = nil;

+ (PushProvider *)instance {
    if (!instance) {
        instance = [[PushProvider alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            _push = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
            _push.delegate = self;
            _push.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
        }
    }
    return self;
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type
{
    cootek_log(@"didUpdatePushCredentials......");
    if ([PKPushTypeVoIP isEqualToString:type]) {
        NSData *token = [credentials token];
        NSString *deviceTokenStr = [[[[token description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
        NSString *pre = [UserDefaultsManager stringForKey:APPLE_VOIP_PUSH_TOKEN defaultValue:nil];
        if (![pre isEqualToString:deviceTokenStr]) {
            [UserDefaultsManager setObject:deviceTokenStr forKey:APPLE_VOIP_PUSH_TOKEN];
            [PJSIPManager checkInit];
        }
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    cootek_log(@"didReceiveIncomingPushWithPayload......");
    if ([PKPushTypeVoIP isEqualToString:type]) {
        [PJSIPManager checkInit];
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(NSString *)type
{
    cootek_log(@"didInvalidatePushTokenForType......");
    if ([PKPushTypeVoIP isEqualToString:type]) {
        [UserDefaultsManager setObject:nil forKey:APPLE_VOIP_PUSH_TOKEN];
    }
}
@end
