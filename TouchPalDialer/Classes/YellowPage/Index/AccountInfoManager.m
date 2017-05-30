//
//  AccountInfoManager.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/15.
//
//

#import "AccountInfoManager.h"
#import "UserDefaultsManager.h"
#import "TPDialerResourceManager.h"
#import "IndexConstant.h"

AccountInfoManager* _accountInfoInstance;


@implementation AccountInfoManager


+ (void)initialize
{
    _accountInfoInstance  = [[AccountInfoManager alloc] init];
    _accountInfoInstance.accountInfos = [NSMutableDictionary new];
    
}

+ (AccountInfoManager *)instance
{
    return _accountInfoInstance;
}

- (void) updateAccountInfos
{
    NSMutableDictionary* dic = [NSMutableDictionary new];
    if ([UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO] != nil) {
        [dic setObject: [NSString stringWithFormat:@"%d", [UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY]] forKey:PROPERTY_VIP];
        [dic setObject:[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"coins"] forKey:PROPERTY_WALLET];
        [dic setObject:[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"minutes"] forKey:PROPERTY_MINUTES];
        [dic setObject:[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"bytes_f"] forKey:PROPERTY_TRAFFIC];
        [dic setObject:[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"cards"] forKey:PROPERTY_CARDS];
    }
    [self setAccountInfos:dic];
}

@end
