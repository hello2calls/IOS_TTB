//
//  DetailGroupInfo.h
//  TouchPalDialer
//
//  Created by zhang Owen on 12/5/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupDataModel.h"


@interface DetailGroupInfo : NSObject {
	BOOL in_this_group;
	GroupDataModel *group_data_model;
}

@property(nonatomic) BOOL in_this_group;
@property(nonatomic, retain) GroupDataModel *group_data_model;

@end
