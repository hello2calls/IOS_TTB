//
//  GesturePhonePadGuideView.m
//  TouchPalDialer
//
//  Created by wen on 15/12/14.
//
//

#import "GesturePhonePadGuideView.h"
static int i =6;

@implementation GesturePhonePadGuideView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())]) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, TPScreenHeight()-[self calculatePhonePadFrame].size.height-111, TPScreenWidth(), 23)];
        lable.text = @"试试在这里面画刚才的图形";
        lable.backgroundColor = [ UIColor clearColor];
        lable.font =[UIFont systemFontOfSize:16];
        lable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        lable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lable];
        
        _animationView = [[UIImageView alloc] initWithFrame:CGRectMake(lable.center.x-18/2, CGRectGetMaxY(lable.frame)+10, 18 , 18)];
        _animationView.image = [TPDialerResourceManager getImage:@"gesture_dial_arrow@2x.png"];
        [self addSubview:_animationView];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(animation) userInfo:nil repeats:YES];
        
        
        _T9_phonePad = [[KeypadView alloc] initWithFrame:[self calculatePhonePadFrame]
                                                      andKeyPadType:T9KeyBoardType
                                                        andDelegate:nil];
        _T9_phonePad.userInteractionEnabled = NO;
        
        [self addSubview:_T9_phonePad];
    }
    return self;
}

-(void)animation{
    if(i-->1){
    [self startAnimation:_animationView];
    }else{
        [self removeSelf];
    }
}

-(void)startAnimation:(UIImageView *)animaView{
    [UIView animateWithDuration:1 animations:^{
        CGRect oldFrame = animaView.frame;
        oldFrame.origin.y = oldFrame.origin.y+15;
        animaView.frame = oldFrame;
    } completion:^(BOOL finished) {
        CGRect oldFrame = animaView.frame;
        oldFrame.origin.y = oldFrame.origin.y-15;
        animaView.frame = oldFrame;
    }];
    
}

- (CGRect)calculatePhonePadFrame{
    if ([[UIDevice currentDevice]systemVersion].integerValue > 7) {
        return CGRectMake(0, TPAppFrameHeight()-TAB_BAR_HEIGHT-(TPKeypadHeight()+5)+TPHeaderBarHeightDiff(), TPScreenWidth(), TPKeypadHeight()+5);
    }
        return CGRectMake(0, TPAppFrameHeight()-(TPKeypadHeight()+35)+TPHeaderBarHeightDiff(), TPScreenWidth(), TPKeypadHeight()+5);
}

-(void)removeSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_UPDATE_FROM_TODAYWIDGET defaultValue:NO]) {
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_T9_phonePad];
    if(point.x>0&&point.y>0 && point.y<[self calculatePhonePadFrame].size.height && point.x<[self calculatePhonePadFrame].size.width){
        i = 0;
        [self performSelector:@selector(removeSelf) withObject:nil];
    }
}

@end
