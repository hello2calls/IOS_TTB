//
//  TodayWidgetAnimationThirdView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/1.
//
//

#import "TodayWidgetAnimationThirdView.h"
#import "TPDialerResourceManager.h"

@interface TodayWidgetAnimationThirdView(){
    UIView *_textView;
    UIImageView *_showLabel;

    UIView *_showView;

    UIImageView *_imageView;
    UIImageView *_copyImageView;
    UILabel *_secondLabel;
    UIView *centerView;

    CGFloat _middleHeight;

    UIView *_testView;
}

@end

@implementation TodayWidgetAnimationThirdView

- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];

    if ( self ){
        [self addViewOnSelf:frame];

    }
    return self;
}

- (void)addViewOnSelf:(CGRect)frame{
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake((TPScreenWidth()-223*HEIGHT_ADAPT)/2, (TPScreenHeight()-477*HEIGHT_ADAPT)/2, 223*HEIGHT_ADAPT, 477*HEIGHT_ADAPT)];
    bgView.image = [TPDialerResourceManager getImage:@"today_widget_phone@2x.png"];
    [self addSubview:bgView];

    centerView = [[UIView alloc]initWithFrame:CGRectMake((bgView.frame.size.width-192*HEIGHT_ADAPT)/2, (bgView.frame.size.height-341*HEIGHT_ADAPT)/2, 192*HEIGHT_ADAPT, 341*HEIGHT_ADAPT)];
    centerView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"today_widget_third_view_bg_color"];
    [bgView addSubview:centerView];

    CGFloat globalY = 106*HEIGHT_ADAPT;

    _textView = [[UIView alloc]initWithFrame:CGRectMake(14*HEIGHT_ADAPT, globalY, centerView.frame.size.width - 28*HEIGHT_ADAPT, 14*HEIGHT_ADAPT)];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.alpha = 0;
    [centerView addSubview:_textView];

    UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 14*HEIGHT_ADAPT, 14*HEIGHT_ADAPT)];
    signLabel.layer.masksToBounds = YES;
    signLabel.layer.cornerRadius = 7*HEIGHT_ADAPT;
    signLabel.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    signLabel.text = @"3";
    signLabel.textAlignment = NSTextAlignmentCenter;
    signLabel.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_label_color"];
    signLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_text_color"];
    [_textView addSubview:signLabel];

    UILabel *alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*HEIGHT_ADAPT, 0, _textView.frame.size.width, _textView.frame.size.height)];
    alertLabel.text = @"拷贝陌生号码";
    alertLabel.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_text_color"];
    alertLabel.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    alertLabel.backgroundColor = [UIColor clearColor];
    [_textView addSubview:alertLabel];

    globalY += _textView.frame.size.height + 24*HEIGHT_ADAPT;

    _middleHeight = globalY;
    _showView = [[UIView alloc]initWithFrame:CGRectMake(14*HEIGHT_ADAPT, globalY, centerView.frame.size.width - 28*HEIGHT_ADAPT, 36*HEIGHT_ADAPT)];
    _showView.backgroundColor = [UIColor clearColor];
    _showView.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"].CGColor;
    _showView.layer.borderWidth = 1.0f;
    _showView.layer.cornerRadius = 2.0f;
    [centerView addSubview:_showView];

    UIImage *image = [TPDialerResourceManager getImage:@"today_widget_number@2x.png"];
    CGFloat imageWidth = image.size.width/image.size.height*12*HEIGHT_ADAPT;
    _showLabel = [[UIImageView alloc]initWithFrame:CGRectMake((_showView.frame.size.width-imageWidth)/2, (_showView.frame.size.height-12*HEIGHT_ADAPT)/2, imageWidth, 12*HEIGHT_ADAPT)];
    _showLabel.image = image;
    [_showView addSubview:_showLabel];

    globalY += _showView.frame.size.height + 34*HEIGHT_ADAPT;

    _secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, centerView.frame.size.width, 14*HEIGHT_ADAPT)];
    _secondLabel.text = @"号码已复制到剪贴板";
    _secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_400"];
    _secondLabel.textAlignment = NSTextAlignmentCenter;
    _secondLabel.alpha = 0;
    _secondLabel.backgroundColor = [UIColor clearColor];
    _secondLabel.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    [centerView addSubview:_secondLabel];
}

