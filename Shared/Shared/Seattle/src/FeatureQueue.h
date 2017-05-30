//
//  FeatureQueue.h
//  CallerInfoShow
//
//  Created by Elfe Xu on 13-2-7.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SerilizableFeature : NSObject<NSCoding>

@property (nonatomic, copy) NSString *featureSignature;
@property (nonatomic, retain) NSArray *arguments;
@property (nonatomic, assign) NSInteger repeatCount;

+ (id)serilizableFeatureWithSelector:(SEL)selector arguements:(NSArray *)arguments;

@end

@interface FeatureQueue : NSObject

- (void)queueFeature:(SerilizableFeature *)feature;

- (dispatch_queue_t)getQueue;

@end
