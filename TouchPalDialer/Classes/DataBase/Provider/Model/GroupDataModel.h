//
//  GroupDataModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-8.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface GroupDataModel : NSObject 

@property (nonatomic,assign) NSInteger groupID;
@property (nonatomic,assign) ABRecordRef groupRecord;
@property (nonatomic,assign) NSInteger memberCount;
@property (nonatomic,retain) NSString *groupName;

-(NSArray *)getMemberListByGroup;

@end
