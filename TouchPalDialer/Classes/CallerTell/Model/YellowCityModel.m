//
//  YellowCityModel.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YellowCityModel.h"

@implementation YellowCityModel
@synthesize cityID;
@synthesize cityName;
@synthesize mainVersion;
@synthesize mainPath;
@synthesize mainSize;
@synthesize updateVersion;
@synthesize updatePath;
@synthesize updateSize;
@synthesize isDown;

- (id)initWithCloudData:(CloudPackageInfo *)package
{
    self = [super init];
    if (self) {
        self.cityID = package.cityID;
        self.cityName = package.cityName;
        self.mainVersion = package.mainVersion;
        self.mainPath = package.mainPath;
        self.mainSize = package.mainSize;
        self.updatePath = package.updatePath;
        self.updateSize = package.updateSize;
        self.updateVersion = package.updateVersion;
        self.isDown = NO;
    }
    
    return self;
}
@end