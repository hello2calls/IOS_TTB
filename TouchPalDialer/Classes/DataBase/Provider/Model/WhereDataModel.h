//
//  WhereDataModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-22.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WhereDataModel : NSObject 

@property (nonatomic,retain) NSString *fieldKey;
@property (nonatomic,retain) NSString *oper;
@property (nonatomic,retain) NSString *fieldValue;

@end
