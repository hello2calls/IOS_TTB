//
//  TPVideoSlider.h
//  FirstSight
//
//  Created by siyi on 2016-11-25.
//  Copyright © 2016 CooTek. All rights reserved.
//

#ifndef TPVideoSlider_h
#define TPVideoSlider_h

#define N_USER_SEEK_TO_POSITION @"user_seek_to_position"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VKScrubber.h"


@interface TPVideoSlider : UISlider <VKScrubberDelegate>

@property (nonatomic, weak) id <VKScrubberDelegate> delegate;
@property (nonatomic, strong) UISlider *cacheSlider;

@end

#endif /* TPVideoSlider_h */
