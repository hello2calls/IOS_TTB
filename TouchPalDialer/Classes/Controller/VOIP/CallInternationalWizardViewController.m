//
//  CallInternationalWizardViewController.m
//  TouchPalDialer
//
//  Created by wen on 15/12/10.
//
//

#import "CallInternationalWizardViewController.h"
#import "VoipConsts.h"
#import "VoipTopSectionMiddleView.h"
#import "TPDialerResourceManager.h"
#import "CallbackWizardTextView.h"
#import "CallViewController.h"
#import "TouchPalDialerAppDelegate.H"
#import "FunctionUtility.h"
#import "NSString+Color.h"
@interface CallInternationalWizardViewController ()
@property (copy, nonatomic) NSString *number;
@property (retain, nonatomic)UIImageView *imageViewCall1;
@property (retain, nonatomic)UIImageView *imageViewCall2;
@property (retain, nonatomic)UIView *outCircle1;
@property (retain, nonatomic)UIView *outCircle2;
@end

@implementation CallInternationalWizardViewController {
    float _scaleRatio;
    VoipTopSectionMiddleView *_breathingView;
    UIButton *_okButton;
    UIView *_bgView;
    int _timerTicker;
}


+ (id)instanceWithNumber:(NSString *)number {
    CallInternationalWizardViewController *controller = [[CallInternationalWizardViewController alloc] init];
    controller.number = number;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    float scaleRatio = WIDTH_ADAPT;
    _scaleRatio = scaleRatio;
    float globalY = 0;
    BOOL isLargeScreen = TPScreenHeight() > 500;
    BOOL isXLargeScreen = TPScreenHeight() > 580;
    float topViewH = isLargeScreen ? 40 : 30;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    
    bgView.backgroundColor = [@"0x333333" color];
    [self.view addSubview:bgView];
    _bgView = bgView;
    
    //title
    float labelHeight = topViewH * scaleRatio;
    globalY += labelHeight * 2 - 28;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), labelHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_title_text_color"];
    label.text = NSLocalizedString(@"voip_international_call_wizard_title", @"");
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[label.font fontWithSize:FONT_SIZE_0_5]];
    [self.view addSubview:label];
    float gap1 = topViewH * scaleRatio;
    globalY += gap1;
    
    //top section middle view
    float width = VOIP_BREATHING_OUTTER_CIRCLE_RADIUS * scaleRatio;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), width)];
    imageView.image = [TPDialerResourceManager getImage:@"international_wizard_map@2x.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
                              
    _imageViewCall1 = [[UIImageView alloc] initWithFrame:CGRectMake(2/3.0*TPScreenWidth(), 0.8/3.0*imageView.frame.size.height, 23, 23)];
    _imageViewCall1.image = [TPDialerResourceManager getImage:@"international_wizard_telephone@2x.png"];
    _imageViewCall1.contentMode = UIViewContentModeScaleAspectFit;
    [imageView addSubview:_imageViewCall1];
    
    _imageViewCall2= [[UIImageView alloc] initWithFrame:CGRectMake(1/3.0*TPScreenWidth(), 1.3/3.0*imageView.frame.size.height, 23, 23)];
    _imageViewCall2.image = [TPDialerResourceManager getImage:@"international_wizard_telephone2@2x.png"];
    _imageViewCall2.contentMode = UIViewContentModeScaleAspectFit;
    [imageView addSubview:_imageViewCall2];
    
    

    
    globalY += (width + (isLargeScreen ? 30 : -10));
    
    //hint view 1
    NSString *line1Text = NSLocalizedString(@"voip_international_call_wizard_hint1",@"");
    NSString *line2Text = NSLocalizedString(@"voip_international_call_wizard_hint2", @"");
    CGFloat hintHeight = line2Text.length > 0 ? FONT_SIZE_3 * 2 + 10 : FONT_SIZE_3 + 10;
    CallbackWizardTextView *firstHint = [[CallbackWizardTextView alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), hintHeight) withLine1Text:line1Text withLine2Text:line2Text];
    [self.view addSubview:firstHint];
    globalY += (hintHeight + (isLargeScreen ? 30 : 10));
    
    
    //hint view 2
    line1Text = NSLocalizedString(@"voip_international_call_wizard_hint3",@"");
    line2Text = NSLocalizedString(@"voip_international_call_wizard_hint4", @"");
    hintHeight = line2Text.length > 0 ? FONT_SIZE_3 * 2 + 10 : FONT_SIZE_3 + 10;
    CallbackWizardTextView *secondHint = [[CallbackWizardTextView alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), hintHeight) withLine1Text:line1Text withLine2Text:line2Text];
    [self.view addSubview:secondHint];
    globalY += (hintHeight + (isLargeScreen ? 30 : 10));
    
    //hint view 3
    line1Text = NSLocalizedString(@"voip_international_call_wizard_hint5",@"");
    line2Text = NSLocalizedString(@"voip_international_call_wizard_hint6", @"");
    hintHeight = line2Text.length > 0 ? FONT_SIZE_3 * 2 + 10 : FONT_SIZE_3 + 10;
    CallbackWizardTextView *thirdHint = [[CallbackWizardTextView alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), hintHeight) withLine1Text:line1Text withLine2Text:line2Text];
    [self.view addSubview:thirdHint];
    CGFloat delta = 20;
    if (isXLargeScreen) {
        delta = 40;
    } else if (isLargeScreen) {
        delta = 30;
    }else{
        delta = 10;
    }
    globalY += (hintHeight + delta);
    
    //button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((TPScreenWidth() - 300) / 2, globalY, 300, 50);
    [button setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_callback_wizard_normal_bg_image"] forState:UIControlStateNormal];
    [button setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_callback_wizard_highlight_bg_image"] forState:UIControlStateHighlighted];
    [button setTitle:NSLocalizedString(@"voip_callback_wizard_ok", "") forState:UIControlStateNormal];
    [button setTitleColor:[[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"voip_callback_wizard_ok_color"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _okButton = button;
    [self breath];
    
}

-(void)breath{
    _outCircle1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
    _outCircle1.backgroundColor = [UIColor whiteColor];
    _outCircle1.layer.masksToBounds = YES;
    _outCircle1.layer.cornerRadius = 15;
    _outCircle1.center =CGPointMake(_imageViewCall1.frame.size.width/2, _imageViewCall1.frame.size.width/2);
    [_imageViewCall1 addSubview:_outCircle1];
    
    _outCircle2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
    _outCircle2.backgroundColor = [UIColor whiteColor];
    _outCircle2.layer.masksToBounds = YES;
    _outCircle2.layer.cornerRadius = 15;
    _outCircle2.center =CGPointMake(_imageViewCall2.frame.size.width/2, _imageViewCall2.frame.size.width/2);
    [_imageViewCall2 addSubview:_outCircle2];
    
    [NSTimer scheduledTimerWithTimeInterval:1/1000.0 target:self selector:@selector(statrBreath) userInfo:nil repeats:YES];
    
}

-(void)statrBreath{
    static float i = 5;
    static BOOL flag = NO;
    if (i>20) {
        flag = YES;
    }
    if (i<5) {
         flag = NO;
    }
    _outCircle1.alpha = i/100.0;
    _outCircle2.alpha =_outCircle1.alpha;
    if (flag) {
        i=i-15/500.0;
    }else{
        i=i+15/500.0;
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) buttonClick {
    NSLog(@"pushViewController start(%@,%@)",[TouchPalDialerAppDelegate naviController].viewControllers,[TouchPalDialerAppDelegate naviController].childViewControllers);
    [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:self.number andCallMode:CallModeOutgoingCall] animated:YES];
    [FunctionUtility removeFromStackViewController:self];
    NSLog(@"pushViewController end");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
