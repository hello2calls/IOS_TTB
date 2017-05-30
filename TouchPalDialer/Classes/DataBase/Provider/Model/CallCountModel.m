//
//  CallCountModel.m
//  TouchPalDialer
//
//  Created by Alice on 12-2-1.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CallCountModel.h"


@implementation CallCountModel

@synthesize personID;
@synthesize callCount;
@synthesize callTime;

+ (CallCountModel *)callCount:(NSInteger)personID
                        count:(NSInteger)count
                     lastTime:(NSInteger)time
{
    CallCountModel *callCountModel = [[CallCountModel alloc] init];
    callCountModel.callTime = time;
    callCountModel.callCount = count;
    callCountModel.personID = personID;
    return callCountModel;
}

@end
