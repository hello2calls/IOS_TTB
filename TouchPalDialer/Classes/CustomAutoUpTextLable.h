//
//  CustomAutoUpTextLable.h
//  NewsBannerDemo
//
//  Created by wen on 2016/10/25.
//  Copyright © 2016年 ssyzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NJDBezierCurve.h"
typedef void(^customeBlock)();
@interface CustomAutoUpTextLable : UILabel
@property(nonatomic,copy) customeBlock endblock;
@property(nonatomic,copy) customeBlock animationBlock;

- (void)jumpNumberWithDuration:(NSTimeInterval)duration
                    fromNumber:(float)startNumber
                      toNumber:(float)endNumber
                animationBlock:(customeBlock)animationBlock
                      endBlock:(customeBlock)endBlock;
@end
