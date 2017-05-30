//
//  TPAddressBookWrapper.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface TPAddressBook : NSObject

+ (TPAddressBook*) TPAddressBook;
- (ABAddressBookRef) RetrieveABAddressBookRef;
- (BOOL) ReleaseABAddressBookRef;

@end

@interface TPAddressBookWrapper : NSObject

+ (ABAddressBookRef) CreateAddressBookRefForCurrentThread;
+ (ABAddressBookRef) RetrieveAddressBookRefForCurrentThread;
+ (void) ReleaseAddressBookForCurrentThread;

@end