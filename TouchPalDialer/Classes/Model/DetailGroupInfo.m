//
//  DetailGroupInfo.m
//  TouchPalDialer
//
//  Created by zhang Owen on 12/5/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "DetailGroupInfo.h"


@implementation DetailGroupInfo
@synthesize in_this_group;
@synthesize group_data_model;

- (void)setGroupDataModel:(GroupDataModel *)gmodel {
	self.group_data_model = gmodel;
}

@end
