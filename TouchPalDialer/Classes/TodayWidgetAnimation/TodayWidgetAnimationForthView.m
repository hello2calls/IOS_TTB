//
//  TodayWidgetAnimationForthView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/1.
//
//

#import "TodayWidgetAnimationForthView.h"
#import "TPDialerResourceManager.h"
#import "DialerUsageRecord.h"

@interface TodayWidgetAnimationForthView(){
    UIView *centerView;
    UIView *_bottomView;
    
    UIImageView *_cellView;
}

@end

@implementation TodayWidgetAnimationForthView

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
    
    UIImageView *phoneView = [[UIImageView alloc]initWithFrame:CGRectMake((bgView.frame.size.width-192*HEIGHT_ADAPT)/2, (bgView.frame.size.height-341*HEIGHT_ADAPT)/2, 192*HEIGHT_ADAPT, 341*HEIGHT_ADAPT)];
    phoneView.image = [TPDialerResourceManager getImage:@"today_widget_screen_bg@2x.png"];
    [bgView addSubview:phoneView];
    
    UIImage *tabTitleImage = [TPDialerResourceManager getImage:@"today_widget_tab_title@2x.png"];
    CGFloat tabHeight = tabTitleImage.size.height/tabTitleImage.size.width*phoneView.frame.size.width;
    
    UIImageView *tabTitle = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, phoneView.frame.size.width, tabHeight)];
    tabTitle.image = tabTitleImage;
    [phoneView addSubview:tabTitle];
    
    CGFloat globalY = tabHeight;
    
    UIImage *identityImage = [TPDialerResourceManager getImage:@"today_widget_cell_identify_title@2x.png"];
    CGFloat identityHeight = identityImage.size.height/identityImage.size.width*phoneView.frame.size.width;
    
    UIImageView *identityView = [[UIImageView alloc]initWithFrame:CGRectMake(0, globalY, phoneView.frame.size.width, identityHeight)];
    identityView.image = identityImage;
    [phoneView addSubview:identityView];
    
    globalY += identityView.frame.size.height + 10*HEIGHT_ADAPT;
    
    UIImage *cellImage = [TPDialerResourceManager getImage:@"today_widget_cell_identify@2x.png"];
    CGFloat cellHeight = cellImage.size.height/cellImage.size.width*phoneView.frame.size.width;
    
    _cellView = [[UIImageView alloc]initWithFrame:CGRectMake(0, globalY, phoneView.frame.size.width, cellHeight)];
    _cellView.image = cellImage;
    [phoneView addSubview:_cellView];
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(14*HEIGHT_ADAPT, phoneView.frame.size.height-78*HEIGHT_ADAPT, phoneView.frame.size.width - 28*HEIGHT_ADAPT, 36*HEIGHT_ADAPT)];
    _bottomView.backgroundColor = [UIColor clearColor];
    _bottomView.alpha = 0;
    [phoneView addSubview:_bottomView];
    
    UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 14*HEIGHT_ADAPT, 14*HEIGHT_ADAPT)];
    signLabel.layer.masksToBounds = YES;
    signLabel.layer.cornerRadius = 7*HEIGHT_ADAPT;
    signLabel.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    signLabel.text = @"4";
    signLabel.textAlignment = NSTextAlignmentCenter;
    signLabel.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_label_color"];
    signLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_text_color"];
    [_bottomView addSubview:signLabel];
    
    UILabel *alertLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(20*HEIGHT_ADAPT, 0, _bottomView.frame.size.width, 14*HEIGHT_ADAPT)];
    alertLabel1.text = @"下拉通知中心，";
    alertLabel1.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_text_color"];
    alertLabel1.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    alertLabel1.backgroundColor = [UIColor clearColor];
    [_bottomView addSubview:alertLabel1];
    
    UILabel *alertLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(20*HEIGHT_ADAPT, 20*HEIGHT_ADAPT, _bottomView.frame.size.width, 14*HEIGHT_ADAPT)];
    alertLabel2.text = @"触宝自动识别号码信息";
    alertLabel2.textColor = [TPDialerResourceManager getColorForStyle:@"today_widget_sign_text_color"];
    alertLabel2.font = [UIFont systemFontOfSize:12*HEIGHT_ADAPT];
    alertLabel2.backgroundColor = [UIColor clearColor];
    [_bottomView addSubview:alertLabel2];

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
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    _bottomView.alpha = 1;
    [UIView commitAnimations];
}

- (void)secondAnimation{
    [UIView beginAnimations:@"secondAnimation" context:nil];
    [UIView setAnimationDelay:0.7];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _cellView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    [UIView commitAnimations];
}

- (void)thirdAnimation{
    
    [UIView beginAnimations:@"thirdAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _cellView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    [UIView commitAnimations];
}

- (void)forthAnimation{
    
    [UIView beginAnimations:@"forthAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _cellView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    [UIView commitAnimations];
}

- (void)fifthAnimation{
    [UIView beginAnimations:@"fifthAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    _cellView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
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
        [UserDefaultsManager setBoolValue:YES forKey:TODAY_WIDGET_ANIMATION_SHOWN_4];
        if ( ![UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_LOG_PUSH defaultValue:NO]
            && [UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_1 defaultValue:NO]
            && [UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_2 defaultValue:NO]
            && [UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_3 defaultValue:NO]
            && [UserDefaultsManager boolValueForKey:TODAY_WIDGET_ANIMATION_SHOWN_4 defaultValue:NO]
            ){
            [DialerUsageRecord recordYellowPage:PATH_TODAY_WIDGET kvs:Pair(ANTIHARASS_TODAY_WIDGET_ANIMATION_SHOWN_FINISH, @(1)), nil];
            [UserDefaultsManager setBoolValue:YES forKey:TODAY_WIDGET_ANIMATION_SHOWN_LOG_PUSH];
        }
    }
}

@end
