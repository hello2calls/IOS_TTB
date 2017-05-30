//
//  GestureModel.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GestureModel.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"



@implementation GestureModel

@synthesize mGestureRecognier;
@synthesize isOpenSwitchGesture;
@synthesize pointArray;

static GestureModel *_sharedSingletonModel = nil;


+ (GestureModel *)getShareInstance
{
	if (_sharedSingletonModel)
		return _sharedSingletonModel;
	
	@synchronized([GestureModel class])
	{
		if (!_sharedSingletonModel){
			_sharedSingletonModel=[[self alloc] init];
		}		
	}	
	return _sharedSingletonModel;
}

- (id)init {
	self = [super init];
    if (self) {
        GestureRecognizer *tmpRecognier = [[GestureRecognizer alloc] initGestureRecognizer];
        self.mGestureRecognier = tmpRecognier;
        if ([self isOpenSwitchGesture]) {
            [self setIsOpenSwitchGesture:YES];
        } else {
            [self setIsOpenSwitchGesture:NO];
        }
    }
    return self;
}
- (BOOL)isOpenSwitchGesture{
    return [UserDefaultsManager boolValueForKey:IS_OPEN_GESTURE_RECOGNIZER];
}

- (void)setIsOpenSwitchGesture:(BOOL)is_open{
    isOpenSwitchGesture = is_open;
    [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_SETTING_CHNAGE object:[NSNumber numberWithBool:is_open] userInfo:nil];
    [UserDefaultsManager setObject:[NSNumber numberWithBool:is_open] forKey:IS_OPEN_GESTURE_RECOGNIZER];
    [UserDefaultsManager synchronize];

}
@end
