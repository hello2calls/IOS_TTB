//
//  AntiAninationGuideViewController_iOS10.m
//  TouchPalDialer
//
//  Created by wen on 2016/10/12.
//
//

#import "AntiAninationGuideViewController_iOS10.h"
#import "TPDialerResourceManager.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#import "CommonTipsWithBolckView.h"
#import "DialerUsageRecord.h"
@interface AntiAninationGuideViewController_iOS10 ()
@property(nonatomic,strong)UIImageView *antiGuideViewPhonebgView;
@property(nonatomic,strong) UIImageView *switchView1;
@property(nonatomic,strong) UIImageView *switchView2;
@property(nonatomic,strong) UIImageView *switchView3;
@property(nonatomic,strong) UIImageView *switchView4;
@property(nonatomic,strong) UIImageView *switchView5;
@property(nonatomic,strong) UIImageView *antiGuideViewCircle;
@property(nonatomic,strong) UIView    *antiGuideViewBgView;
@property(nonatomic,strong) UIImageView *antiGuideView1;
@property(nonatomic,strong) UIImageView *antiGuideView2;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) UIView *rectangleView;
@property(nonatomic,strong)CommonTipsWithBolckView *guideView;
@end

@implementation AntiAninationGuideViewController_iOS10
// data point
- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;

}

