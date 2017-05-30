//
//  DialerGuideAnimationBoardView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/19.
//
//

#import "DialerGuideAnimationBoardView.h"
#import "TPDialerResourceManager.h"

@interface DialerGuideAnimationBoardView(){
    NSInteger _tag;
}

@end

@implementation DialerGuideAnimationBoardView

- (instancetype)initWithFrame:(CGRect)frame andTitle:(NSString *)title andTag:(NSInteger)tag{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        _tag = tag;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 2.0f;
        self.alpha = 0;
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        titleLabel.text = title;
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:28];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        self.layer.shadowOffset = CGSizeMake(0,2);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
        self.layer.shadowOpacity = 0;
        self.layer.shadowRadius = 2;//阴影半径，默认3
    }
    
    return self;
}

- (void) startAnimation{
    CGRect oldFrame = self.frame;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 1;
                         self.layer.shadowOpacity = 0.25;
                         self.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y - 20 - oldFrame.size.height , oldFrame.size.width, oldFrame.size.height);
                     }
                     completion:^(BOOL finished){
                         if ( !finished )
                             return;
                         [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:0.8f];
                     }];
}

- (void) stopAnimation{
    if ( _delegate != nil )
        [_delegate onAnimationStop];
    [self removeFromSuperview];
}

- (void)dealloc{
    _delegate = nil;
}

@end
