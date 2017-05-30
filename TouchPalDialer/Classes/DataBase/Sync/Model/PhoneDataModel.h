//
//  PhoneDataModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-25.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneDataModel : NSObject

@property(nonatomic,copy) NSString *number;
@property(nonatomic,copy) NSString *displayNumber;
@property(nonatomic,copy) NSString *digitNumber;
@property(nonatomic,copy) NSString *normalizedNumber;
@property(nonatomic,assign) NSInteger phoneID;
@property(nonatomic,assign) BOOL isForGesture;

@end
