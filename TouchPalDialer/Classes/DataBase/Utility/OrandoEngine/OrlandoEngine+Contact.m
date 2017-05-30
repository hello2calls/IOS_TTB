//
//  OrlandoEngine+Contact.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import "OrlandoEngine+Contact.h"


#define NUMBER_SIZE               7

@implementation OrlandoEngine (Contact)

- (void)changeCacheContract:(NSInteger)iType
                   personID:(NSInteger)recordId
                   fullName:(NSString*)fullName
                  hasNumber:(BOOL)hasNumber
{
	switch (iType) {
		case 0:
            [self addContactToEngine:recordId fullName:fullName hasNumber:hasNumber];
            break;
		case 1:
            [self updateContactToEngine:recordId fullName:fullName hasNumber:hasNumber];
			break;
		case 2:
            [self deleteContactByPersonID:recordId];
			break;
		default:
			break;
	}
}

- (NSInteger)queryNumberToContact:(NSString *)number
{
    return [self queryNumberToContact:number withLength:NUMBER_SIZE];
}

- (void)updateContactsWeights:(NSArray *)callcounts
{
    @autoreleasepool {
        for (CallCountModel *callCount in callcounts) {
            [self updateContactWeightToEngine:callCount.personID weight:[self calcuWeight:callCount]];
        }
    }
}
@end
