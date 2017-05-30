//
//  FeatureQueue.m
//  CallerInfoShow
//
//  Created by Elfe Xu on 13-2-7.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//

#import "FeatureQueue.h"
#import "SeattleFeatureExecutor.h"
#import "Reachability.h"

// [TODO] Elfe move the code to UserDefaultsManager, after UserDefaultManager is moved to common lib.
#define KEY_FEATURE_QUEUE_VERSION @"KEY_FEATURE_QUEUE_VERSION"
#define KEY_FEATURE_QUEUE @"KEY_FEATURE_QUEUE"

#define FEATURE_QUEUE_VERSION 1

#define MAX_FEATURE_REPEAT_COUNT 3

#define SERILIZABLE_FEATURE_KEY_SIGNATURE @"featureSignature"
#define SERILIZABLE_FEATURE_KEY_ARGUMENTS @"arguments"
#define SERILIZABLE_FEATURE_KEY_REPEAT @"repeat"

@implementation SerilizableFeature

static int specificKey;

@synthesize featureSignature;
@synthesize arguments;
@synthesize repeatCount;

+ (id)serilizableFeatureWithSelector:(SEL)selector arguements:(NSArray *)args
{
    SerilizableFeature *feature = [[SerilizableFeature alloc] init];
    feature.featureSignature = NSStringFromSelector(selector);
    feature.arguments = args;
    feature.repeatCount = 0;
    return feature;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.featureSignature forKey:SERILIZABLE_FEATURE_KEY_SIGNATURE];
    [aCoder encodeObject:self.arguments forKey:SERILIZABLE_FEATURE_KEY_ARGUMENTS];
    [aCoder encodeInteger:self.repeatCount forKey:SERILIZABLE_FEATURE_KEY_REPEAT];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        self.featureSignature = [aDecoder decodeObjectForKey:SERILIZABLE_FEATURE_KEY_SIGNATURE];
        self.arguments = [aDecoder decodeObjectForKey:SERILIZABLE_FEATURE_KEY_ARGUMENTS];
        self.repeatCount = [aDecoder decodeIntegerForKey:SERILIZABLE_FEATURE_KEY_REPEAT];
    }
    
    return self;
}

@end

@interface FeatureQueue () {
    __strong dispatch_queue_t dispatchQueue_;
}

@property (nonatomic, retain) NSMutableArray *queue;
@property (nonatomic, retain) Reachability *netStatusListener;

@end

@implementation FeatureQueue

@synthesize netStatusListener;
@synthesize queue;

- (id)init
{
    self = [super init];
    if (self) {
        dispatchQueue_ = dispatch_queue_create("com.touchpal.dialer.seattle", NULL);
        CFStringRef specificValue = CFSTR("com.touchpal.dialer.seattle");
        dispatch_queue_set_specific(dispatchQueue_, &specificKey, (void*)specificValue, NULL);
        
        NSInteger previousVersion = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_FEATURE_QUEUE_VERSION];
        if (previousVersion == FEATURE_QUEUE_VERSION) {
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:KEY_FEATURE_QUEUE]];
            if (array) {
                self.queue = [NSMutableArray arrayWithArray:array];
            }
        }
        if (!self.queue) {
            self.queue = [NSMutableArray arrayWithCapacity:10];
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:FEATURE_QUEUE_VERSION forKey:KEY_FEATURE_QUEUE_VERSION];
        self.netStatusListener = [Reachability shareReachability];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenNetworkChanged) name:N_REACHABILITY_NETWORK_CHANE object:nil];
    }
    
    return self;
}

- (void)doWhenNetworkChanged
{
    if ([netStatusListener currentReachabilityStatus] != NotReachable) {
        [self executeNextFetureAsync];
    }
}

- (void)queueFeature:(SerilizableFeature *)feature
{
    @synchronized(self) {
        [queue addObject:feature];
    }
    
    [self executeNextFetureAsync];
}

- (void)executeNextFetureAsync
{
    if (!dispatch_get_specific(&specificKey)) {
        dispatch_async(dispatchQueue_, ^() {
            [self executeNextFetureAsync];
        });
        return;
    }
    
    if ([netStatusListener currentReachabilityStatus] == NotReachable) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:queue]
                                                  forKey:KEY_FEATURE_QUEUE];
        NSLog(@"network not reachable. ");
        return;
    }
    
    SerilizableFeature *feature = nil;
    do {
        @synchronized(self) {
            if ([queue count] > 0) {
                feature = [queue objectAtIndex:0];
                feature.repeatCount = feature.repeatCount + 1;
                [queue removeObjectAtIndex:0];
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:queue]
                                                          forKey:KEY_FEATURE_QUEUE];
            } else {
                return;
            }
        }
        
        [self executeFeature:feature];
    } while (feature);
}

- (void)executeFeature:(SerilizableFeature *)feature
{
    FeatureExecuteResult result = [SeattleFeatureExecutor executeSerilizedFeature:feature];
    if ((result == FeatureExecuteResultFailCouldRetry) && feature.repeatCount < MAX_FEATURE_REPEAT_COUNT) {
        [self queueFeature:feature];
    }
}

- (dispatch_queue_t)getQueue {
    return dispatchQueue_;
}

@end
