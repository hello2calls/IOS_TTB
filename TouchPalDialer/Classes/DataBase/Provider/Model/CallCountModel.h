//
//  CallCountModel.h
//  TouchPalDialer
//
//  Created by Alice on 12-2-1.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CallCountModel : NSObject

@property(nonatomic,assign)	NSInteger personID;
@property(nonatomic,assign) NSInteger callTime;
@property(nonatomic,assign) NSInteger callCount;

+ (CallCountModel *)callCount:(NSInteger)personID
                        count:(NSInteger)count
                     lastTime:(NSInteger)time;
@end

