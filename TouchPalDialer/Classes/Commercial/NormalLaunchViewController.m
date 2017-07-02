//
//  NormalLaunchViewController.m
//  TouchPalDialer
//
//  Created by wen on 16/7/13.
//
//

#import "NormalLaunchViewController.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "TouchPalDialerAppDelegate.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface NormalLaunchViewController ()
@property(nonatomic,retain)NSTimer *timer;
@end

@implementation NormalLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [FunctionUtility setStatusBarHidden:YES];
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    
    // logo image view
    UIImage *logoImage = [TPDialerResourceManager getImage:@"chubao_slogan@2x.png"];
    CGSize logoSize = logoImage.size;
    CGFloat logoViewWidth = TPScreenWidth();
    CGFloat logoViewHeight = (logoSize.height / logoSize.width) * logoViewWidth;
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.frame = CGRectMake(0, TPScreenHeight() - logoViewHeight, logoViewWidth, logoViewHeight);
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    logoImageView.hidden = YES;
    
    
    UIImageView *normalLaunchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight() - logoViewHeight)];
    normalLaunchImageView.contentMode = UIViewContentModeScaleToFill;
    normalLaunchImageView.image = [TPDialerResourceManager getImage:@"chubao_normalLaunch@2x.png"];
    normalLaunchImageView.hidden= YES;
    
    [self.view addSubview:logoImageView];
    [self.view addSubview:normalLaunchImageView];
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(removeSelf) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    self.fd_interactivePopDisabled = YES;
    // Do any additional setup after loading the view.
}

- (void)removeSelf{
    [FunctionUtility setStatusBarHidden:NO];
    [self setTimerNil];
    [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:NO];
}

- (void)setTimerNil{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
