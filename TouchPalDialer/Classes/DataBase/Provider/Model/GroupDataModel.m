//
//  GroupDataModel.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-8.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "GroupDataModel.h"
#import "ContactCacheDataModel.h"
#import "PersonDBA.h"


@implementation GroupDataModel

@synthesize	 groupID;
@synthesize  groupName;
@synthesize  memberCount;
@synthesize  groupRecord;

- (NSArray *)getMemberListByGroup
{
	if (!groupRecord) {
		return nil;
	}
	CFArrayRef members=ABGroupCopyArrayOfAllMembers(groupRecord);
	if (!members) {
		return nil;
	}
	int member_count=CFArrayGetCount(members);
	NSMutableArray *member_list=[[NSMutableArray alloc] init];
	for (int i=0; i<member_count; i++) {
		ABRecordRef person=CFArrayGetValueAtIndex(members, i);
		ContactCacheDataModel *person_info=[PersonDBA contactCacheDataModelByRecord:person];
		[member_list addObject:person_info];
	}
	CFRelease(members);
	return member_list ;
}

@end
