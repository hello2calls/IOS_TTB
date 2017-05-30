//
//  DiscoverAnimationButton.m
//  TouchPalDialer
//
//  Created by lin tang on 16/11/10.
//
//

#import "DiscoverAnimationButton.h"
#import "MASConstraintMaker.h"
#import "View+MASShorthandAdditions.h"
#import "UIColor+TPDExtension.h"
#import <Masonry.h>
#import "DiscoverCircleAnimation.h"
#import "TPDialerResourceManager.h"

@implementation DiscoverAnimationButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.pointView = [[UIImageView alloc] init];
        self.arrowView = [[UIImageView alloc] init];
        UIImage *point = [TPDialerResourceManager getImage:@"common_tabbar_refresh02@2x.png"];
        [self.pointView setImage:point];
        UIImage *arrow = [TPDialerResourceManager getImage:@"common_tabbar_refresh01@2x.png"];
        [self.arrowView setImage:arrow];
        
        self.title = [[UIImageView alloc] init];
        self.title.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *title = [TPDialerResourceManager getImage:@"common_tabbar_discovery_text_pressed@2x.png"];
        [self.title setImage:title];
        
        [self addSubview:self.title];
        [self addSubview:self.arrowView];
        [self addSubview:self.pointView];
        self.pointView.hidden = YES;
        [[NSNotificationCenter defaultCenter]addObserverForName:N_SKIN_SHOULD_CHANGE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            

            [self configImage];
            
        }];
    }
    return self;
}
- (void)configImage {
    UIImage *point = [TPDialerResourceManager getImage:@"common_tabbar_refresh02@2x.png"];
    [self.pointView setImage:point];
    UIImage *arrow = [TPDialerResourceManager getImage:@"common_tabbar_refresh01@2x.png"];
    [self.arrowView setImage:arrow];
    UIImage *title = [TPDialerResourceManager getImage:@"common_tabbar_discovery_text_pressed@2x.png"];
    [self.title setImage:title];

    [self updateOfTabBar];
}

- (void)updateOfTabBar {

    BOOL hasText = [[[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"tabBarIconHasText"] intValue];

    
    [self.arrowView updateConstraints:^(MASConstraintMaker *make){
        if (hasText) {
            make.centerY.equalTo(self).offset(-6);
        } else {
            make.centerY.equalTo(self);
        }
    }];


}
- (void)layoutSubviews

{
    [super layoutSubviews];
    
    [self.title makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self);
    }];
    
    BOOL hasText = [[[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"tabBarIconHasText"] intValue];
    
    
    [self.arrowView updateConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        if (hasText) {
            make.centerY.equalTo(self).offset(-6);
        } else {
            make.centerY.equalTo(self);
        }
        make.size.mas_equalTo(CGSizeMake(28,  28));
    }];
    
    [self.pointView makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.arrowView);
    }];
}

- (void) show
{
    
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:M_PI];
    animation.toValue =  [NSNumber numberWithFloat: M_PI * 4];
    animation.duration  = 0.5;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    [self.arrowView.layer addAnimation:animation forKey:nil];
    self.pointView.alpha = 0.0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CABasicAnimation *theAnimation;
        theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        self.pointView.hidden = NO;
        self.pointView.alpha = 1.0;
        theAnimation.duration = 0.5;
        theAnimation.removedOnCompletion = YES;
        theAnimation.fromValue = [NSNumber numberWithFloat:0];
        theAnimation.toValue = [NSNumber numberWithFloat:1];
         self.pointView.frame = self.arrowView.frame;
        [self.pointView.layer addAnimation:theAnimation forKey:@"animateTransform"];
    });
}

- (void) doClick
{
    cootek_log(@" clicked ");
}
@end
