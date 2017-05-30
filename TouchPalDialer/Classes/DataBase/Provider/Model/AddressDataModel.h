//
//  AddressDataModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-7.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressDataModel : NSObject

@property(nonatomic,retain) NSString *country;
@property(nonatomic,retain) NSArray *streetArray;
@property(nonatomic,retain) NSString *city;
@property(nonatomic,retain) NSString *zip;
@property(nonatomic,retain) NSString *state;
@property(nonatomic,retain) NSString *countryCode;

@end
