//
//  TodayWidgetSecondViewFirstAnimationView_iOS10.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/22.
//
//

#import "TodayWidgetSecondViewFirstAnimationView_iOS10.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

@interface TodayWidgetSecondViewFirstAnimationView_iOS10(){
    UIView *_bottomView;
    UIButton *_editButton;
    UIImageView *_pressView;
    
    UIImageView *phoneView;
    
    UIView *_testView;
}

@end

@implementation TodayWidgetSecondViewFirstAnimationView_iOS10

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        phoneView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        phoneView.contentMode = UIViewContentModeScaleToFill;
        phoneView.image = [TPDialerResourceManager getImage:@"today_widget_screen_bg_ios10@2x.png"];
        [self addSubview:phoneView];
        
//        UIImage *tabTitleImage = [TPDialerResourceManager getImage:@"today_widget_tab_title@2x.png"];
//        CGFloat tabHeight = tabTitleImage.size.height/tabTitleImage.size.width*phoneView.frame.size.width;
//        
//        UIImageView *tabTitle = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, phoneView.frame.size.width, tabHeight)];
//        tabTitle.image = tabTitleImage;
//        [phoneView addSubview:tabTitle];
//        
//        UIImage *cellTodayImage = [TPDialerResourceManager getImage:@"today_widget_cell_today@2x.png"];
//        CGFloat todayHeight = cellTodayImage.size.height/cellTodayImage.size.width*phoneView.frame.size.width;
//        
//        UIImageView *cellToday = [[UIImageView alloc]initWithFrame:CGRectMake(0, tabHeight + 6, phoneView.frame.size.width, todayHeight)];
//        cellToday.image = cellTodayImage;
//        [phoneView addSubview:cellToday];
//        
        CGFloat globalY =  150 * HEIGHT_ADAPT;
        _editButton = [[UIButton alloc]initWithFrame:CGRectMake((phoneView.frame.size.width-30*HEIGHT_ADAPT)/2, globalY, 30*HEIGHT_ADAPT, 30*HEIGHT_ADAPT)];
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editButton setTitleColor:[UIColor colorWithRed:24/255.0 green:85/255.0 blue:104/255.0 alpha:1.0] forState:UIControlStateNormal];
        _editButton.layer.cornerRadius = _editButton.tp_width/2;
        _editButton.layer.masksToBounds = YES;
        _editButton.titleLabel.font = [UIFont systemFontOfSize:7*HEIGHT_ADAPT];
        _editButton.backgroundColor = [self editButtonColorIsHighlighted:NO];
        [phoneView addSubview:_editButton];
        
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(14*HEIGHT_ADAPT, phoneView.frame.size.height-58*HEIGHT_ADAPT, phoneView.frame.size.width - 28*HEIGHT_ADAPT, 36*HEIGHT_ADAPT)];
        _bottomView.backgroundColor = [UIColor clearColor];
        _bottomView.alpha = 0;
        [phoneView addSubview:_bottomView];
        
        UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 14*HEIGHT_ADAPT, 14*HEIGHT_ADAPT)];
        signLabel.layer.masksToBounds = YES;
        signLabel.layer.cornerRadius = 7*HEIGHT_ADAPT;
        signLabel.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
        signLabel.text = @"1";
        signLabel.textAlignment = NSTextAlignmentCenter;
        signLabel.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_label_color"];
        signLabel.backgroundColor = [UIColor whiteColor];
        [_bottomView addSubview:signLabel];
        
        
        UILabel *alertLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(20*HEIGHT_ADAPT, 0, _bottomView.frame.size.width, 14*HEIGHT_ADAPT)];
        alertLabel1.text = @"从屏幕左边向右滑动，";
        alertLabel1.backgroundColor = [UIColor clearColor];
        alertLabel1.textColor = [UIColor whiteColor];
        alertLabel1.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
        [_bottomView addSubview:alertLabel1];
        
        UILabel *alertLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(20*HEIGHT_ADAPT, 20*HEIGHT_ADAPT, _bottomView.frame.size.width, 14*HEIGHT_ADAPT)];
        alertLabel2.text = @"打开通知中心，点「编辑」";
        alertLabel2.backgroundColor = [UIColor clearColor];
        alertLabel2.textColor = [UIColor whiteColor];
        alertLabel2.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
        [_bottomView addSubview:alertLabel2];
        
        
    }
    
    return self;
    
}

- (UIColor *)editButtonColorIsHighlighted:(BOOL)isHighlighted {
    
    return isHighlighted ? [UIColor colorWithRed:228/255.0 green:244/255.0 blue:248/255.0 alpha:1.0] : [UIColor colorWithRed:185/255.0 green:220/255.0 blue:230/255.0 alpha:1.0];
}

- (void)stopAnimation{
    _bottomView.alpha = 0;
//    _editButton.highlighted = NO;
    _editButton.backgroundColor = [self editButtonColorIsHighlighted:NO];
    [_pressView removeFromSuperview];
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
    _bottomView.alpha = 1;
    [UIView commitAnimations];
}


- (void)secondAnimation{
    _testView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self addSubview:_testView];
    [UIView beginAnimations:@"secondAnimation" context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _testView.alpha = 0;
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)thirdAnimation{
    
    _pressView = [[UIImageView alloc]initWithFrame:CGRectMake(_editButton.frame.origin.x + _editButton.frame.size.width/5*3, _editButton.frame.origin.y, _editButton.frame.size.height, _editButton.frame.size.height)];
    _pressView.image = [TPDialerResourceManager getImage:@"today_widget_ht_ios10@2x.png"];
    [phoneView addSubview:_pressView];
    
    [UIView beginAnimations:@"thirdAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _pressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
    [UIView commitAnimations];
}

- (void)forthAnimation{
    [UIView beginAnimations:@"forthAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _pressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    [UIView commitAnimations];
}

- (void)fifthAnimation{
    [UIView beginAnimations:@"fifthAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _pressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
//    _editButton.highlighted = YES;
    _editButton.backgroundColor = [self editButtonColorIsHighlighted:YES];
    [UIView commitAnimations];
}

- (void)doNextAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if ( [animationID isEqualToString:@"firstAnimation"] && finished ){
        [self secondAnimation];
    }else if ( [animationID isEqualToString:@"secondAnimation"] && finished ){
        [_testView removeFromSuperview];
        [self thirdAnimation];
    }else if ( [animationID isEqualToString:@"thirdAnimation"] && finished ){
        [self forthAnimation];
    }else if ( [animationID isEqualToString:@"forthAnimation"] && finished ){
        [self fifthAnimation];
    }else if ( [animationID isEqualToString:@"fifthAnimation"] && finished ){
        [_pressView removeFromSuperview];
//        _editButton.highlighted = NO;
        _editButton.backgroundColor = [self editButtonColorIsHighlighted:NO];
        if ( self.delegate != nil )
            [self.delegate onAnimationOver:0];
    }
}

@end
