//
//  SyncTouchPalAccount.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/8/30.
//
//

#import "SyncTouchPalAccount.h"
#import <Contacts/Contacts.h>
#import "VoipUrlUtil.h"
#import "TouchPalVersionInfo.h"

@implementation SyncTouchPalAccount

+ (NSMutableArray *)mergeSocialProfileFromNumber:(NSArray<CNLabeledValue<CNPhoneNumber*>*> *)phones
                                        profiles:(NSArray<CNLabeledValue<CNSocialProfile*>*> *)profiles
                                         appName:(NSString *)appName
                                      identifier:(NSString *)identifier
{

    NSMutableArray *socials = [NSMutableArray array];
    for (CNLabeledValue<CNSocialProfile*> *profile in profiles) {
        CNSocialProfile *social = (CNSocialProfile *)profile.value;
        if (![social.userIdentifier isEqualToString:identifier]) {
            [socials addObject:profile];
        }
    }
    if (DEFAULT_ENABLE_CONATCTS_SYNC_IOS10) {
        for (CNLabeledValue<CNPhoneNumber*> *phone in phones) {
            CNPhoneNumber *number = (CNPhoneNumber *)phone.value;
            NSString *accountName = number.stringValue;
            NSString *url = [VoipUrlUtil touchpalUrl:accountName];
            CNSocialProfile * appSocialProfile = [[CNSocialProfile alloc] initWithUrlString:url
                                                                                   username:accountName
                                                                             userIdentifier:identifier
                                                                                    service:appName];
            CNLabeledValue<CNSocialProfile *> *appSocialProfileLabeledValue = [[CNLabeledValue alloc] initWithLabel:appName
                                                                                                              value:appSocialProfile];
            [socials addObject:appSocialProfileLabeledValue];
        }
    }
    return socials;
    
}

+ (void)updateAllContactTouchPalAccount
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        CNContactStore *store = [[CNContactStore alloc] init];
        NSArray<id<CNKeyDescriptor>> *condition = @[CNContactPhoneNumbersKey,CNContactSocialProfilesKey];
        CNContactFetchRequest * query = [[CNContactFetchRequest alloc] initWithKeysToFetch:condition];
        NSError *error;
        CNSaveRequest *save = [[CNSaveRequest alloc] init];
        [store enumerateContactsWithFetchRequest:query error:&error usingBlock:^(CNContact *contact, BOOL *stop) {
            if (contact && contact.phoneNumbers.count > 0) {
                NSArray *socials = [SyncTouchPalAccount mergeSocialProfileFromNumber:contact.phoneNumbers
                                                                            profiles:contact.socialProfiles
                                                                             appName:appName
                                                                          identifier:identifier];
                CNMutableContact *tmp = [contact mutableCopy];
                tmp.socialProfiles = socials;
                [save updateContact:tmp];
            }
        }];
        [store executeSaveRequest:save error:&error];
    }
}

@end
