//
//  ProfileModel.h
//  TouchDataAcess
//
//  Created by Alice on 11-9-5.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProfileModel : NSObject 

@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSMutableArray *rule_list;
@property(nonatomic,assign) NSInteger ID;

@end
