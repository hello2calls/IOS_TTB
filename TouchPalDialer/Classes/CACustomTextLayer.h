

#import <QuartzCore/QuartzCore.h>
#import "NJDBezierCurve.h"
typedef void(^customeBlock)();

@interface CACustomTextLayer : CATextLayer

@property(nonatomic,copy) customeBlock endblock;
@property(nonatomic,copy) customeBlock animationBlock;

@property (nonatomic, assign) BOOL ifStop;
- (void)jumpNumberWithDuration:(NSTimeInterval)duration
                    fromNumber:(float)startNumber
                      toNumber:(float)endNumber;
- (void)jumpNumberWithDuration:(NSTimeInterval)duration
                    fromNumber:(float)startNumber
                      toNumber:(float)endNumber
                    endBlock:(customeBlock)endBlock;
- (void)jumpNumberWithDuration:(NSTimeInterval)duration
                    fromNumber:(float)startNumber
                      toNumber:(float)endNumber
                animationBlock:(customeBlock)animationBlock
                      endBlock:(customeBlock)endBlock;
- (void)jumpNumber;

@end
