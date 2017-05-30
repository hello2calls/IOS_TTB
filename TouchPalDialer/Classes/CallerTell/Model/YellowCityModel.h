//
//  YellowCityModel.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SeattleDataModel.h"

#define KEY_NATIONAL_ID @"nation"

@interface YellowCityModel : NSObject

@property(nonatomic,copy)NSString *cityID;
@property(nonatomic,copy)NSString *cityName;
@property(nonatomic,copy)NSString *mainVersion;
@property(nonatomic,copy)NSString *mainPath;
@property(nonatomic,assign)NSInteger mainSize;
@property(nonatomic,copy)NSString *updateVersion;
@property(nonatomic,copy)NSString *updatePath;
@property(nonatomic,assign)NSInteger updateSize;
@property(nonatomic,assign)BOOL isDown;

- (id)initWithCloudData:(CloudPackageInfo *)package;

@end