- (void)startAnimation{
    [self firstAnimation];
}

- (void)stopAnimation{
    for (UIView *view in self.subviews )
        [view removeFromSuperview];
    [self addViewOnSelf:self.frame];
}

- (void)firstAnimation{
    [UIView beginAnimations:@"firstAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _textView.alpha = 1;
    [UIView commitAnimations];
}

- (void)secondAnimation{
    _testView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [centerView addSubview:_testView];
    [UIView beginAnimations:@"secondAnimation" context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _testView.alpha = 0;
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)thirdAnimation{
    UIImage *image = [TPDialerResourceManager getImage:@"today_widget_hand@2x.png"];
    CGFloat imageHeight = image.size.height/image.size.width*80*HEIGHT_ADAPT;

    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(centerView.frame.size.width/2-40*HEIGHT_ADAPT,_middleHeight+_showView.frame.size.height/2,80*HEIGHT_ADAPT,imageHeight)];
    _imageView.image = image;
    [centerView addSubview:_imageView];

    [UIView beginAnimations:@"thirdAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _showLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 20.0/14.0, 20.0/14.0);
    [UIView commitAnimations];
}

- (void)forthAnimation{
    UIImage *image = [TPDialerResourceManager getImage:@"today_widget_copy@2x.png"];
    CGFloat imageWidth = image.size.width/image.size.height*2*HEIGHT_ADAPT;
    CGFloat imageResultWidth = image.size.width/image.size.height*30*HEIGHT_ADAPT;
    _copyImageView = [[UIImageView alloc]initWithFrame:CGRectMake(centerView.frame.size.width/2-imageWidth/2, _middleHeight, imageWidth, 2*HEIGHT_ADAPT)];
    _copyImageView.image = image;
    [centerView addSubview:_copyImageView];

    [UIView beginAnimations:@"forthAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _copyImageView.frame = CGRectMake(centerView.frame.size.width/2-imageResultWidth/2, _middleHeight-20*HEIGHT_ADAPT, imageResultWidth, 30*HEIGHT_ADAPT);
    _copyImageView.alpha = 1;
    [UIView commitAnimations];
}

- (void)fifthAnimation{
    _testView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [centerView addSubview:_testView];
    [UIView beginAnimations:@"fifthAnimation" context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _testView.alpha = 0;
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)sixthAnimation{
    UIImage *image = [TPDialerResourceManager getImage:@"today_widget_hand@2x.png"];
    CGFloat imageHeight = image.size.height/image.size.width*80*HEIGHT_ADAPT;

    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_copyImageView.frame.size.width/2-40*HEIGHT_ADAPT,_copyImageView.frame.size.height/2,80*HEIGHT_ADAPT,imageHeight)];
    _imageView.image = image;
    [_copyImageView addSubview:_imageView];

    [UIView beginAnimations:@"sixthAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _copyImageView.alpha = 0;
    _imageView.alpha = 0;
    _showLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    [UIView commitAnimations];
}

- (void)seventhAnimation{
    [UIView beginAnimations:@"seventhAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _secondLabel.alpha = 1;
    [UIView commitAnimations];
}

- (void)doNextAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if ( [animationID isEqualToString:@"firstAnimation"] && finished ){
        [self secondAnimation];
    }else if ( [animationID isEqualToString:@"secondAnimation"] && finished ){
        [_testView removeFromSuperview];
        [self thirdAnimation];
    }else if ( [animationID isEqualToString:@"thirdAnimation"] && finished ){
        [_imageView removeFromSuperview];
        [self forthAnimation];
    }else if ( [animationID isEqualToString:@"forthAnimation"] && finished ){
        [self fifthAnimation];
    }else if ( [animationID isEqualToString:@"fifthAnimation"] && finished ){
        [_testView removeFromSuperview];
        [self sixthAnimation];
    }else if ( [animationID isEqualToString:@"sixthAnimation"] && finished ){
        [self seventhAnimation];
    }else if ( [animationID isEqualToString:@"seventhAnimation"] && finished ){
        [UserDefaultsManager setBoolValue:YES forKey:TODAY_WIDGET_ANIMATION_SHOWN_3];
    }
}

@end
