//
//  AntiharassAdressbookUtil.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/11.
//
//

#import <Foundation/Foundation.h>
#import "TPAddressBookWrapper.h"

@interface AntiharassAdressbookUtil : NSObject
+ (BOOL) addAntiharassToAddressbook:(NSArray *)array andIndex:(NSInteger)index;
+ (BOOL) removeAntiharassAddressbook;
+ (BOOL) isTouchpalAntiharass: (ABRecordRef) people;
+ (BOOL) isOtherAntiharass: (ABRecordRef) people;
+ (BOOL) removeAntiharassAddressbookAtbackgrondOfOthers;
@end
