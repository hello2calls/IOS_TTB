//
//  ContactTransferRecord.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/8.
//
//

#import "ContactTransferRecord.h"
#import "ContactTransferUtil.h"
#import "FunctionUtility.h"
#import "TPAddressBookWrapper.h"

@implementation ContactTransferRecord

- (instancetype) initWithCachedModel:(ContactCacheDataModel *)model {
    if (!model) {
        return nil;
    }
    if (self = [super init]) {
        _items = [ContactTransferUtil getItemsByCachedModel:model];
        if (!_items) {
            return nil;
        }
    }
    return self;
}

- (instancetype) initWithRecordID:(ABRecordID)recordID {
    if (self = [super init]) {
        _items = [ContactTransferUtil getItemsByRecordID:recordID];
        if (!_items) {
            return nil;
        }
    }
    return self;
}

- (instancetype) initWithDictionary:(NSDictionary *)receivedDict {
    if (!receivedDict) {
        return nil;
    }
    self = [super init];
    if (self) {
        _dict = receivedDict;
        _recordRef = ABPersonCreate();
        if ([FunctionUtility systemVersionFloat] < 9.0) {
            [self resovleForABRecordRef];
        } else {
            [self resolveForCNContact];
        }
    }
    return self;
}

- (BOOL) writeToContact {
    if (self.recordRef) {
        CFErrorRef error = NULL;
        
//        CFTypeRef nickname = ABRecordCopyValue(self.recordRef, kABPersonNicknameProperty);
//        cootek_log(@"contact_transfer, nickname: %@", (__bridge NSString *)(nickname));
//        if (nickname) {
//            CFRelease(nickname);
//        }
        
        ABAddressBookRef iPhoneAddressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        
        ABAddressBookAddRecord(iPhoneAddressBook, self.recordRef, &error);
        ABAddressBookSave(iPhoneAddressBook, &error);
        
        CFRelease(self.recordRef);
        if (!error) {
            // no error, write successfully
            return YES;
        }
    }
    return NO;
}

- (NSString *) toJSONString {
    if (!self.items) {
        return nil;
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.items options:kNilOptions error:&error];
    if (error || !data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void) resovleForABRecordRef {
    if (!_dict) {
        return;
    }
    NSArray *keys = [_dict allKeys];
    for(NSString *key in keys) {
        // keys, like `system_2` or `private_23`
        NSArray *value = [_dict objectForKey:key];  // items, unmerged
        _type = [ContactTransferUtil getRecordTypeByString:key];
        if (_type == RECORD_TYPE_PRIVATE) {
            _isPrivate = YES;
        }
        if (value) {
            [ContactTransferUtil resovleForRecord:value recordRef:self.recordRef];
        }
    }
}

- (void) resolveForCNContact {
//    if (!_dict) {
//        return;
//    }
//    _contact = [ContactTransferUtil resovleForCNContact:nil];
    [self resovleForABRecordRef];
}

@end
