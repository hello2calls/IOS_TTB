//
//  PullDownSheet.m
//  TouchPalDialer
//
//  Created by Simeng on 14-7-3.
//
//

#import "PullDownSheet.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
#import "HighlightTip.h"
#import "UserDefaultKeys.h"
#import "UserDefaultsManager.h"
#import "NoahManager.h"
#define BTN_HEIGHT 46
#define BTN_WIDTH 125

@implementation PullDownSheet
@synthesize contentArray;
@synthesize delegate;
@synthesize btnAreaHeight;
@synthesize btnCount;
@synthesize shadowView;
- (id)initWithContent:(NSArray *)contents
{
    self = [super initWithFrame:CGRectZero];
    if(self){
        self.contentArray = contents;
        self.btnCount = 0;
        self.btnAreaHeight = 0;
        self.shadowView = [[UIView alloc]init];
        for (NSString *content in self.contentArray) {
            [self addContentTitle:content ifNeedToast:NO andKey:nil];
        }
        self.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)showShadow
{
    [shadowView removeFromSuperview];
    UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(TPScreenWidth() - BTN_WIDTH, TPHeaderBarHeight(), BTN_WIDTH, self.btnAreaHeight)];
    shadow.backgroundColor = [[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"pullDown_background_color"];
    shadow.layer.shadowColor = [[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"pullDown_shadow_color"].CGColor;
    shadow.layer.shadowOffset = CGSizeMake(0,0);
    shadow.layer.shadowRadius = 3;
    shadow.layer.shadowOpacity = 0.45;
    shadowView = shadow;
    [self addSubview:shadow];
    [self sendSubviewToBack:shadow];
}

- (void)clearAllBtns
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    self.btnCount = 0;
    self.btnAreaHeight = 0;
}

- (void)addContentTitle:(NSString *)title ifNeedToast:(BOOL)needToast andKey:(NSString *)key
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(TPScreenWidth() - BTN_WIDTH, self.btnAreaHeight + TPHeaderBarHeight(), BTN_WIDTH, BTN_HEIGHT)];
    btn.tag = self.btnCount;
    [btn setBackgroundImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"blackWith_0.1_alpha_color"] withFrame:CGRectMake(0, 0, BTN_WIDTH, BTN_HEIGHT)] forState:UIControlStateHighlighted];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitleColor:[TPDialerResourceManager getColorForStyle:@"pullDown_item_text_color"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth() - BTN_WIDTH, self.btnAreaHeight + TPHeaderBarHeight() - 0.5, BTN_WIDTH, 0.5)];
    label.backgroundColor = [[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"blackWith_0.2_alpha_color"];
    [self addSubview:label];
    self.btnAreaHeight = self.btnAreaHeight + BTN_HEIGHT;
    self.btnCount = self.btnCount + 1;
    [self showShadow];
    
    if ( !needToast ){
        return;
    }
    int guidePointType = PTHide;
    if (key) {
        guidePointType = [[NoahManager sharedPSInstance] getGuidePointType:key];
    }
    if ( guidePointType == PTNew ){
        UILabel *newLabel = [[UILabel alloc]initWithFrame:CGRectMake(btn.frame.size.width - 45, btn.frame.size.height/2 - 7.5, 40, 15)];
        newLabel.text = @"new";
        newLabel.layer.masksToBounds = YES;
        newLabel.layer.cornerRadius = 7.5;
        newLabel.backgroundColor = [UIColor redColor];
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.font = [UIFont systemFontOfSize:12];
        newLabel.textColor = [UIColor whiteColor];
        [btn addSubview:newLabel];
    } else if ( guidePointType == PTDot ){
        UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"dialerView_newPoint@2x.png"];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.size.width-icon.size.width-2,7, icon.size.width, icon.size.height)];
        iconView.image = icon;
        [btn addSubview:iconView];
    }
    
    if (guidePointType>PTHide){
        [[NoahManager sharedPSInstance] getGuidePointShown:key];
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self];
    if(CGRectContainsPoint(CGRectMake(170, 0, BTN_WIDTH, self.btnAreaHeight), location))
    {
        return NO;
    }
    return YES;
}

- (void)viewTapped
{
    [self.delegate removePullDownSheet];
}

- (void)btnPressed:(UIButton *)btn
{
    [self.delegate doClickOnPullDownSheet:btn.tag];
}

@end
