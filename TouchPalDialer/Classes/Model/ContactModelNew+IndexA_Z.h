//
//  ContactModelNew+IndexA_Z.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import "ContactModelNew.h"

@interface ContactModelNew (IndexA_Z)
//A-Z scroll index
+ (int)buildIndexArray:(NSArray *)allContacts
toNewContactsContainer:(NSMutableDictionary *)contactsContainer
      andKeyContainers:(NSMutableArray *)contactsKeys;
@end
