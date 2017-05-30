//
//  CheckboxAlertView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/30.
//
//

#import "CheckboxAlertView.h"
#import "TPDialerResourceManager.h"
#import "TPButton.h"
#import "UserDefaultsManager.h"
#import "CootekNotifications.h"

#define HEIGHT_ADAPT (TPScreenWidth()>320?1.1:1)

@interface CheckboxAlertView(){
    UIView *boxView;
    UILabel *titleLabel;
    UILabel *subLabel;
    
    TPButton *sureButton;
    TPButton *leftButton;
    
    BOOL ifCheck;
    NSString *_key;
}

@end

@implementation CheckboxAlertView

- (instancetype)initWithTitle:(NSString *)title andKey:(NSString *)key{
    
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    
    if ( self ){
        _key = key;
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        boxView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280*HEIGHT_ADAPT)/2, 0, 280*HEIGHT_ADAPT, 0)];
        boxView.backgroundColor = [UIColor whiteColor];
        boxView.layer.masksToBounds = YES;
        boxView.layer.cornerRadius = 4.0f;
        [self addSubview:boxView];
        
        float globalY = 30*HEIGHT_ADAPT;
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, boxView.frame.size.width , 25*HEIGHT_ADAPT)];
        titleLabel.text = title;
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:24*HEIGHT_ADAPT];
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [boxView addSubview:titleLabel];
        
        globalY += titleLabel.frame.size.height + 30*HEIGHT_ADAPT;
        
        subLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*HEIGHT_ADAPT, globalY, boxView.frame.size.width - 40*HEIGHT_ADAPT , 16*HEIGHT_ADAPT)];
        subLabel.text = @"恭喜您获得今日启动奖励";
        subLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15*HEIGHT_ADAPT];;
        subLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        subLabel.textAlignment = NSTextAlignmentCenter;
        [boxView addSubview:subLabel];
        
        globalY += subLabel.frame.size.height + 30*HEIGHT_ADAPT;
        
        leftButton = [[TPButton alloc]initWithFrame:CGRectMake(20*HEIGHT_ADAPT, globalY, boxView.frame.size.width/2-30*HEIGHT_ADAPT, 46*HEIGHT_ADAPT) withType:GRAY_LINE withFirstLineText:@"不再弹框" withSecondLineText:nil];
        [boxView addSubview:leftButton];
        [leftButton addTarget:self action:@selector(onLeftbutton) forControlEvents:UIControlEventTouchUpInside];
        
        sureButton = [[TPButton alloc]initWithFrame:CGRectMake(boxView.frame.size.width/2+10*HEIGHT_ADAPT, globalY, boxView.frame.size.width/2-30*HEIGHT_ADAPT, 46*HEIGHT_ADAPT) withType:BLUE_LINE withFirstLineText:@"关闭" withSecondLineText:nil];
        [boxView addSubview:sureButton];
        [sureButton addTarget:self action:@selector(onSurebutton) forControlEvents:UIControlEventTouchUpInside];
        
        globalY += sureButton.frame.size.height + 20*HEIGHT_ADAPT;
        boxView.frame = CGRectMake((TPScreenWidth()-280*HEIGHT_ADAPT)/2, (TPScreenHeight()-globalY)/2, 280*HEIGHT_ADAPT, globalY);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEnterbackground) name:N_APP_DID_ENTER_BACKGROUND object:nil];
    }
    
    return self;
}

- (void)onLeftbutton{
    [UserDefaultsManager setBoolValue:YES forKey:_key];
    [self removeFromSuperview];
}

- (void)onSurebutton{
    [self removeFromSuperview];
}

- (void)onEnterbackground{
    [self removeFromSuperview];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
