//
//  CallbackWizardViewController.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/2/4.
//
//

#import "CallbackWizardViewController.h"
#import "VoipConsts.h"
#import "VoipTopSectionMiddleView.h"
#import "TPDialerResourceManager.h"
#import "CallbackWizardTextView.h"
#import "CallViewController.h"
#import "TouchPalDialerAppDelegate.H"
#import "FunctionUtility.h"

@interface CallbackWizardViewController ()

//@property (copy, nonatomic) NSString *number;
@property (nonatomic,strong) NSArray* numberArr;
@property (copy, nonatomic) NSString *reuqestUUID;

@end

@implementation CallbackWizardViewController {
    float _scaleRatio;
    VoipTopSectionMiddleView *_breathingView;
    UIButton *_okButton;
    UIView *_bgView;
}

+ (id)instanceWithNumberArr:(NSArray *)number {
    return [CallbackWizardViewController instanceWithNumberArr:number aduuid:nil];
}

+ (id)instanceWithNumber:(NSString *)number {
    return [CallbackWizardViewController instanceWithNumberArr:@[number] aduuid:nil];
}

+ (id)instanceWithNumberArr:(NSArray *)number aduuid:(NSString *)uuid {
    CallbackWizardViewController *controller = [[CallbackWizardViewController alloc] init];
    controller.numberArr = number;
    controller.reuqestUUID = uuid;
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
    bgView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_bg_color"];
    [self.view addSubview:bgView];
    _bgView = bgView;
    
    //title
    float labelHeight = topViewH * scaleRatio;
    globalY += labelHeight * 2 - 28;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), labelHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_title_text_color"];
    label.text = NSLocalizedString(@"voip_callback_wizard_title", @"");
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[label.font fontWithSize:FONT_SIZE_0_5]];
    [self.view addSubview:label];
    float gap1 = topViewH * scaleRatio;
    globalY += gap1;
    
    //top section middle view
    float width = VOIP_BREATHING_OUTTER_CIRCLE_RADIUS * scaleRatio;
    VoipTopSectionMiddleView *breathingView = [[VoipTopSectionMiddleView alloc] initWithFrame:CGRectMake((TPScreenWidth() - width)/2, globalY, width, width)];
    breathingView.outter.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_circle_bg_color"];
    breathingView.outter.alpha = 0.08;
    breathingView.middle.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_circle_bg_color"];
    breathingView.middle.alpha = 0.2;
    breathingView.inner.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_circle_bg_color"];
    breathingView.inner.alpha = 1.0;
    breathingView.innerImageView.frame = CGRectMake(40, 30, breathingView.inner.frame.size.width - 80, breathingView.inner.frame.size.height - 80);
    breathingView.innerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [breathingView setInnerCircleImage:[TPDialerResourceManager getImage:@"voip_callback_wizard_image@2x.png"]];
    [self.view addSubview:breathingView];
    _breathingView = breathingView;
    globalY += (width + (isLargeScreen ? 30 : 10));
    
    //hint view 1
    NSString *line1Text = NSLocalizedString(@"voip_callback_wizard_hint1",@"");
    NSString *line2Text = NSLocalizedString(@"voip_callback_wizard_hint2", @"");
    CGFloat hintHeight = line2Text.length > 0 ? FONT_SIZE_3 * 2 + 10 : FONT_SIZE_3 + 10;
    CallbackWizardTextView *firstHint = [[CallbackWizardTextView alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), hintHeight) withLine1Text:line1Text withLine2Text:line2Text];
    [self.view addSubview:firstHint];
    globalY += (hintHeight + (isLargeScreen ? 30 : 10));
    
    
    //hint view 2
    line1Text = NSLocalizedString(@"voip_callback_wizard_hint3",@"");
    line2Text = NSLocalizedString(@"voip_callback_wizard_hint4", @"");
    hintHeight = line2Text.length > 0 ? FONT_SIZE_3 * 2 + 10 : FONT_SIZE_3 + 10;
    CallbackWizardTextView *secondHint = [[CallbackWizardTextView alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), hintHeight) withLine1Text:line1Text withLine2Text:line2Text];
    NSMutableAttributedString *attrbuteStr = [[NSMutableAttributedString alloc]initWithString:line1Text];
    int len = attrbuteStr.length;
    [attrbuteStr addAttribute:NSForegroundColorAttributeName
                        value:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"voip_callback_wizard_hint_highlight_color"]
                        range:NSMakeRange(0, len)];
    secondHint.line1Label.attributedText = attrbuteStr;
    [self.view addSubview:secondHint];
    globalY += (hintHeight + (isLargeScreen ? 30 : 10));
    
    //hint view 3
    line1Text = NSLocalizedString(@"voip_callback_wizard_hint5",@"");
    line2Text = NSLocalizedString(@"voip_callback_wizard_hint6", @"");
    hintHeight = line2Text.length > 0 ? FONT_SIZE_3 * 2 + 10 : FONT_SIZE_3 + 10;
    CallbackWizardTextView *thirdHint = [[CallbackWizardTextView alloc] initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), hintHeight) withLine1Text:line1Text withLine2Text:line2Text];
    [self.view addSubview:thirdHint];
    CGFloat delta = 20;
    if (isXLargeScreen) {
        delta = 40;
    } else if (isLargeScreen) {
        delta = 30;
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) buttonClick {
    NSLog(@"pushViewController start(%@,%@)",[TouchPalDialerAppDelegate naviController].viewControllers,[TouchPalDialerAppDelegate naviController].childViewControllers);
    [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumberArr:self.numberArr andCallMode:CallModeBackCall requestAdUUId:self.reuqestUUID] animated:YES];
    [FunctionUtility removeFromStackViewController:self];
    NSLog(@"pushViewController end");
}


@end
