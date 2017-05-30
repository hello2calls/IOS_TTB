//
//  TodayWidgetSecondViewSecondAnimationView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/6.
//
//

#import "TodayWidgetSecondViewSecondAnimationView.h"
#import "TPDialerResourceManager.h"

@interface TodayWidgetSecondViewSecondAnimationView(){
    UIImageView *_imageView1;
    UIImageView *_imageView2;
    UIImageView *_imageView6;
    
    UIImageView *_imageView3;
    UIImageView *_imageView4;
    UIImageView *_imageView5;
    
    UIView *_bottomView;
    
    UIImageView *_pressView;
    
    UILabel *_topLabel;
    
    UIView *_line4;
    
    CGFloat imageWidth;
    CGFloat imageHeight;
}

@end

@implementation TodayWidgetSecondViewSecondAnimationView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if ( self ){
        [self addViewOnSelf:frame];
    }
    
    return self;
}

- (void)addViewOnSelf:(CGRect)frame{
    UIImageView *phoneView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
    phoneView.image = [TPDialerResourceManager getImage:@"today_widget_screen_bg@2x.png"];
    [self addSubview:phoneView];
    
    CGFloat globalY = 20*HEIGHT_ADAPT;
    
    UILabel *today = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width - 30*HEIGHT_ADAPT)/2, globalY, 30*HEIGHT_ADAPT, 12*HEIGHT_ADAPT)];
    today.text = @"今天";
    today.font = [UIFont systemFontOfSize:10*HEIGHT_ADAPT];
    today.textAlignment = NSTextAlignmentCenter;
    today.textColor = [UIColor whiteColor];
    today.backgroundColor = [UIColor clearColor];
    [phoneView addSubview:today];
    
    UILabel *finish = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 34*HEIGHT_ADAPT, globalY, 30*HEIGHT_ADAPT, 12*HEIGHT_ADAPT)];
    finish.text = @"完成";
    finish.font = [UIFont systemFontOfSize:10*HEIGHT_ADAPT];
    finish.textAlignment = NSTextAlignmentCenter;
    finish.textColor = [UIColor whiteColor];
    finish.backgroundColor = [UIColor clearColor];
    [phoneView addSubview:finish];
    
    globalY += today.frame.size.height + 4*HEIGHT_ADAPT;
    
    UIImage *image1 = [TPDialerResourceManager getImage:@"today_widget_cell_up01@2x.png"];
    
    imageWidth = self.frame.size.width;
    imageHeight = image1.size.height/image1.size.width*imageWidth;
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, 1)];
    line1.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_100"];
    [self addSubview:line1];
    
    _imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, imageHeight)];
    _imageView1.image = image1;
    [self addSubview:_imageView1];
    
    globalY += _imageView1.frame.size.height;
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, 1)];
    line2.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_100"];
    [self addSubview:line2];
    
    _imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, imageHeight)];
    _imageView2.image = [TPDialerResourceManager getImage:@"today_widget_cell_up02@2x.png"];
    [self addSubview:_imageView2];
    
    globalY += _imageView2.frame.size.height;
    
    UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, 1)];
    line3.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_100"];
    [self addSubview:line3];
    
    _imageView6 = [[UIImageView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, 0)];
    _imageView6.image = [TPDialerResourceManager getImage:@"today_widget_cell_up03@2x.png"];
    [self addSubview:_imageView6];
    
    globalY += 45*HEIGHT_ADAPT;
    
    UIImage *image3 = [TPDialerResourceManager getImage:@"today_widget_cell_down01@2x.png"];
    
    _imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, image3.size.height/image3.size.width*imageWidth)];
    _imageView3.image = image3;
    [self addSubview:_imageView3];
    
    globalY += _imageView3.frame.size.height;
    
    UIImage *image4 = [TPDialerResourceManager getImage:@"today_widget_cell_down02@2x.png"];
    CGFloat image4Width = image4.size.width/image4.size.height*imageHeight;
    
    _imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(0, globalY, image4Width, imageHeight)];
    _imageView4.image = [TPDialerResourceManager getImage:@"today_widget_cell_down02@2x.png"];
    [self addSubview:_imageView4];
    
    globalY += _imageView4.frame.size.height;
    
    _line4 = [[UIView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, 1)];
    _line4.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_100"];
    [self addSubview:_line4];
    
    _imageView5 = [[UIImageView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, imageHeight)];
    _imageView5.image = [TPDialerResourceManager getImage:@"today_widget_cell_down03@2x.png"];
    [self addSubview:_imageView5];
    
    globalY += _imageView4.frame.size.height;
    
    UIView *line5 = [[UIView alloc]initWithFrame:CGRectMake(0, globalY, imageWidth, 1)];
    line5.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_100"];
    [self addSubview:line5];
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(14*HEIGHT_ADAPT, phoneView.frame.size.height-78*HEIGHT_ADAPT, phoneView.frame.size.width - 28*HEIGHT_ADAPT, 14*HEIGHT_ADAPT)];
    _bottomView.backgroundColor = [UIColor clearColor];
    _bottomView.alpha = 0;
    [phoneView addSubview:_bottomView];
    
    UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 14*HEIGHT_ADAPT, 14*HEIGHT_ADAPT)];
    signLabel.layer.masksToBounds = YES;
    signLabel.layer.cornerRadius = 7*HEIGHT_ADAPT;
    signLabel.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    signLabel.text = @"2";
    signLabel.textAlignment = NSTextAlignmentCenter;
    signLabel.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_label_color"];
    signLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_text_color"];
    [_bottomView addSubview:signLabel];
    
    UILabel *alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*HEIGHT_ADAPT, 0, _bottomView.frame.size.width, _bottomView.frame.size.height)];
    alertLabel.text = @"在「今天」中添加触宝电话";
    alertLabel.backgroundColor = [UIColor clearColor];
    alertLabel.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_text_color"];
    alertLabel.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    [_bottomView addSubview:alertLabel];
}


