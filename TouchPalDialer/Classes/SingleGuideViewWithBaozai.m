//
//  SingleGuideViewWithBaozai.m
//  TouchPalDialer
//
//  Created by wen on 16/1/6.
//
//

#import "SingleGuideViewWithBaozai.h"

@implementation SingleGuideViewWithBaozai

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithGuideType:(GUIDETYPE)type image1:(UIImage *)image1 frame:(CGRect)frame{
    if ( self =[super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())]) {
        UIImageView *firstImageViewMove = [[UIImageView alloc] init];
        firstImageViewMove.backgroundColor =[UIColor colorWithPatternImage:image1];
        CGRect ViewMoveFrame =frame;
        if ([UIDevice currentDevice].systemVersion.integerValue < 7) {
                ViewMoveFrame.origin.y = ViewMoveFrame.origin.y-20;
            }
        UIView *firstImageView = [[UIView alloc] initWithFrame:frame ];
        firstImageView.layer.masksToBounds = YES;
        firstImageView.backgroundColor = [UIColor clearColor];
        firstImageViewMove.layer.masksToBounds = YES;
        UIImageView *imageViewBaozai = [[UIImageView alloc] init];
        
        if (type<=2) {
            imageViewBaozai.image = [TPDialerResourceManager getImage:@"guide_left@2x.png"];
            imageViewBaozai.frame = CGRectMake(TPScreenWidth()-150, CGRectGetMaxY(firstImageView.frame)-10, 80,90);
            firstImageViewMove.frame = CGRectMake(ViewMoveFrame.origin.x, -ViewMoveFrame.origin.y, TPScreenWidth()  , TPScreenHeight());
        }else{
            firstImageViewMove.frame = CGRectMake(-ViewMoveFrame.origin.x, -ViewMoveFrame.origin.y, TPScreenWidth()  , TPScreenHeight());
            
            imageViewBaozai.image = (type-3)%3>1?[TPDialerResourceManager getImage:@"guide_right@2x.png"]:[TPDialerResourceManager getImage:@"guide_left@2x.png"];
            
            imageViewBaozai.frame = CGRectMake((type-3)%3>1?(CGRectGetMinX(firstImageView.frame)-70):(CGRectGetMaxX(firstImageView.frame)), CGRectGetMinY(firstImageView.frame)+30, 80,90);
        }
        [firstImageView addSubview:firstImageViewMove];
        [self addSubview:firstImageView];
        [self addSubview:imageViewBaozai];
        [self addRemoveTap];
        
    }
  
    return self;
}

@end
