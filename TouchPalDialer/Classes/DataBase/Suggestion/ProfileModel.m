//
//  ProfileModel.m
//  TouchDataAcess
//
//  Created by Alice on 11-9-5.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "ProfileModel.h"

@implementation ProfileModel

@synthesize  ID;
@synthesize  rule_list;
@synthesize  name;

- (id)init
{
	self = [super init];
	if( self != nil ) {
		rule_list=[[NSMutableArray alloc] init];
	}
	return self;
}

@end
