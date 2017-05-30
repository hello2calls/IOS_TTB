//
//  DiscoverCircleAnimation.m
//  TouchPalDialer
//
//  Created by lin tang on 16/11/17.
//
//

#import "DiscoverCircleAnimation.h"
#import "UIColor+TPDExtension.h"
#import "ImageUtils.h"
#import "IndexConstant.h"

@implementation DiscoverCircleAnimation


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self yellowRound];
}

-(void)yellowRound
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,0,0,0,1);
    CGContextSetFillColorWithColor(context, RGB2UIColor2(3, 169, 244).CGColor);
    CGContextSetLineWidth(context, 0);
    CGContextAddArc(context, self.bounds.size.width * 0.5, self.bounds.size.height * 0.5, 12, 0, 360, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
}

-(void)animationSmall
{
    self.isScaled = NO;
    CABasicAnimation *scale = [CABasicAnimation animation];
    scale.keyPath = @"transform.scale";
    scale.fromValue =[NSNumber numberWithFloat:0.0];
    scale.toValue =[NSNumber numberWithFloat:0.5];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scale];
    group.duration =.6;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:group forKey:nil];
}

-(void)animationLarge
{
    if (!self.isScaled) {
        self.isScaled = YES;
        CABasicAnimation *scale = [CABasicAnimation animation];
        scale.keyPath = @"transform.scale";
        scale.fromValue =[NSNumber numberWithFloat:0.5];
        scale.toValue =[NSNumber numberWithFloat:1.0];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[scale];
        group.duration =.6;
        group.removedOnCompletion = NO;
        group.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:group forKey:nil];
    }
    
}

@end
