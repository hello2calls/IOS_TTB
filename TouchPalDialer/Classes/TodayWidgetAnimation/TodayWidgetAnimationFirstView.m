//
//  TodayWidgetAnimationFirstView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/1.
//
//

#import "TodayWidgetAnimationFirstView.h"
#import "TPDialerResourceManager.h"

@interface TodayWidgetAnimationFirstView(){
    UILabel *_firstLabel;
    UILabel *_secondLabel;
    
    UIImageView *_imageView;
    
    CGFloat _imageHeight;
}

@end

@implementation TodayWidgetAnimationFirstView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        float globalY = frame.size.height/3;
        
        _firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, frame.size.width, 30*HEIGHT_ADAPT)];
        _firstLabel.text = @"未接来电要不要回?";
        _firstLabel.alpha = 0;
        _firstLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:27*HEIGHT_ADAPT];
        _firstLabel.textAlignment = NSTextAlignmentCenter;
        _firstLabel.textColor = [UIColor whiteColor];
        _firstLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_firstLabel];
        
        globalY += _firstLabel.frame.size.height + 10*HEIGHT_ADAPT;
        
        _secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, frame.size.width, 24*HEIGHT_ADAPT)];
        _secondLabel.text = @"用触宝快速查询号码信息";
        _secondLabel.alpha = 0;
        _secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:21*HEIGHT_ADAPT];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.textColor = [UIColor whiteColor];
        _secondLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_secondLabel];
        
        globalY += _secondLabel.frame.size.height + 104*HEIGHT_ADAPT;
        
        _imageHeight = globalY;
    }
    
    return self;
}


- (void)stopAnimation{
    _firstLabel.alpha = 0;
    _secondLabel.alpha = 0;
    [_imageView removeFromSuperview];
}

- (void)startAnimation{
    [self firstAnimation];
}

- (void)firstAnimation{
    //0.5
    //1
    [UIView beginAnimations:@"firstAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _firstLabel.alpha = 1;
    [UIView commitAnimations];
}

- (void)secondAnimation{
    //1.5
    //2
    [UIView beginAnimations:@"secondAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _secondLabel.alpha = 1;
    [UIView commitAnimations];
}

- (void)thirdAnimation{
    //2.5
    //3
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width/2+25*HEIGHT_ADAPT, _imageHeight, 25*HEIGHT_ADAPT, 25*HEIGHT_ADAPT)];
    _imageView.image = [TPDialerResourceManager getImage:@"today_widget_arrow@2x.png"];
    _imageView.alpha = 0;
    [self addSubview:_imageView];
    
    [UIView beginAnimations:@"thirdAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _imageView.alpha = 1;
    [UIView commitAnimations];
}

- (void)forthAnimation{
    //3
    //4
    CGRect oldFrame = _imageView.frame;
    [UIView beginAnimations:@"forthAnimation" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    _imageView.frame = CGRectMake(self.frame.size.width/2-25*HEIGHT_ADAPT, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
    _imageView.alpha = 0;
    [UIView commitAnimations];
}

- (void)doNextAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if ( [animationID isEqualToString:@"firstAnimation"] && finished ){
        [self secondAnimation];
    }else if ( [animationID isEqualToString:@"secondAnimation"] && finished ){
        [self thirdAnimation];
    }else if ( [animationID isEqualToString:@"thirdAnimation"] && finished ){
        [self forthAnimation];
    }else if ( [animationID isEqualToString:@"forthAnimation"] && finished ){
        CGRect oldFrame = _imageView.frame;
        _imageView.frame = CGRectMake(self.frame.size.width/2+25*HEIGHT_ADAPT, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
        _imageView.alpha = 1;
        [self forthAnimation];
        [UserDefaultsManager setBoolValue:YES forKey:TODAY_WIDGET_ANIMATION_SHOWN_1];
    }
    
}

@end
