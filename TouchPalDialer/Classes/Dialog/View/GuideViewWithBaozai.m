//
//  PersonalCenterGuideViewWithBaozai.m
//  TouchPalDialer
//
//  Created by wen on 16/1/4.
//
//

#import "GuideViewWithBaozai.h"
#import "UserDefaultsManager.h"
@implementation GuideViewWithBaozai

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithSelfFrame:(CGRect) frame  image1:(UIImage *)image1 andFrame1:(CGRect)frame1 image2:(UIImage *)image2 andFrame2:(CGRect)frame2 image3:(UIImage *)image3 andFrame3:(CGRect)frame3 ifRemoveSelf:(BOOL)ifRemoveSelf{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:frame1];
        imageView1.image = image1;
        imageView1.contentMode = UIViewContentModeCenter;

        [self addSubview:imageView1];
        
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:frame2];
        imageView2.image = image2;
        imageView2.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView2];
        
        UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:frame3];
        imageView3.image = image3;
        imageView3.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView3];
        
        if (ifRemoveSelf) {
            [self addRemoveTap];
        }
       
    }
    
    return self;
}

-(void)addRemoveTap{
    UITapGestureRecognizer *tap  =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sureToBlock)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
}

-(void)closeToBlock{
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self removeSelf];
}

-(void)removeSelf{
    if ([UserDefaultsManager intValueForKey:had_show_personCenterGuideStatus]==1) {
        [UserDefaultsManager setIntValue:2 forKey:had_show_personCenterGuideStatus];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}

-(void)sureToBlock{
    if (self.sureBlock) {
        self.sureBlock();
    }
    [self removeSelf];
}
@end
