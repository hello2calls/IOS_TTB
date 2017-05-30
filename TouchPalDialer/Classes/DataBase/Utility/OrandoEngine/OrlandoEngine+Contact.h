//
//  OrlandoEngine+Contact.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import "OrlandoEngine.h"

@interface OrlandoEngine (Contact)
- (void)changeCacheContract:(NSInteger)iType
                   personID:(NSInteger)recordId
                   fullName:(NSString*)fullName
                  hasNumber:(BOOL)hasNumber;



- (NSInteger)queryNumberToContact:(NSString *)number;

- (void)updateContactsWeights:(NSArray *)callcounts;

@end