- (instancetype)init{
    if (self = [super init]) {
        self.headerTextColor = [UIColor whiteColor];
        self.skinDisabled = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DialerUsageRecord recordpath:PATH_ANTIHARASS_GUIDE_GO_SETTING kvs:Pair(PATH_ANTIHARASS_GUIDE_GO_SETTING, @(1)), nil];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self setupHeaderBar];
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"0x03a9f4"];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(addAnimationAndStartAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [self addAnimationAndStartAnimation];
    [self addStaticView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // Do any additional setup after loading the view.
}
-(void)pauseTimer{
    
    if (![self.timer isValid]) {
        return ;
    }
    
    [self.timer setFireDate:[NSDate distantFuture]];
    
    
}


-(void)resumeTimer{
    
    if (![self.timer isValid]) {
        return ;
    }
    [self.timer fire];
}

- (void)DidBecomeActive {
    if ([UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION]&&[UserDefaultsManager boolValueForKey:@"ifFirstAutoShow" defaultValue:YES]) {
        [self.guideView removeFromSuperview];
        [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    //[self resumeTimer];
    
}
- (void)DidEnterBackground {
    
    //[self pauseTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addAnimationAndStartAnimation {
    [self.antiGuideViewPhonebgView removeFromSuperview];
    
    UIImage *image = [[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewPhonebg@2x.png"];
    CGSize imageSize = image.size;
    CGFloat Width =imageSize.width;
    CGFloat Height =imageSize.height;
    self.antiGuideViewPhonebgView = [[UIImageView alloc] initWithFrame:CGRectMake((TPScreenWidth()-imageSize.width)/2, 164, Width, Height)];
    _antiGuideViewPhonebgView.backgroundColor = [UIColor clearColor];
    _antiGuideViewPhonebgView.image = image;
    [self.view addSubview:_antiGuideViewPhonebgView];
    
    
    
    
    
    image = [[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideView1@2x.png"];
    
    _antiGuideViewBgView =[[UIView alloc] initWithFrame:CGRectMake((Width-image.size.width)/2.0, 0, image.size.width, image.size.height)];
    _antiGuideViewBgView.backgroundColor = [UIColor clearColor];
    [_antiGuideViewPhonebgView addSubview:_antiGuideViewBgView];
    
    
    _antiGuideView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    _antiGuideView1.backgroundColor = [UIColor clearColor];
    _antiGuideView1.image = image;
    [_antiGuideViewBgView addSubview:_antiGuideView1];
    
    
    image = [[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideView2@2x.png"];
    _antiGuideView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    _antiGuideView2.backgroundColor = [UIColor clearColor];
    _antiGuideView2.image = image;
    _antiGuideView2.alpha = 0;
    [_antiGuideViewBgView addSubview:_antiGuideView2];
    
    self.switchView1 = [[UIImageView alloc] init];
    [_switchView1 setImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOff@2x.png"]];
    [_switchView1 setHighlightedImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOn@2x.png"]];
    _switchView1.frame = CGRectMake(212, 170, 30, 16.7);
    _switchView1.alpha = 0;
    
    _switchView2 = [[UIImageView alloc] init];
    [_switchView2 setImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOff@2x.png"]];
    [_switchView2 setHighlightedImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOn@2x.png"]];
    _switchView2.frame = CGRectMake(212, 170+28*1, 30, 16.7);
    _switchView2.alpha = 0;
    
    _switchView3 = [[UIImageView alloc] init];
    [_switchView3 setImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOff@2x.png"]];
    [_switchView3 setHighlightedImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOn@2x.png"]];
    _switchView3.frame = CGRectMake(212, 170+28*2-1, 30, 16.7);
    _switchView3.alpha = 0;
    
    _switchView4 = [[UIImageView alloc] init];
    [_switchView4 setImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOff@2x.png"]];
    [_switchView4 setHighlightedImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOn@2x.png"]];
    _switchView4.frame = CGRectMake(212, 170+28*3-1, 30, 16.7);
    _switchView4.alpha = 0;
    
    self.switchView5 = [[UIImageView alloc] init];
    [_switchView5 setImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOff@2x.png"]];
    [_switchView5 setHighlightedImage:[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewSwitchOn@2x.png"]];
    _switchView5.frame = CGRectMake(212, 170+28*4-1, 30, 16.7);
    _switchView5.alpha = 0;
    
    [_antiGuideViewPhonebgView addSubview:_switchView1];
    [_antiGuideViewPhonebgView addSubview:_switchView2];
    [_antiGuideViewPhonebgView addSubview:_switchView3];
    [_antiGuideViewPhonebgView addSubview:_switchView4];
    [_antiGuideViewPhonebgView addSubview:_switchView5];
    
    image = [[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideViewCircle@2x.png"];
    _antiGuideViewCircle = [[UIImageView alloc] initWithFrame:CGRectMake(220, 220, image.size.width, image.size.height)];
    _antiGuideViewCircle.backgroundColor = [UIColor clearColor];
    _antiGuideViewCircle.image = image;
    _antiGuideViewCircle.alpha = 0;
    [_antiGuideViewPhonebgView addSubview:_antiGuideViewCircle];
        
    _rectangleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _antiGuideViewBgView.bounds.size.width, 28)];
    _rectangleView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_150"];
    _rectangleView.alpha = 0;
    [_antiGuideViewBgView addSubview:_rectangleView];
    [self.view bringSubviewToFront:self.guideView];
    
    [UIView animateWithDuration:1.1 delay:1 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
        _antiGuideViewCircle.alpha = 1;
        _antiGuideViewCircle.frame = CGRectMake(140, 150, image.size.width, image.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            _antiGuideView1.alpha = 0;
            _antiGuideView2.alpha = 1;
            _antiGuideViewCircle.alpha =0;
            //1->2切换 a隐藏
        } completion:^(BOOL finished) {
            _antiGuideViewCircle.center = CGPointMake(220, 240);
            _antiGuideViewCircle.alpha =1;
            _antiGuideView1.image =[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideView3@2x.png"];
            [UIView animateWithDuration:0.8 animations:^{
                //b移动
                _antiGuideViewCircle.frame = CGRectMake(165, 193, image.size.width, image.size.height);
                
            } completion:^(BOOL finished) {
                _rectangleView.center= CGPointMake(_rectangleView.center.x, _antiGuideViewCircle.center.y);
                [UIView animateWithDuration:0.2 animations:^{
                    _rectangleView.alpha = 1;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        _rectangleView.alpha = 0;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.3 animations:^{
                            _antiGuideView1.alpha = 1;
                            _antiGuideView2.alpha = 0;
                            _antiGuideViewCircle.alpha =0;
                        } completion:^(BOOL finished) {
                            _antiGuideViewCircle.center = CGPointMake(220, 220);

                            _antiGuideViewCircle.alpha = 1;
                            [UIView animateWithDuration:0.8 animations:^{
                                _antiGuideViewCircle.frame = CGRectMake(165, 160, image.size.width, image.size.height);
                            } completion:^(BOOL finished) {
                                _rectangleView.center= CGPointMake(_rectangleView.center.x, _antiGuideViewCircle.center.y);
                                [UIView animateWithDuration:0.2 animations:^{
                                    _rectangleView.alpha = 1;
                                } completion:^(BOOL finished) {
                                    [UIView animateWithDuration:0.2 animations:^{
                                        _rectangleView.alpha = 0;
                                    } completion:^(BOOL finished) {
                                        _antiGuideView2.image =[[TPDialerResourceManager sharedManager] getImageByName:@"antiGuideView4@2x.png"];
                                        
                                        [UIView animateWithDuration:0.3 animations:^{
                                            _antiGuideView1.alpha = 0;
                                            _antiGuideView2.alpha = 1;
                                            _antiGuideViewCircle.alpha =0;
                                            _switchView1.alpha = 1;_switchView2.alpha = 1;_switchView3.alpha = 1;_switchView4.alpha = 1;_switchView5.alpha = 1;
                                        } completion:^(BOOL finished) {
                                            _antiGuideViewCircle.alpha = 1;
                                            _antiGuideViewCircle.center = CGPointMake(260, 220);

                                            
                                            [UIView animateWithDuration:1 animations:^{
                                                _antiGuideViewCircle.center = _switchView1.center;
                                            } completion:^(BOOL finished) {
                                                [self stepSwitchAnimation];
                                                
                                            }];
                                        }];
                                    }];
                                }];
                                
                                
                                
                                
                            }];
                            
                            
                        }];
                    }];
                }];
                
            }]
            ;
            
            
            
        }];
    }];
    
}

- (void)stepSwitchAnimation {
    _switchView1.highlighted = YES;
    CGFloat rectangleViewAnimation = 0.2;
    _rectangleView.center= CGPointMake(_rectangleView.center.x, _antiGuideViewCircle.center.y);
    [UIView animateWithDuration:0.15 animations:^{
        _rectangleView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            _rectangleView.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                _antiGuideViewCircle.center = _switchView2.center;
            } completion:^(BOOL finished) {
                _switchView2.highlighted = YES;
                _rectangleView.center= CGPointMake(_rectangleView.center.x, _antiGuideViewCircle.center.y);
                [UIView animateWithDuration:0.15 animations:^{
                    _rectangleView.alpha = 1;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.15 animations:^{
                        _rectangleView.alpha = 0;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 delay:0.15 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
                            _antiGuideViewCircle.center = _switchView3.center;
                        } completion:^(BOOL finished) {
                            _switchView3.highlighted = YES;
                            _rectangleView.center= CGPointMake(_rectangleView.center.x, _antiGuideViewCircle.center.y);
                            [UIView animateWithDuration:0.15 animations:^{
                                _rectangleView.alpha = 1;
                            } completion:^(BOOL finished) {
                                [UIView animateWithDuration:0.15 animations:^{
                                    _rectangleView.alpha = 0;
                                } completion:^(BOOL finished) {
                                    [UIView animateWithDuration:0.2 delay:0.15 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
                                        _antiGuideViewCircle.center = _switchView4.center;
                                    } completion:^(BOOL finished) {
                                        _switchView4.highlighted = YES;
                                        _rectangleView.center= CGPointMake(_rectangleView.center.x, _antiGuideViewCircle.center.y);
                                        [UIView animateWithDuration:0.15 animations:^{
                                            _rectangleView.alpha = 1;
                                        } completion:^(BOOL finished) {
                                            [UIView animateWithDuration:0.15 animations:^{
                                                _rectangleView.alpha = 0;
                                            } completion:^(BOOL finished) {
                                                [UIView animateWithDuration:0.2 delay:0.15 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
                                                    _antiGuideViewCircle.center = _switchView5.center;
                                                } completion:^(BOOL finished) {
                                                    _switchView5.highlighted = YES;
                                                    _rectangleView.center= CGPointMake(_rectangleView.center.x, _antiGuideViewCircle.center.y);
                                                    [UIView animateWithDuration:0.15 animations:^{
                                                        _rectangleView.alpha = 1;
                                                    } completion:^(BOOL finished) {
                                                        [UIView animateWithDuration:0.15 animations:^{
                                                            _rectangleView.alpha = 0;
                                                        } completion:^(BOOL finished) {
                                                            [UIView animateWithDuration:0.2 animations:^{
                                                                _antiGuideViewCircle.alpha =0;
                                                            }];
                                                            
                                                        }];
                                                    }];
                                                    

                                                }];
                                            }];
                                        }];
                                        
                                    }];
                                }];
                            }];
                            
                            
                        }];
                    }];
                }];
                
            }];
        }];
    }];
    
    
}

- (void)addStaticView {
    UIFont *font  = [UIFont systemFontOfSize:18];
    CGSize size = [@"最后一步" sizeWithFont:font];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-size.width)/2, 87, size.width, size.height)];
    lineLabel.font = font;
    lineLabel.text = @"最后一步";
    lineLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    [self.view addSubview:lineLabel];
    
    CAGradientLayer *gradientLayerLeft = [[CAGradientLayer alloc] init];
    
    gradientLayerLeft.colors = @[(__bridge id)[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_0"].CGColor,(__bridge id)[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"].CGColor];
    
    gradientLayerLeft.startPoint = CGPointMake(0, 1);
    
    gradientLayerLeft.endPoint = CGPointMake(1, 1);
    
    gradientLayerLeft.frame = CGRectMake(0, lineLabel.center.y, (TPScreenWidth()-size.width)/2-10, 1);
    
    [self.view.layer addSublayer:gradientLayerLeft];
    
    CAGradientLayer *gradientLayerRight = [[CAGradientLayer alloc] init];
    
    gradientLayerRight.colors = @[(__bridge id)[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_0"].CGColor,(__bridge id)[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_200"].CGColor];
    
    gradientLayerRight.startPoint = CGPointMake(1, 1);
    gradientLayerRight.endPoint = CGPointMake(0, 1);
    
    gradientLayerRight.frame = CGRectMake(0, lineLabel.center.y, (TPScreenWidth()-size.width)/2-10, 1);
    
    [self.view.layer addSublayer:gradientLayerRight];
    
   
    gradientLayerRight.frame = CGRectMake((TPScreenWidth()+size.width)/2+10, lineLabel.center.y, (TPScreenWidth()-size.width)/2-10, 1);
    [self.view.layer addSublayer:gradientLayerRight];
    
    font  = [UIFont systemFontOfSize:14];
    size = [@"系统设置->电话->来电设置与身份识别" sizeWithFont:font];
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth()/2-size.width/2, CGRectGetMaxY(lineLabel.frame)+13, size.width, size.height)];
    descLabel.text = @"系统设置->电话->来电阻止与身份识别";
    descLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    descLabel.font = font;
    [self.view addSubview:descLabel];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setTitle:@"去设置" forState:(UIControlStateNormal)];

    if (TPScreenHeight() > 600) {
      button.frame = CGRectMake(TPScreenWidth()/2-120,CGRectGetMaxY(_antiGuideViewPhonebgView.frame)+30 , 240, 48);
    } else {
        button.frame = CGRectMake(TPScreenWidth()/2-120, TPScreenHeight()-58 , 240, 48);
    }
    
    [button setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"0x03a9f4"] forState:(UIControlStateNormal)];
    //button.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    [button setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_white" withFrame:button.bounds] forState:(UIControlStateNormal)];
    [button setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_white_transparency_800" withFrame:button.bounds] forState:(UIControlStateHighlighted)];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 24;
    [button addTarget:self action:@selector(alertGudieView) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
}

- (void)alertGudieView {
    self.guideView =[[CommonTipsWithBolckView alloc]initWithtitleString:@"触宝提示" lable1String:@"请手动前往系统设置，开启通通宝诈骗拦截及号码识别开关" lable1textAlignment:NSTextAlignmentLeft lable2String:nil lable2textAlignment:0 leftString:nil rightString:@"我知道了" rightBlock:^{
        
        
    } leftBlock:nil];

    [DialogUtil showDialogWithContentView:self.guideView  inRootView:self.view];
    [self.view bringSubviewToFront:self.guideView];
}

- (void)setupHeaderBar {
    
    self.headerTitle = @"骚扰拦截设置";
    
    UIView *headerBarBackView = [self.headerBar valueForKey:@"backView"];
    UIView *headerBarBgView = [self.headerBar valueForKey:@"bgView"];
    headerBarBackView.backgroundColor = [UIColor clearColor];
    headerBarBgView.hidden = YES;
}
-(void)gotoBack {
    [self.timer invalidate];
    self.timer = nil;
    [super gotoBack];
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
