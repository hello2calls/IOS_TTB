//
//  ContactModelNew.h
//  TouchPalDialer
//
//  Created by Sendor on 12-1-18.
//  Copyright 2012 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactModelNew : NSObject

@property(nonatomic, retain, readonly) NSDictionary *all_contacts;
@property(nonatomic, retain, readonly) NSArray *all_contact_keys;
@property(nonatomic, retain, readonly) NSArray *predefinedKeys;

+ (ContactModelNew *)getSharedContactModel;
- (void)buildAZtoAllContacts;

@end