- (void)stopAnimation{
    for (UIView *view in self.subviews )
         [view removeFromSuperview];
    [self addViewOnSelf:self.frame];
}

- (void)startAnimation{
    [self startBottomViewAnimation];
    [self firstAnimation];
}

- (void)startBottomViewAnimation{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _bottomView.alpha = 1;
    [UIView commitAnimations];
}

- (void)firstAnimation{
    [UIView beginAnimations:@"firstAnimation" context:nil];
    [UIView setAnimationDelay:1];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    _imageView4.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    [UIView commitAnimations];
}

- (void)secondAnimation{
    [UIView beginAnimations:@"secondAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    _imageView4.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    [UIView commitAnimations];
}

- (void)thirdAnimation{
    [UIView beginAnimations:@"thirdAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    _imageView4.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    [UIView commitAnimations];
}

- (void)forthAnimation{
    [UIView beginAnimations:@"forthAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    _imageView4.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    [UIView commitAnimations];
}

- (void)fifthAnimation{
    _pressView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _imageView4.frame.size.height, _imageView4.frame.size.height)];
    _pressView.image = [TPDialerResourceManager getImage:@"today_widget_ht@2x.png"];
    [_imageView4 addSubview:_pressView];
    
    [UIView beginAnimations:@"fifthAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _pressView.alpha = 0;
    [UIView commitAnimations];
    
}

- (void)sixthAnimation{
    CGRect oldFrame = _imageView4.frame;
    CGRect oldTopFrame = _imageView3.frame;
    CGRect oldNewFrame = _imageView6.frame;
    
    [UIView beginAnimations:@"sixthAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    _imageView4.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y+oldFrame.size.height, oldFrame.size.width, 0);
    _imageView3.frame = CGRectMake(oldTopFrame.origin.x, oldTopFrame.origin.y+oldFrame.size.height, oldTopFrame.size.width, oldTopFrame.size.height);
    _imageView6.frame = CGRectMake(oldNewFrame.origin.x, oldNewFrame.origin.y, oldNewFrame.size.width, oldFrame.size.height);
    [UIView commitAnimations];
}

- (void)seventhAnimation{
    
    _topLabel = [[UILabel alloc]initWithFrame:CGRectMake(_imageView6.frame.size.width - 34*HEIGHT_ADAPT, _imageView6.frame.origin.y + _imageView6.frame.size.height + 8*HEIGHT_ADAPT ,30*HEIGHT_ADAPT, 14*HEIGHT_ADAPT)];
    _topLabel.text = @"置顶";
    _topLabel.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_text_color"];
    _topLabel.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    _topLabel.backgroundColor = [UIColor clearColor];
    _topLabel.alpha = 1;
    [self addSubview:_topLabel];
    
    
    [UIView beginAnimations:@"seventhAnimation" context:nil];
    [UIView setAnimationDelay:0.7];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _topLabel.alpha = 1;
    [UIView commitAnimations];
}

- (void)eighthAnimation{
    CGRect oldFrame = _imageView6.frame;
    UIImage *image = [TPDialerResourceManager getImage:@"today_widget_cell_up03_ht@2x.png"];
    _imageView6.image = image;
    
    CGFloat height = image.size.height/image.size.width*imageWidth;
    _imageView6.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y - (height-imageHeight)/2, oldFrame.size.width, height);
    
    _pressView = [[UIImageView alloc]initWithFrame:CGRectMake(_imageView6.frame.size.width - _imageView6.frame.size.height, 0, _imageView6.frame.size.height, _imageView6.frame.size.height)];
    _pressView.image = [TPDialerResourceManager getImage:@"today_widget_ht@2x.png"];
    _pressView.alpha = 0;
    [_imageView6 addSubview:_pressView];
    
    
    [UIView beginAnimations:@"eightAnimation" context:nil];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _pressView.alpha = 1;
    [UIView commitAnimations];
}

- (void)nighthAnimation{
    CGRect oldFrame1 = _imageView1.frame;
    CGRect oldFrame2 = _imageView2.frame;
    CGRect oldFrame3 = _imageView6.frame;
    
    
    [UIView beginAnimations:@"nighthAnimation" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    _imageView1.frame = CGRectMake(oldFrame1.origin.x, oldFrame1.origin.y + imageHeight, oldFrame1.size.width, oldFrame1.size.height);
    _imageView2.frame = CGRectMake(oldFrame2.origin.x, oldFrame2.origin.y + imageHeight, oldFrame2.size.width, oldFrame2.size.height);
    _imageView6.frame = CGRectMake(oldFrame3.origin.x, oldFrame3.origin.y - 2*imageHeight, oldFrame3.size.width, oldFrame3.size.height);
    [UIView commitAnimations];
}

- (void)tenthAnimation{
    CGRect oldFrame = _imageView6.frame;
    _imageView6.image = [TPDialerResourceManager getImage:@"today_widget_cell_up03@2x.png"];
    _imageView6.frame = CGRectMake(oldFrame.origin.x, _imageView1.frame.origin.y - imageHeight, imageWidth, imageHeight);
    
    [UIView beginAnimations:@"tenthAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
    _pressView.alpha = 0;
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
        [self fifthAnimation];
    }else if ( [animationID isEqualToString:@"fifthAnimation"] && finished ){
        [_pressView removeFromSuperview];
        [self sixthAnimation];
    }else if ( [animationID isEqualToString:@"sixthAnimation"] && finished ){
        [_line4 removeFromSuperview];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _imageView6.frame.origin.y + imageHeight, imageWidth, 1)];
        line.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_100"];
        [self addSubview:line];
        [self seventhAnimation];
    }else if ( [animationID isEqualToString:@"seventhAnimation"] && finished ){
        [self eighthAnimation];
    }else if ( [animationID isEqualToString:@"eightAnimation"] && finished ){
        [self nighthAnimation];
    }else if ( [animationID isEqualToString:@"nighthAnimation"] && finished ){
        [self tenthAnimation];
    }else if ( [animationID isEqualToString:@"tenthAnimation"] && finished ){
        [UserDefaultsManager setBoolValue:YES forKey:TODAY_WIDGET_ANIMATION_SHOWN_2];
    }
}

@end
