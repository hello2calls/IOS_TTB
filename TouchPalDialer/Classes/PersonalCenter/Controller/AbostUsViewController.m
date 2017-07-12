//
//  AbostUsViewController.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/1.
//
//

#import "AbostUsViewController.h"
#import "TPDialerResourceManager.h"
#import "TouchPalVersionInfo.h"
#import "SettingTableView.h"
#import "NormalSettingItem.h"
#import "CommonWebViewController.h"
#import "AboatUsLogoItem.h"
#import "DefaultUIAlertViewHandler.h"
#import "TouchPalDialerAppDelegate.h"
#import "PrivacyViewController.h"

@interface AbostUsViewController ()<SettingTableViewDelegate>

@property (nonatomic,weak) SettingTableView *settingTableView;
@property (nonatomic,strong) NSMutableArray *settingArr;
@property (nonatomic,strong) UIView *footerView;

@end

@implementation AbostUsViewController

- (NSMutableArray *)settingArr{
    if (!_settingArr) {
        _settingArr = [NSMutableArray array];
    }
    return _settingArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerTitle = NSLocalizedString(@"personal_center_setting_aboat_us", @"关于触宝");
    [self buildUI];
}

- (void)buildUI{
    
    [self bulidFooterView];
    
    [self buildSettingView];
    
    [self setupSettingItems];
}

- (void)buildSettingView{
    SettingTableView *settingTableView = [[SettingTableView alloc] init];
    
    CGFloat settingTableViewX = 0;
    CGFloat settingTableViewY = TPHeaderBarHeight();
    CGFloat settingTableViewW = TPScreenWidth();
    CGFloat settingTableViewH = TPScreenHeight() - settingTableViewY;
    settingTableView.frame = CGRectMake(settingTableViewX, settingTableViewY, settingTableViewW, settingTableViewH);
    self.settingTableView = settingTableView;
    settingTableView.delegate = self;
    settingTableView.footerView =  self.footerView;
    [self.view addSubview:settingTableView];
}

- (void)bulidFooterView{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    self.footerView = footerView;
    
    UIButton *serviceAgreementBtn = [[UIButton alloc] init];
    [serviceAgreementBtn setTitle:@"用户协议及隐私政策" forState:UIControlStateNormal];
    [serviceAgreementBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] forState:UIControlStateNormal];
    [serviceAgreementBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_700"] forState:UIControlStateHighlighted];
    serviceAgreementBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [serviceAgreementBtn sizeToFit];
    [serviceAgreementBtn addTarget:self action:@selector(pushServiceAgreement) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:serviceAgreementBtn];
    
    UILabel *copyRightLabel = [[UILabel alloc] init];
    copyRightLabel.backgroundColor = [UIColor clearColor];
    copyRightLabel.numberOfLines = 2;
    copyRightLabel.textAlignment = NSTextAlignmentCenter;
    copyRightLabel.font = [UIFont systemFontOfSize:13];
    copyRightLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextGray_color"];
    copyRightLabel.text = @"触宝科技 版权所有\nCopyright © 2011-2016 Cootek. All Rights Reserved.";
    [copyRightLabel sizeToFit];
    [footerView addSubview:copyRightLabel];
    
    CGFloat footerViewH = 24 + copyRightLabel.tp_height + 24 + 13 + 32;
    CGFloat footerViewX = 0;
    CGFloat footerViewY = TPScreenHeight() - footerViewH;
    CGFloat footerViewW = TPScreenWidth();
    footerView.frame = CGRectMake(footerViewX, footerViewY, footerViewW, footerViewH);
    
    serviceAgreementBtn.tp_x = (footerViewW - serviceAgreementBtn.tp_width) / 2;
    serviceAgreementBtn.tp_y = 40;
    
    copyRightLabel.tp_x = (footerViewW - copyRightLabel.tp_width) / 2;
    copyRightLabel.tp_y = footerViewH - copyRightLabel.tp_height - 24;
}

- (void)setupSettingItems{
    [self.settingArr removeAllObjects];
    
    AboatUsLogoItem *aboatUsLogoItem = [[AboatUsLogoItem alloc]init];
    aboatUsLogoItem.hiddenArrow = YES;
    NormalSettingItem *firstItem = [NormalSettingItem itemWithTitle:@"触宝官网" subTitle:@"www.chubao.cn" badgeTitle:nil handleBlock:^{
        CommonWebViewController* webVC = [[CommonWebViewController alloc] init];
        webVC.url_string = @"http://www.chubao.cn";
        [self.navigationController pushViewController:webVC animated:YES];
    }];
    
    NormalSettingItem *secondItem = [NormalSettingItem itemWithTitle:@"QQ讨论群" subTitle:@"182770766" badgeTitle:nil handleBlock:^{
        
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"已为您复制QQ讨论群，搜索时可直接粘贴。是否立即前往QQ？" message:nil okButtonActionBlock:^(){
            BOOL canOpenWX = [[TouchPalApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
            if (canOpenWX) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = @"182770766";
                [[TouchPalApplication sharedApplication] openURL:[NSURL URLWithString:@"mqq://"]];
            }
            else {
                [[[UIApplication sharedApplication].delegate window]
                 makeToast:@"未检测到安装QQ，若已安装，建议手动打开" duration:3.0 position:nil];
            }
        }cancelActionBlock:^{
            
        }];

        
    }];
    
    NormalSettingItem *thirdItem = [NormalSettingItem itemWithTitle:@"新浪微博" subTitle:@"@通通宝" badgeTitle:nil handleBlock:^{
        CommonWebViewController* webVC = [[CommonWebViewController alloc] init];
        webVC.url_string = @"http://e.weibo.com/touchpalcontacts";
        [self.navigationController pushViewController:webVC animated:YES];
    }];
    
    NormalSettingItem *fourthItem = [NormalSettingItem itemWithTitle:@"官方微信" subTitle:@"touchpal-fan" badgeTitle:nil handleBlock:^{
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"已为您复制公众号，搜索时可直接粘贴。是否立即前往微信？" message:nil okButtonActionBlock:^(){
            BOOL canOpenWX = [[TouchPalApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
            if (canOpenWX) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = @"touchpal-fan";
                [[TouchPalApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
            }
            else {
                [[[UIApplication sharedApplication].delegate window]
                 makeToast:NSLocalizedString(@"wexin_not_found", @"未检测到安装微信，若已安装，建议手动打开") duration:3.0 position:nil];
            }
        }cancelActionBlock:^{
            
        }];

    }];
    
  
    [self.settingArr addObject:@[aboatUsLogoItem,firstItem,secondItem,thirdItem,fourthItem]];
    self.settingTableView.settingArr = self.settingArr;
}



- (void)pushServiceAgreement{
//    CommonWebViewController* webVC = [[CommonWebViewController alloc] init];
//    webVC.url_string = NSLocalizedString(@"http://www.touchpal.com/privacypolicy_contacts.html", @"");
//    webVC.header_title = @"";
//    [self.navigationController pushViewController:webVC animated:YES];
    PrivacyViewController *controller = [[PrivacyViewController alloc]init];
    [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
}

#pragma mark - PersonalCenterTableViewDelegate

- (void)settingTableView:(SettingTableView *)tableView didSelectSettingItem:(SettingItem *)settingModel{
    UIViewController *vc = [[NSClassFromString(settingModel.vcClass) alloc] init];
    
    if (settingModel.handle) {
        settingModel.handle();
    }
    
    if (vc == nil) {
        return;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
