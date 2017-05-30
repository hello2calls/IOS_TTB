//
//  TPDSkinViewController.m
//  TouchPalDialer
//
//  Created by H L on 2016/12/2.
//
//

#import "TPDSkinViewController.h"
#import "Masonry.h"
#import "HeaderBar.h"
#import "HeadTabBar.h"
#import "TPHeaderButton.h"
#import "TPDLib.h"
@interface TPDSkinViewController ()

@property(nonatomic, strong)UIView* tittleView;
@property(nonatomic, strong)UIView* navigationView;
@property(nonatomic, strong)UIView* topBar;
@end

@implementation TPDSkinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    // head bar
//    HeaderBar* headBar_ = [[HeaderBar alloc] initHeaderBarWithTitle:@"个性换肤"];
//    [self.view addSubview:headBar_];
//    [headBar_ setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
//    
    // back button
    TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
    [backBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    
    self.topBar = [[[[UIView alloc] init] tpd_withBackgroundColor:RGB2UIColor2(3, 169, 244)] tpd_withHeight:20];
    [self.view addSubview:self.topBar];

    self.navigationView = [[[[[UILabel tpd_commonLabel] tpd_withText:@"个性换肤" color:[UIColor whiteColor] font:16] tpd_wrapper] tpd_withHeight:44] tpd_withBackgroundColor:RGB2UIColor2(3, 169, 244)];
    [self.view addSubview:self.navigationView];
    
    self.view.backgroundColor=  [UIColor whiteColor];

    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit ;
    imageView.image = [UIImage imageNamed:@"wait_for_repair"];
    [self.view addSubview:imageView];
    [self.view addSubview:backBtn];

    [self.topBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.navigationView setTranslatesAutoresizingMaskIntoConstraints:NO];

    
    [self.topBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
    }];

    [imageView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
    
    [self.navigationView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topBar.bottom);
    }];

}

- (void)gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
