//
//  CommonImageViewWithBlock.m
//  TouchPalDialer
//
//  Created by wen on 16/2/2.
//
//

#import "CommonImageViewWithBlock.h"

@implementation CommonImageViewWithBlock

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithImage:(UIImage *)image leftTitle:(NSString *)leftTitle leftBlock:(btnBlock)leftBlock rightTitle:(NSString *)rightTitle rightBlock:(btnBlock)rightBlock
{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {

        self.leftBlock = leftBlock;
        self.rightBlock = rightBlock;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, TPScreenWidth()-20*2,image.size.height*(TPScreenWidth()-20*2)/image.size.width+96)];
        bgView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, TPScreenWidth()-20*2, image.size.height*(TPScreenWidth()-20*2)/image.size.width);
        [bgView addSubview:imageView];
        
        UIButton *buttonL = [UIButton buttonWithType:(UIButtonTypeCustom)];
        buttonL.layer.borderColor =([TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"]).CGColor;
        buttonL.layer.masksToBounds = YES;
        buttonL.layer.borderWidth = 1;
        buttonL.layer.cornerRadius = 4;
        buttonL.frame = CGRectMake(20, bgView.frame.size.height-66, (bgView.frame.size.width-20*3)/2, 46);
        [buttonL setTitle:leftTitle forState:(UIControlStateNormal)];
        [buttonL setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"] forState:(UIControlStateNormal)];
         [buttonL setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
        [buttonL setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"]] forState:(UIControlStateHighlighted)];
        
        
        [buttonL addTarget:self action:@selector(tapLeftButton) forControlEvents:(UIControlEventTouchUpInside)];
        
        UIButton *buttonR = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [buttonR setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"] forState:(UIControlStateNormal)];
        [buttonR setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
        [buttonR setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]] forState:(UIControlStateHighlighted)];
        buttonR.layer.masksToBounds = YES;
        buttonR.layer.borderWidth = 1;
        buttonR.layer.cornerRadius = 4;
        buttonR.layer.borderColor =([TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]).CGColor;
        buttonR.frame = CGRectMake(CGRectGetMaxX(buttonL.frame)+20, bgView.frame.size.height-66, (bgView.frame.size.width-20*3)/2, 46);
        [buttonR setTitle:rightTitle forState:(UIControlStateNormal)];
        [buttonR addTarget:self action:@selector(tapRightButton) forControlEvents:(UIControlEventTouchUpInside)];
        buttonR.titleLabel.font = [UIFont systemFontOfSize:17*(TPScreenWidth()/375)];
        buttonL.titleLabel.font = [UIFont systemFontOfSize:17*(TPScreenWidth()/375)];

        [bgView addSubview:buttonL];
        [bgView addSubview:buttonR];
        
        bgView.center = CGPointMake(TPScreenWidth()/2, TPScreenHeight()/2);
        [self addSubview:bgView];
        
    }
    return self;
}
-(void)tapLeftButton{
    if (self.leftBlock) {
        self.leftBlock();
    }
    [self removeSelf];

}
-(void)tapRightButton{
    if (self.rightBlock) {
        self.rightBlock();
    }
    [self removeSelf];
}


-(void)removeSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}

-(void)sureToBlock{
    if (self.rightBlock) {
        self.rightBlock();
    }
    [self removeSelf];
}

@end
