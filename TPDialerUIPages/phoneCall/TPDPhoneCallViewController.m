//
//  TPDPhoneCallViewController.m
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

//menu
#import "TPDSuperSearchViewController.h"
#import "YellowPageWebViewController.h"
#import "AntiharassmentViewController.h"
#import "AntiharassmentViewController_iOS10.h"
#import "GestureSettingsViewController.h"
#import "BtnModel.h"
#import "MenuView.h"
#import "TPScanCardViewController.h"
#import "AllViewController.h"
#import "HandlerWebViewController.h"
#import "NoahToolBarView.h"
#import "VOIPCall.h"
#import "TPDPhoneCallViewController.h"
#import <Masonry.h>
#import "TPDLib.h"
#import "PublicNumberListController.h"
#import <RDVTabBarController.h>
#import <BlocksKit.h>
#import <UIGestureRecognizer+BlocksKit.h>
#import "ReactiveCocoa.h"
#import "TPDCallViewController.h"
#import "Favorites.h"
#import "PhonePadModel.h"
#import "CallLogDataModel.h"
#import "TPCallActionController.h"
#import "ContactSearchModel.h"
#import "CootekNotifications.h"
#import "DateTimeUtil.h"
#import "TPDContactInfoManagerCopy.h"
#import "SmartDailerSettingModel.h"
#import "PhoneNumber.h"
#import "NSString+PhoneNumber.h"
#import "UserDefaultsManager.h"
#import "UserDefaultsManager.h"
#import "TPMFMessageActionController.h"
#import "DialerUsageRecord.h"
#import "TouchPalDialerAppDelegate.h"
#import "FunctionUtility.h"
#import "CallerIDInfoModel.h"
#import "TPABPersonActionController.h"
#import "TPDrawRich.h"
#import "WhereDataModel.h"
#import "DataBaseModel.h"
#import "CallLog.h"
#import "LongGestureOperationView.h"
#import "OperationCommandBase.h"
#import "TPDialerResourceManager.h"
#import "TPDDialerPad.h"
#import "UIDialerSearchHintView.h"
#import "FeedsSigninManager.h"
#import "SignBtnManager.h"
#import "CootekSystemService.h"
#import "TPDContactInfoManagerCopy.h"
#import "NewFeatureGuideManager.h"
#import "VoipUtils.h"
#import "ContactCacheDataManager.h"
#import "BiBiPairManager.h"
#import "NumberPersonMappingModel.h"
#import "ContactInfoUtil.h"
#import "PersonDBA.h"

typedef enum{
    FunctionListTypeNoSearchResult,
    FunctionListTypeSharp,
    FunctionListTypeStar
} FunctionListType;


@interface TPDDialBtn: UIButton
@end

@implementation TPDDialBtn
-(instancetype)init{
    self = [super init];
    if (self) {

        [self setBackgroundImage:[TPDialerResourceManager getImage:@"dialer_view_show_keyboard_icon_normal@2x.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[TPDialerResourceManager getImage:@"dialer_view_show_keyboard_icon_pressed@2x.png"] forState:UIControlStateHighlighted];
        
        WEAK(self)
        [[NSNotificationCenter defaultCenter] addObserverForName:N_SKIN_DID_CHANGE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakself setBackgroundImage:[TPDialerResourceManager getImage:@"dialer_view_show_keyboard_icon_normal@2x.png"] forState:UIControlStateNormal];
            [weakself setBackgroundImage:[TPDialerResourceManager getImage:@"dialer_view_show_keyboard_icon_pressed@2x.png"] forState:UIControlStateHighlighted];
        }];
    }
    return self;
    
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    NSLog(@"x:%lf, y: %lf",point.x,point.y);
    
    double deltaX = point.x - 47;
    double deltaY = point.y - 36;
    if (sqrt(deltaX*deltaX + deltaY*deltaY)<30) {
        return [super hitTest:point withEvent:event];
    }else{
        return nil;
    }
    
}

@end

#define dialBtnShowCenter (CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height - 50))
#define dialBtnHideCenter (CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height + 50))

@interface TPDPhoneCallViewController ()
@property (nonatomic, strong) UIButton* homePageBanner;
@property (nonatomic, strong) UIImageView* topBar;
@property (nonatomic, strong) UIView* navigationView;
@property (nonatomic, strong) UITableViewCell* freeCalltip;
@property (nonatomic, strong) UIView* doubleBtnYunYingView;


@property (nonatomic, strong) UITableView* phoneCallList;
@property (nonatomic, strong) UITableView* searchList;
@property (nonatomic, strong) NSArray* phoneCallListData;
@property (nonatomic, strong) NSArray* searchListData;



@property (nonatomic, strong) UIView* welcomeView;
@property (nonatomic, strong) UIScrollView* functionList;

@property (nonatomic, strong) UIButton* serviceBtn;

@property (nonatomic, strong) UIImageView* bibiImageView;
@property (nonatomic, strong) UIButton* bibiButton;
@property (nonatomic, strong) UITableViewCell* bibiGuideView;
@property (nonatomic, strong) UIView* bibiGuideTriangleView;

@property (nonatomic, strong) TPDDialBtn* expandDialPadBtn;
@property (nonatomic, strong) UIWindow* topWindow;

@property (nonatomic, strong) TPDDialerPad* dialPad;
@property (nonatomic, strong) UIView* gestureGuideView;

@property (nonatomic, strong) ContactSearchModel* engine;


@property (nonatomic, strong) UIView* longPressView; // 长按
@property (nonatomic, strong) NSArray* allPopupSheetCommands;
@property (nonatomic, strong) UIView* maskView;// 长按遮罩

@property (nonatomic, strong) UIDialerSearchHintView* hintView;  // 空白页

@property (nonatomic, strong) MenuView *menu;   // 小熊猫

// 现实所有条目的View
@property (nonatomic, strong) UIView* multiEntryListView;
@property (nonatomic, strong) UIView* multiEntryListViewMaskView;

@property (nonatomic, strong) NSMutableArray* disposableArray;
@end



#import "TPDYunYing.h"

@implementation TPDPhoneCallViewController

#pragma mark 子控件

#pragma mark 子控件 - 显示全部号码
-(void)loadMultiEntryMaskView:(id<BaseContactsDataSource>)dataModel{
    WEAK(self)
    

    NSString* title = @"";
    if (dataModel.personID > 0) {
        if ([dataModel.name length] > 0) {
            title = dataModel.name;
        } else {
            title = dataModel.number;
        }
    }else{
        title = dataModel.number;
    }
    
    NSMutableArray* viewArr = [NSMutableArray array];
    UILabel* titleLine = [[UILabel tpd_commonLabel] tpd_withText:title color:[UIColor blackColor] font:16];
    titleLine.textAlignment = NSTextAlignmentCenter;
    [viewArr addObject:[titleLine tpd_withHeight:44.f]];
    
    NSMutableArray* numbers = [NSMutableArray array];
    if (dataModel.personID > 0) {
        NSArray *phones = [[[ContactCacheDataManager instance] contactCacheItem:dataModel.personID] phones];
        for (PhoneDataModel *phone in phones) {
            [numbers addObject:phone.number];
        }
    }else{
        [numbers addObject:dataModel.number];
    }
    
    for (NSString* number in numbers) {
        UITableViewCell* cell = [UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:j:30:tp_color_grey_600",number,@"",@"iphone-ttf:iPhoneIcon3:i:30:tp_color_grey_600"] action:^(id sender) {
            [weakself.multiEntryListViewMaskView removeFromSuperview];
            [weakself makeCallWithNumber:number];
        }];
        [viewArr addObject:[cell tpd_withHeight:60.f]];
        cell.tpd_img2.userInteractionEnabled = YES;
        [cell.tpd_img2 addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [weakself.multiEntryListViewMaskView removeFromSuperview];
            [TPMFMessageActionController sendMessageToNumber:number
                                                 withMessage:@""
                                                 presentedBy:weakself.rdv_tabBarController];
        }]];
    }
    
    UIButton* cancelBtn = [UIButton tpd_buttonStyleCommon];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal] ;
//    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [viewArr addObject:[cancelBtn tpd_withHeight:44.f]];
    
    self.multiEntryListView = [[[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:viewArr] tpd_withBackgroundColor:[UIColor whiteColor]];
    
    self.multiEntryListViewMaskView = [self.multiEntryListView tpd_maskViewContainer:^(id sender) {
        
    }];
    
    [self.topWindow addSubview:self.multiEntryListViewMaskView];
    [self.multiEntryListViewMaskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topWindow);
    }];
    
    [self.multiEntryListView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.multiEntryListViewMaskView);
    }];
    
    [cancelBtn tpd_withBlock:^(id sender) {
        [weakself.multiEntryListViewMaskView removeFromSuperview];
    }];
}

#pragma mark 子控件 - 双按钮运营位
-(void)loadDoubleBtnYunYing{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        TPDYunYingItem* item = [TPDYunYing getYunYingByPosition:YunYinPositionCallLog];
        if (item == nil || VALUE_IN_DEFAULT(item.ad_id) != nil) {
            // 如果没拉过，或者已经展示过并被用户点掉
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.doubleBtnYunYingView removeFromSuperview];
            WEAK(self)
            
            UIView* alertView = [[UIView alloc] init];
            UILabel* title = [[UILabel tpd_commonLabel] tpd_withText:@"触宝提示" color:RGB2UIColor2(51, 51, 51) font:20];
            UILabel* text = [[UILabel tpd_commonLabel] tpd_withText:item.desc color:RGB2UIColor2(102, 102, 102) font:16];
            UIButton* btn1 = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
                [weakself.doubleBtnYunYingView removeFromSuperview];
                //                SET_VALUE_IN_DEFAULT(@"shown", item.ad_id)
                YellowPageWebViewController* vc = [[YellowPageWebViewController alloc] init];
                vc.url_string = item.reserved.url1;
                [weakself.navigationController pushViewController:vc animated:YES];
            }];
            [btn1 setTitle:item.reserved.button1 forState:UIControlStateNormal];
            [btn1 setTitleColor:RGB2UIColor2(153, 153, 153) forState:UIControlStateNormal];
            [[btn1 tpd_withBorderWidth:.5f color:RGB2UIColor2(153, 153, 153)] tpd_withCornerRadius:5.f];
            
            [alertView addSubview:title];
            [alertView addSubview:text];
            [alertView addSubview:btn1];
            
            [title makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(alertView);
                make.top.equalTo(alertView).offset(30);
            }];
            [text makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(alertView);
                make.top.equalTo(title.bottom).offset(20);
                make.width.equalTo(alertView).offset(-60);
            }];
            if (item.reserved.button2 != nil) {
                UIButton* btn2 = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
                    [weakself.doubleBtnYunYingView removeFromSuperview];
                    //                SET_VALUE_IN_DEFAULT(@"shown", item.ad_id)
                    YellowPageWebViewController* vc = [[YellowPageWebViewController alloc] init];
                    vc.url_string = item.reserved.url2;
                    [weakself.navigationController pushViewController:vc animated:YES];
                }];
                [self.doubleBtnYunYingView addSubview:btn2];
                [btn2 setTitle:item.reserved.button2 forState:UIControlStateNormal];
                [btn2 setTitleColor:RGB2UIColor2(3, 169, 244) forState:UIControlStateNormal];
                [[btn2 tpd_withBorderWidth:.5f color:RGB2UIColor2(3, 169, 244)] tpd_withCornerRadius:.5f];
                
                [btn1 makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(alertView.centerX).offset(-30);
                    make.top.equalTo(text.bottom).offset(30);
                    make.size.equalTo(CGSizeMake(100, 40));
                }];
                [btn2 makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(alertView.centerX).offset(30);
                    make.top.equalTo(text.bottom).offset(30);
                    make.size.equalTo(CGSizeMake(100, 40));
                }];
            }else{
                [btn1 makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(alertView);
                    make.top.equalTo(text.bottom).offset(30);
                    make.size.equalTo(CGSizeMake(100, 40));
                    make.bottom.equalTo(alertView).offset(-20);
                }];
            }
            
            
            self.doubleBtnYunYingView = [alertView tpd_maskViewContainer:^(id sender) {
                weakself.doubleBtnYunYingView.hidden = YES;
                //                SET_VALUE_IN_DEFAULT(@"shown", item.ad_id)
            }];
            
            
            [self.topWindow addSubview:self.doubleBtnYunYingView];
            [self.doubleBtnYunYingView makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.topWindow);
            }];
            
            [alertView makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.doubleBtnYunYingView);
                make.width.equalTo(self.doubleBtnYunYingView).offset(-100);
            }];
            [[alertView tpd_withCornerRadius:10.f] tpd_withBackgroundColor:[UIColor whiteColor]];
            self.doubleBtnYunYingView.tpd_maskView.alpha = .7f;
        });
        
    });
    
}

#pragma mark BiBi
-(void)createBiBiView{
    self.bibiGuideTriangleView = [UIImageView tpd_imageView:@"light_dial_notification_triangle@3x.png"];
    
    self.bibiGuideView = [UITableViewCell tpd_tableViewCellStyle1:@[@"a",@"",@"",@""]
                                                           action:^(id sender) {
                                                               [DialerUsageRecord recordCustomEvent:PATH_BIBI_GUIDE_CLICK];
                                                               [self pushBiBiGuideWebview];
                                                           }];
    [self.bibiGuideView setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"]];
    
    [self.bibiGuideView.tpd_img1 tpd_withSize:CGSizeMake(36, 36)];
    [self.bibiGuideView.tpd_img1 tpd_withCornerRadius:18];
    self.bibiGuideView.tpd_label1.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    
    
    UIButton* btn = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        [DialerUsageRecord recordCustomEvent:PATH_BIBI_GUIDE_CLICK];
        [self pushBiBiGuideWebview];
    }];
    [btn tpd_withSize:CGSizeMake(60,30)];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    CGRect rect= CGRectMake(0, 0, 60, 30);
    [btn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"]
              forState:UIControlStateNormal];
    [btn setTitle:NSLocalizedString(@"bibi_guide_go","认领") forState:UIControlStateNormal];
    [btn setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_pink_400"
                                                               withFrame:rect]
                   forState:UIControlStateNormal];
    [btn setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_pink_600"
                                                               withFrame:rect]
                   forState:UIControlStateHighlighted];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 15;
    [self.bibiGuideView addSubview:btn];
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bibiGuideView);
        make.right.equalTo(self.bibiGuideView.right).offset(-18);
    }];
    
    [self.bibiGuideView.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bibiGuideView.tpd_img1.left).offset(46);
        make.right.lessThanOrEqualTo(btn.left);
    }];
    
    self.bibiButton = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        [DialerUsageRecord recordCustomEvent:PATH_BIBI_ICON_CLICK];
        [self pushBiBiGuideWebview];
    }];
    self.bibiImageView = [[UIImageView alloc] init];
    self.bibiImageView.layer.cornerRadius = 14;
    self.bibiImageView.layer.masksToBounds = YES;
    [self.bibiButton addSubview:self.bibiImageView];
    
}

- (void)refreshBiBiView {
    NSString *number = [[BiBiPairManager manager] recommendNumber];
    if (number != nil) {
        int personId = [NumberPersonMappingModel getCachePersonIDByNumber:number];
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        NSString *display = number;
        if (personData) {
            display = personData.displayName;
        }
        UIImage *photo = personData.image ?  personData.image : [[BiBiPairManager manager] defualtBibiPhoto];
        self.bibiButton.hidden = !self.dialPad.hidden;
        [self.bibiImageView setImage:photo];
        [DialerUsageRecord recordCustomEvent:PATH_BIBI_ICON_SHOW];
        BOOL showBiBiGuide = [[BiBiPairManager manager] canShowBibiGuide];
        if(showBiBiGuide) {
             [DialerUsageRecord recordCustomEvent:PATH_BIBI_GUIDE_SHOW];
        }
        [self setBiBiGuidleViewHidden:!(showBiBiGuide && self.dialPad.hidden)];
        [self.bibiGuideView.tpd_img1.cast2UIImageView setImage:photo];
        NSString *desc = [NSString stringWithFormat:@" · %@",NSLocalizedString(@"bibi_guide_desc","认领")];
        display = [NSString stringWithFormat:@"%@%@",display,desc];
        NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:desc
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];
        [self.bibiGuideView.tpd_label1 tpd_withAttributedText:display
                                        normalColor:RGB2UIColor2(26, 26, 26)
                                         normalFont:[UIFont systemFontOfSize:17]
                                     highlightColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"]
                                      highlightFone:[UIFont systemFontOfSize:14] ofPattern:reg];
        
    } else {
        self.bibiButton.hidden = YES;
        [self setBiBiGuidleViewHidden:YES];
    }
}

- (void)pushBiBiGuideWebview {
    [self setBiBiGuidleViewHidden:YES];
    [[BiBiPairManager manager] pushBibiWebController:self.navigationController];
}

- (void)setBiBiGuidleViewHidden:(BOOL)hidden {
    self.bibiGuideTriangleView.hidden = hidden;
    self.bibiGuideView.hidden = hidden;
    int height = hidden ? 0 : 66;
    [self.bibiGuideView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(height);
    }];
    
}


#pragma mark 子控件 - 小熊猫

- (void)loadViewMenu {

    [self.menu removeFromSuperview];
    [self.menu.maskView removeFromSuperview];
    
    NSMutableArray *contentArray = [NSMutableArray new] ;
    NSMutableArray *block = [NSMutableArray new];
    
    for (int i = 0 ; i < 3; i ++) {
        BtnModel *m = [[BtnModel alloc]init];
        m.isNew = YES;
        switch (i) {
             case 0:{
                 m = [self AntiharassCall];
                 break;
            }
            case 1:{
                 m = [self scanCard];
                break;
            }
            case 2:
                m = [self superSearch];
                break;
                
            default:
                break;
        }
        [contentArray addObject:m];
        [block addObject:[m.blockItem copy]];
    }
    
    self.menu = [MenuView MenuInitialWithArray:contentArray Delegate:self BlockArray:block changeStatusBlock:^(BOOL isShow) {
        
    }];
    
    
    [self.rdv_tabBarController.view addSubview:self.menu.maskView];
    [self.rdv_tabBarController.view addSubview:self.menu];
    
    [self.menu.maskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.rdv_tabBarController.view);
    }];

}
//亲情号
- (BtnModel *)familyCall {
    BtnModel *m = [BtnModel new];
    m.title = @"f";
    m.blockItem = ^{
        YellowPageWebViewController *controller = [[YellowPageWebViewController alloc] init];
        controller.needTitle = YES;
        if ([AllViewController getNumberArrarFromBindsuccessListArray].count>0 && [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] != nil) {
            controller.url_string = @"http://dialer.cdn.cootekservice.com/web/internal/activities/family-num-bind/bind-detail.html";
            [UserDefaultsManager setObject:[NSDate date] forKey:CONTACT_FAMILY_GUIDE_CLICK_DATE];
            
        } else {
            controller.url_string = @"http://dialer.cdn.cootekservice.com/web/internal/activities/family-num-bind/index.html";
        }
        [self.navigationController pushViewController:controller animated:YES];
        self.menu.maskView.hidden = YES;
    };
    return m;
}
//防骚扰
- (BtnModel *)AntiharassCall {
    BtnModel *m = [BtnModel new];
    m.title = @"R";
    m.image1 = @"assistant_Antiharass";
    m.image2 = @"assistant_Antiharass_highlight";
    m.blockItem = ^{
        if ([FunctionUtility is64bitAndIOS10]) {
            AntiharassmentViewController_iOS10 *blockController = [[AntiharassmentViewController_iOS10 alloc] init];
            [self.navigationController pushViewController:blockController animated:YES];
        } else {
            AntiharassmentViewController *blockController = [[AntiharassmentViewController alloc] init];
            [self.navigationController pushViewController:blockController animated:YES];
            
        }
        self.menu.maskView.hidden = YES;
        
    };
    return m;
}
//扫卡
- (BtnModel *)scanCard {
    BtnModel *m = [BtnModel new];
    m.title = @"v";
    m.image1 = @"assistant_scancard";
    m.image2 = @"assistant_scancard_highlight";
    
    m.blockItem = ^{
        [DialerUsageRecord recordpath:PATH_SCANCARD
                                  kvs:Pair(CONTACT_SCANCARD_ENTRANCE_CLICK, @(1)), nil];
        [self.navigationController pushViewController:[TPScanCardViewController new] animated:YES];
        self.menu.maskView.hidden = YES;
    };
    return m;
}
//超级搜索
- (BtnModel *)superSearch {
    BtnModel *m = [BtnModel new];
    m.title = @"m";
    m.image1 = @"assistant_yellowpage";
    m.image2 = @"assistant_yellowpage_highlight";
    m.blockItem = ^{
        [DialerUsageRecord recordpath:PATH_CONTACT_VERSIONSiXLATER
                                  kvs:Pair(PATH_CONTACT_VERSIONSiXLATER_SUPERSEARCHCLICK, @(1)), nil];
        TPDSuperSearchViewController *blockController = [TPDSuperSearchViewController new];
        [self.navigationController pushViewController:blockController animated:YES];
        self.menu.maskView.hidden = YES;
    };
    return m;
}

-(void)configurePanda:(BOOL)keypadShow{
    
    // 在黄页上打电话会被call到，导致布局crash
    // 在超级搜索上打电话会被call到，导致布局crash
    
    
    if (self == [UIViewController tpd_topViewController]) {
        
        if (keypadShow) {
            [self.menu updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.dialPad.top).offset(80);
                make.right.equalTo(self.rdv_tabBarController.view.right).offset(34);
            }];
            
            if ([UIScreen mainScreen].bounds.size.height < 570) {
                self.menu.hidden = YES;
            }else{
                self.menu.hidden = NO;
            }
        }else{
            [self.menu updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.dialPad.top).offset(0);
                make.right.equalTo(self.rdv_tabBarController.view.right).offset(34);
            }];
            self.menu.hidden = NO;
        }
    }
    
}

#pragma mark 子控件 - inApp运营位
-(void)loadInAppCell{
    // no perform
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        TPDYunYingItem* item = [TPDYunYing getYunYingByPosition:YunYinPositionInApp];
        if (item == nil || VALUE_IN_DEFAULT(item.ad_id) != nil) {
            // 如果没拉过，或者已经展示过并被用户点掉
            return;
        }
        double now = [[NSDate date] timeIntervalSince1970];
        if (now < item.reserved.start || now > item.reserved.start + item.reserved.duration) {
//            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            WEAK(self)
            NSString* arrowName = item.reserved.hasClose?@"iphone-ttf:iPhoneIcon4:G:25:skinPushMessageText_color":
            (item.reserved.hasArrow?@"iphone-ttf:iPhoneIcon4:K:25:skinPushMessageText_color":@"");
            
            [self.freeCalltip removeFromSuperview];
            self.freeCalltip = [UITableViewCell tpd_tableViewCellStyle1:@[item.material,item.title,@"",arrowName] action:^(id sender) {
                YellowPageWebViewController* vc = [[YellowPageWebViewController alloc] init];
                vc.url_string = item.reserved.url;
                [weakself.navigationController pushViewController:vc animated:YES];
                [weakself.freeCalltip removeFromSuperview];
            }];
            [self.view addSubview:self.freeCalltip];
            [self.freeCalltip makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self.phoneCallList);
                make.height.equalTo(44);
            }];
            self.freeCalltip.tpd_img2.userInteractionEnabled = YES;
            [self.freeCalltip.tpd_img2 addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                [weakself.freeCalltip removeFromSuperview];
            }]];
            self.freeCalltip.backgroundColor = [UIColor colorWithHexString:@"0x000000" alpha:0.81];
            self.freeCalltip.tpd_label1.textColor = [TPDialerResourceManager getColorForStyle:@"skinPushMessageText_color"];
            
            
            [self.freeCalltip.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.freeCalltip).offset(-50);
                make.left.equalTo(self.freeCalltip.tpd_img1.left).offset(40);
            }];
            
            [self.freeCalltip.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(30);
                
            }];

            
        });
        
    });
}

#pragma mark 子控件 - #号和*号菜单
-(void)generateFunctionalList:(FunctionListType)type{
    WEAK(self)
    [self.functionList.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UITableViewCell* cell1 = [UITableViewCell tpd_tableViewCellStyle1:@[@"dailer_item_paste_number@2x.png",@"粘帖剪贴板中的号码",@"",@""] action:^(id sender) {
        [weakself.dialPad pasteNum];
    }];
    [cell1.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell1.tpd_img1).offset(50);
    }];
    
    UITableViewCell* cell2 = [UITableViewCell tpd_tableViewCellStyle1:@[@"dailer_item_send_message@2x.png",@"发短信",@"",@""] action:^(id sender) {
        PhonePadModel* shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
        [weakself sendMessage:[PhonePadModel ABC2Num:shared_phonepadmodel.input_number]];
        [weakself clearInput];
        [weakself showKeyPad:NO];
    }];
    [cell2.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell2.tpd_img1).offset(50);
    }];
    
    UITableViewCell* cell3 = [UITableViewCell tpd_tableViewCellStyle1:@[@"dailer_item_add_contact@2x.png",@"新建联系人",@"",@""] action:^(id sender) {
        PhonePadModel* shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
        NSString *numStr = [PhonePadModel ABC2Num:shared_phonepadmodel.input_number];
        [weakself addContact:numStr];
        
    }];
    [cell3.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell3.tpd_img1).offset(50);
    }];
    
    UITableViewCell* cell4= [UITableViewCell tpd_tableViewCellStyle1:@[@"dailer_item_add_contact@2x.png",@"添加到现有联系人",@"",@""] action:^(id sender) {
        PhonePadModel* shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
        NSString *numStr = [PhonePadModel ABC2Num:shared_phonepadmodel.input_number];
        
        [weakself addToExistingContact:numStr];
        
        
    }];
    [cell4.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell4.tpd_img1).offset(50);
    }];
    
    UITableViewCell* cell5= [UITableViewCell tpd_tableViewCellStyle1:@[@"dailer_item_change_keyboard@2x.png",@"切换到全键盘",@"",@""] action:^(id sender) {
        if( self.dialPad.numPad.hidden){
            [weakself.dialPad showAllKeys:NO];
            [weakself.dialPad research:@""];
        }else{
            [weakself.dialPad showAllKeys:YES];
            [weakself.dialPad research:@""];
        }
        
    }];
    [cell5.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell5.tpd_img1).offset(50);
    }];
    if (self.dialPad.numPad.hidden) {
        cell5.tpd_label1.text = @"切换到9键（数字键盘）";
    }
    
    UIView* innerView = nil;
    if (type == FunctionListTypeSharp) {
        NSArray* viewArr = @[
                             [cell1 tpd_withHeight:66],
                             [cell2 tpd_withHeight:66],
                             [cell3 tpd_withHeight:66],
                             [cell4 tpd_withHeight:66],
                             ];
        innerView = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:viewArr offsets:@[@0,@0,@0,@0]];
    }else if(type == FunctionListTypeStar){
        NSArray* viewArr = @[
                             [cell5 tpd_withHeight:66],
                             [cell2 tpd_withHeight:66],
                             [cell3 tpd_withHeight:66],
                             [cell4 tpd_withHeight:66],
                             ];
        innerView = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:viewArr offsets:@[@0,@0,@0,@0]];
    }else{
        NSArray* viewArr = @[
                             [cell2 tpd_withHeight:66],
                             [cell3 tpd_withHeight:66],
                             [cell4 tpd_withHeight:66],
                             ];
        innerView = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:viewArr offsets:@[@0,@0,@0]];
    }
    //    innerView.userInteractionEnabled = NO;
    [self.functionList addSubview:innerView];
    self.functionList.alwaysBounceVertical = YES;
    [innerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.bottom.equalTo(self.functionList);
    }];
    //    self.functionList.delaysContentTouches = YES;
    //    self.functionList.canCancelContentTouches
}


#pragma mark 子控件 - 长按菜单
-(void)cancelLongPress{
    if (self.maskView != nil)
    {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.phoneCallList.hidden == NO) {
                [self.phoneCallList reloadData];
            }else if (self.searchList.hidden == NO){
                [self.searchList reloadData];
            }
        });
    }
    
}





-(void)showSheet:(id)dataModel{
    WEAK(self)
    
    CallLogDataModel* d = dataModel;
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    UITableViewCell* topCell = [[[[UITableViewCell tpd_tableViewCellStyleImageLabel2:@[isVersionSix ? @"common_photo_contact_for_list@2x.png" : @"common_photo_contact_big@2x.png", @"12312", @"上海联通"] action:^(id sender) {
    } reuseId:@"TPDLongPressActionSheetCell"] tpd_withHeight:66] tpd_withCornerRadius:10.f] tpd_withBackgroundColor:[UIColor whiteColor]].cast2UITableViewCell;
    
    [topCell.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(40);
    }];
    [topCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topCell).offset(-20);
    }];
    
    
    
    [topCell.tpd_img1 tpd_withCornerRadius:20.f];
    topCell.tpd_img1.backgroundColor = RGB2UIColor2(217,217,217);
    
    if ([dataModel isKindOfClass:[SearchItemModel class]]) {
        [self configNumberLabelForSearch:topCell.tpd_label2 callModel:dataModel];
        [self configNameLabelForSearch:topCell.tpd_label1 callModel:dataModel];
    }else{
        [self configNameLabel:topCell.tpd_label1 callModel:((CallLogDataModel*)dataModel)];
        [self configNumberLabel:topCell.tpd_label2 callModel:((CallLogDataModel*)dataModel)];
    }
    
    UITableViewCell* callCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:j:30:tp_color_grey_600",@"呼叫",@"",@""] action:^(id sender) {
        [weakself cancelLongPress];
        [weakself makeCallWithMultiEntry:dataModel];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [callCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(callCell.tpd_img1).offset(50);
    }];
    [callCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* smsCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon5:B:30:tp_color_grey_600",@"短信",@"",@""] action:^(id sender) {
        [weakself sendMessage:d.number];
        [weakself clearInput];
        [weakself showKeyPad:NO];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [smsCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(smsCell.tpd_img1).offset(50);
    }];
    [smsCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* copyNumCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon5:e:30:tp_color_grey_600",@"复制号码",@"",@""] action:^(id sender) {
        [weakself cancelLongPress];
        [weakself copyPhoneNumber:dataModel];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [copyNumCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(copyNumCell.tpd_img1).offset(50);
    }];
    [copyNumCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    
    UITableViewCell* newContactCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:i:30:tp_color_grey_600",@"新建联系人",@"",@""] action:^(id sender) {
        [weakself addContact:d.number];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [newContactCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(newContactCell.tpd_img1).offset(50);
    }];
    [newContactCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    UITableViewCell* addContactCell = [[UITableViewCell tpd_tableViewCellStyle1:@[@"iphone-ttf:iPhoneIcon4:e:30:tp_color_grey_600",@"添加到现有联系人",@"",@""] action:^(id sender) {
        [weakself addToExistingContact:d.number];
    }] tpd_withHeight:66].cast2UITableViewCell;
    [addContactCell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addContactCell.tpd_img1).offset(50);
    }];
    [addContactCell.tpd_container setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor(0xeeeeee)] forState:UIControlStateHighlighted];
    
    NSArray* displayedCells = nil;
    
    if ([[dataModel name] length] > 0) {
        displayedCells = @[[callCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[smsCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[copyNumCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)]];
    }else{
        displayedCells = @[[callCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[smsCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[copyNumCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[newContactCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)],[addContactCell tpd_seperateLineWithEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)]];
    }
    
    
    UIView* wrapper = [[[[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:displayedCells offsets:@[@0,@0,@0,@0,@0]] tpd_withCornerRadius:10.f] tpd_withBackgroundColor:[UIColor whiteColor]];
    
    
    UIView* wrapper2 = [[[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[topCell, wrapper] offsets:@[@0,@15]] tpd_wrapperWithEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    
    self.maskView = [wrapper2 tpd_maskViewContainer:^(id sender) {
        [weakself cancelLongPress];
    }];
    
    
    [wrapper2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.maskView);
        make.top.equalTo(self.maskView.bottom);
    }];
    
    [self.topWindow addSubview:self.maskView];
    
    [self.maskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.topWindow);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wrapper2 remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.maskView);
        }];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.maskView layoutIfNeeded];
        } completion:^(BOOL finished){
            
        }];
    });
}

#pragma mark 欢迎页
- (void)loadWelcomeView {
    
    UIScrollView *wrapperView = [UIScrollView new];
    
    UIImageView *imageView = [[[UIImageView new] tpd_withSize:CGSizeMake(260, 240)] tpd_withBackgroundColor:[UIColor clearColor]].cast2UIImageView;
    imageView.image = [UIImage imageNamed:@"welcoming.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIView *mentionView = [UIView new];
    UIImageView *mentionImage = [UIImageView new] ;
    mentionImage.image = [UIImage imageNamed:@"welcome_icon.png"];
    
    UILabel *mentionLabel = [[UILabel new] tpd_withText:@"您可以这样开启触宝之旅" color:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"] font:16];
    mentionLabel.numberOfLines = 2;
    mentionLabel.textAlignment = NSTextAlignmentCenter;
    
    NSArray *nameArray = @[@"学习拨打免费电话",@"开启骚扰电话识别"];
    
    UIButton *setLimitButton = [[[[[UIButton buttonWithType:UIButtonTypeSystem] tpd_withSize:CGSizeMake(200, 50)]tpd_withBackgroundColor:[UIColor whiteColor]] tpd_withCornerRadius:25] tpd_withBorderWidth:1 color:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"]].cast2UIButton;
    [setLimitButton setTitle:nameArray[0] forState:UIControlStateNormal];
    [setLimitButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"] forState:UIControlStateNormal];
    [setLimitButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
        //to do
        [DialerUsageRecord recordpath:PATH_CALLLOG_EMPTY kvs:Pair(CALLLOG_EMPTY_CLICK_LEARN, @(1)), nil];
        HandlerWebViewController *controller = [[HandlerWebViewController alloc] init];
        controller.url_string = [NSString stringWithFormat:@"http://%@", VOIP_GUIDE_URL_PATH];
        [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
        
    }];
    
    UIButton *transferButton = [[[[[UIButton buttonWithType:UIButtonTypeSystem] tpd_withSize:CGSizeMake(200, 50)]tpd_withBackgroundColor:[UIColor whiteColor]] tpd_withCornerRadius:25] tpd_withBorderWidth:1 color:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"]].cast2UIButton;
    [transferButton setTitle:nameArray[1] forState:UIControlStateNormal];
    [transferButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"] forState:UIControlStateNormal];
    [transferButton addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
        //to do
        if ([FunctionUtility is64bitAndIOS10]) {
            AntiharassmentViewController_iOS10 *blockController = [[AntiharassmentViewController_iOS10 alloc] init];
            [self.navigationController pushViewController:blockController animated:YES];
        } else {
            AntiharassmentViewController *blockController = [[AntiharassmentViewController alloc] init];
            [self.navigationController pushViewController:blockController animated:YES];
            
        }
        
    }];
    
    UIView* dummyView = [[UIView new] tpd_withHeight:44.f];
    
    UIView* wrapper = [UIView new];
    [[wrapper tpd_addSubviewsWithVerticalLayout:@[[imageView  tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment],
                                                  [mentionView tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment],
                                                  [setLimitButton tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment],
                                                  [transferButton tpd_wrapperWithStyle:WrapperStyleHeightEqual|WrapperStyleWidthGreater| WrapperStyleCenterXAlignment],
                                                  dummyView]
                                        offsets:@[@40,@0,@28,@16,@0]]
     tpd_withBackgroundColor:[UIColor clearColor]];
    setLimitButton.superview.userInteractionEnabled = YES;
    transferButton.superview.userInteractionEnabled = YES;
    
    [mentionView addSubview:mentionImage];
    [mentionView addSubview:mentionLabel];
    
    [wrapperView addSubview:wrapper];
    
    [mentionImage makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(mentionView);
        make.width.height.equalTo(20);
    }];
    [mentionLabel updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(18);
        make.centerY.equalTo(mentionImage);
        make.left.equalTo(mentionImage.right).offset(8);
        make.right.equalTo(mentionView);
    }];
    [wrapper makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(wrapperView);
        make.centerX.width.equalTo(wrapperView);
    }];
    
    wrapperView.backgroundColor = [UIColor whiteColor];
    wrapperView.showsVerticalScrollIndicator = NO;
    wrapperView.showsHorizontalScrollIndicator = NO;
    
    self.welcomeView = wrapperView;
    
    
    BOOL isNewInstall = [UserDefaultsManager stringForKey:VERSION_JUST_BEFORE_UPGRADE defaultValue:nil] == nil;
    if (isNewInstall) {
        if (![UserDefaultsManager boolValueForKey:NEW_INSTALL_FOR_EMPTY_CALLLOG_CHECKED defaultValue:NO]) {
            [self.view addSubview:self.welcomeView];
            [self.welcomeView makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.phoneCallList);
            }];
        }
    }
    

}
#pragma mark header部分
-(void)createHeaderPart{
    WEAK(self)
    self.homePageBanner = [[[[UILabel tpd_commonLabel] tpd_withText:@"广告占位示例" color:[UIColor whiteColor] font:15] tpd_wrapper] tpd_wrapperWithButton];
    self.homePageBanner.backgroundColor = [UIColor orangeColor];
    self.homePageBanner.clipsToBounds = YES;
    
    self.topBar = [[UIImageView alloc] init];
    [self.topBar setImage:[TPDialerResourceManager getImage:@"common_header_bg@2x.png"]];
    
    self.navigationView = [[[[UILabel tpd_commonLabel] tpd_withText:@"最近拨出" color:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] font:16] tpd_wrapper] tpd_withHeight:44];
    self.navigationView.clipsToBounds = YES;
    
    self.serviceBtn = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        PublicNumberListController* vc = [[PublicNumberListController alloc] init];
        [weakself.navigationController pushViewController:vc animated:YES];
    }];
    [self.serviceBtn setTitle:@"F" forState:UIControlStateNormal];
    [self.serviceBtn.titleLabel setFont:[UIFont fontWithName:@"iPhoneIcon5" size:34]];
    [self.serviceBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"] forState:UIControlStateNormal];
    [self.serviceBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_ht_color"] forState:UIControlStateHighlighted];
    
    [self createBiBiView];
    
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.bibiGuideView];
    [self.topBar addSubview:self.bibiGuideTriangleView];
    [self.topBar addSubview:self.navigationView];
    [self.view addSubview:self.serviceBtn];
    [self.view addSubview:self.bibiButton];
    [self.view addSubview:self.homePageBanner];
    
    [self.topBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(64);
    }];
    
    [self.navigationView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.topBar);
    }];
    
    [self.bibiGuideView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(66);
        make.top.equalTo(self.topBar.bottom);
        make.left.right.equalTo(self.view);
    }];
    
    [self.bibiButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.topBar);
        make.width.equalTo(80);
    }];
    
    [self.bibiImageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bibiGuideView.tpd_img1.centerX);
        make.width.equalTo(28);
        make.height.equalTo(28);
        make.centerY.equalTo(self.navigationView.centerY);
    }];
    
    [self.bibiGuideTriangleView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topBar.bottom);
        make.centerX.equalTo(self.bibiImageView.centerX);
    }];
    
    [self.serviceBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(self.navigationView);
    }];
    
}
#pragma mark body部分
-(void)createBodyPart{
    self.phoneCallListData = @[];
    self.searchListData = @[];
    
    self.hintView = [[UIDialerSearchHintView alloc] initWithFrame:self.view.frame];
    self.phoneCallList = [self tpd_tableViewOfController];
    
    self.searchList = [self tpd_tableViewOfController];
    
    self.functionList = [[UIScrollView alloc] init];
    self.functionList.delegate = self;
    
    [self.phoneCallList reloadData];
    self.phoneCallList.backgroundColor = [UIColor whiteColor];
    self.searchList.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.hintView];
    
    [self.view addSubview:self.phoneCallList];
    [self.view addSubview:self.searchList];
    [self.view addSubview:self.functionList];
    
    [self.phoneCallList makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.greaterThanOrEqualTo(self.bibiGuideView.bottom).priorityHigh();
        make.top.greaterThanOrEqualTo(self.homePageBanner.bottom).priorityHigh();
        make.top.equalTo(self.bibiGuideView.bottom).priorityMedium();
        make.top.equalTo(self.homePageBanner.bottom).priorityMedium();
        make.bottom.equalTo(self.view);
    }];
    
    [self.hintView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.functionList);
        make.size.equalTo([UIScreen mainScreen].bounds.size);
    }];
    
    
    [self.searchList makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.phoneCallList);
    }];
    
    
    
    [self.functionList makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.phoneCallList);
    }];
    
    
    
    
    [self loadWelcomeView];
    
    self.phoneCallList.hidden = NO;
    self.phoneCallList.delaysContentTouches = NO;
    self.searchList.hidden = YES;
    self.functionList.hidden = YES;
}

#pragma mark 子控件配置

// 切换皮肤后需重建UI
-(void)reloadUI{
    // 先做清理工作
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (RACDisposable* d in self.disposableArray) {
        [d dispose];
    }
    [self.disposableArray removeAllObjects];
    
    WEAK(self)
    
    self.view.backgroundColor = [UIColor whiteColor];

    
    [self createHeaderPart];
    [self createBodyPart];

    self.dialPad = [[TPDDialerPad alloc] init];
    self.dialPad.delegate = self;
    self.topWindow = [UIView tpd_topWindow];
    
    [self layoutAdBar:nil];
    
    [self.view addSubview:self.dialPad];
    [self.dialPad remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset([UIScreen mainScreen].bounds.size.height-49);
    }];
    self.dialPad.hidden = YES;

    
    
    
    
    

    
    [self.disposableArray addObject:[self.dialPad.inputChangeSignal subscribeNext:^(id x) {
        [weakself reSearch:x];
        if (x == nil || [x isEqualToString:@""]) {
            weakself.welcomeView.hidden = NO;
        }else{
            weakself.welcomeView.hidden = YES;
        }
    }]];
    
    
    [self.disposableArray addObject:[[GlobalVariables getInstance].applicationDidBecomeActiveSignal subscribeNext:^(id x) {
        // 拨打完普通电话回来后，applicationDidEnterForeground被call，重新搜索calllog
        [weakself reSearch:nil];
    }]];
    
    [self.disposableArray addObject:[[GlobalVariables getInstance].enterCallPageSignal subscribeNext:^(id x) {
        // 一旦拨打电话，这里就会call到，要清除输入（包含重新搜索），收起拨号盘
        [weakself clearInput];
        [weakself showKeyPad:NO];
        NSLog(@"%@", NSStringFromClass([weakself.navigationController.topViewController class]));
        
        // 修复：在联系人详情页进入打电话页面会弹出tab的bug
        if (!(weakself.navigationController.topViewController == weakself) && weakself.rdv_tabBarController.selectedIndex == 0) {
            weakself.rdv_tabBarController.tabBarHidden = YES;
            [weakself showDialBtn:NO];
        }
        
        [UserDefaultsManager setBoolValue:YES forKey:NEW_INSTALL_FOR_EMPTY_CALLLOG_CHECKED];
        [weakself.welcomeView removeFromSuperview];
//        [UIViewController tpd_topViewController]
    }]];
    
    self.gestureGuideView = [self.dialPad generateGestureGuideMaskView];
    [self.view insertSubview:self.gestureGuideView belowSubview:self.dialPad];
    
//    [self loadInAppCell];
    
    [self createDialBtn];
    
    
}

-(void)setupNotifications{
    WEAK(self)
    [[NSNotificationCenter defaultCenter] addObserverForName:N_CALL_LOG_LIST_CHANGED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakself searchEndCallback];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:N_SKIN_DID_CHANGE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakself reloadUI];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FIRST_GESTURE_USE" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakself.rdv_tabBarController setSelectedIndex:0];
        [weakself showKeyPad:YES];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BIBI_CALL_OUT" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakself clearInput];
        [weakself showKeyPad:NO];
    }];
}

-(void)configureTab{
    WEAK(self)
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        NSLog(@"%d", state);
        if (state == UIGestureRecognizerStateEnded) {
            if (weakself.rdv_tabBarController.selectedIndex == 0) {
                [weakself showKeyPad:YES];
            }else{
                [weakself.rdv_tabBarController setSelectedIndex:0];
            }
        }
        
        //
        
    }];
    //    tap.numberOfTapsRequired = 2.f;
    tap.delaysTouchesBegan = YES;
    tap.cancelsTouchesInView = YES;
    [self.rdv_tabBarItem addGestureRecognizer:tap];
}

-(void)searchEndCallback{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"weyl: in dispatch");
        
        PhonePadModel* shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
        if ([shared_phonepadmodel.input_number isEqualToString:@""]) {
            if (shared_phonepadmodel.calllog_list.searchResults.count > 0) {
                self.phoneCallList.hidden = NO;
                self.searchList.hidden = YES;
                self.functionList.hidden = YES;
                self.phoneCallListData = [shared_phonepadmodel.calllog_list.searchResults copy];
                [self.phoneCallList reloadData];
                self.hintView.hidden = YES;
                
            }else{
                self.phoneCallList.hidden = YES;
                self.searchList.hidden = YES;
                self.functionList.hidden = YES;
                self.hintView.hidden = NO;
            }
            
        }else if(shared_phonepadmodel.calllog_list.searchResults.count > 0){
            self.phoneCallList.hidden = YES;
            self.searchList.hidden = NO;
            self.functionList.hidden = YES;
            self.searchListData = [shared_phonepadmodel.calllog_list.searchResults copy];
            [self.searchList reloadData];
            self.hintView.hidden = YES;
        }else{
            self.phoneCallList.hidden = YES;
            self.searchList.hidden = YES;
            self.functionList.hidden = NO;
            if([shared_phonepadmodel.input_number rangeOfString:@"#"].location!=NSNotFound){
                [self generateFunctionalList:FunctionListTypeSharp];
            }else if([shared_phonepadmodel.input_number rangeOfString:@"*"].location!=NSNotFound){
                [self generateFunctionalList:FunctionListTypeStar];
            }else{
                [self generateFunctionalList:FunctionListTypeNoSearchResult];
            }
            self.hintView.hidden = YES;
            
        }
        
        [self.dialPad refreshAttrLabel];
    });
    

}

// 状态一：self.homePageBanner出现，phoneCallList贴底

-(void)layoutAdBar:(NSObject*)adInfo{
    if (adInfo == nil) {
        [self.homePageBanner remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view);
            make.height.equalTo(0);
        }];
    }else{
        [self.homePageBanner remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view);
            make.height.equalTo(100);
        }];
    }
    
}

-(void)clearInput{
    [self.dialPad research: @""];
    
    [self reSearch:@""];
}

// 拨号盘出现的组合操作：涉及tabbar是否隐藏、拨号盘本身是否出现。但拨号按钮始终在那里
-(void)showKeyPad:(BOOL)b{
    if (b) {
        if (self.dialPad.hidden == NO) {
            return;
        }
        self.expandDialPadBtn.hidden = YES;
        [self rdv_tabBarController].tabBarHidden = YES;
        
        self.dialPad.hidden = NO;
        [self.topBar tpd_withHeight:20];
        self.navigationView.hidden = YES;
        [self configurePanda:YES];
        
        [self.dialPad remakeConstraints:^(MASConstraintMaker *make) {
            
        }];
        [self.dialPad remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view.top).offset([UIScreen mainScreen].bounds.size.height);
        }];

        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished){
            
        }];
        self.serviceBtn.hidden = YES;
        self.bibiButton.hidden = YES;
        [self setBiBiGuidleViewHidden:YES];
        [self showDialBtn:NO];

        if (VALUE_IN_DEFAULT(@"gesture_guild_has_show") == nil && [GestureModel getShareInstance].isOpenSwitchGesture) {
            self.gestureGuideView.hidden = NO;
            self.dialPad.userInteractionEnabled = NO;
        }
    }else{
        if (self.dialPad.hidden == YES) {
            return;
        }
        self.expandDialPadBtn.hidden = NO;
        [self rdv_tabBarController].tabBarHidden = NO;
        
        
        [self.topBar tpd_withHeight:64];
        self.navigationView.hidden = NO;
        
        [self.dialPad remakeConstraints:^(MASConstraintMaker *make) {
            
        }];
        [self.dialPad remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view.top).offset([UIScreen mainScreen].bounds.size.height-49);
        }];
        
        [self configurePanda:NO];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                             [self.view layoutIfNeeded];
        } completion:^(BOOL finished){
            self.dialPad.hidden = YES;
            
        }];
        
        [self showDialBtn:YES];
        //        [self layoutAdBar:nil];
        self.serviceBtn.hidden = NO;
        self.bibiButton.hidden = ([[BiBiPairManager manager] recommendNumber] == nil);
        [self setBiBiGuidleViewHidden:![[BiBiPairManager manager] canShowBibiGuide]];
    }
}


-(void)createDialBtn{
    WEAK(self)
    self.expandDialPadBtn = [[TPDDialBtn alloc] init];
    [self.expandDialPadBtn tpd_withBlock:^(id sender) {
        if (weakself.dialPad.hidden) {
            [weakself showKeyPad:YES];
        }else{
            [weakself showKeyPad:NO];
        }
    }];
    [self.rdv_tabBarController.view addSubview:self.expandDialPadBtn];
    
    self.expandDialPadBtn.center = dialBtnHideCenter;
    self.expandDialPadBtn.bounds = CGRectMake(0, 0, 94, 94);
    
}

-(void)showDialBtn:(BOOL)bShow{
    if (bShow) {
        
        self.expandDialPadBtn.hidden = NO;
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.expandDialPadBtn.center = dialBtnShowCenter;
        } completion:^(BOOL finished){
            
            NSLog(@"showDialBtn finished");
        }];
        NSLog(@"showDialBtn");
    }else{
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.expandDialPadBtn.center = dialBtnHideCenter;
            
        } completion:^(BOOL finished){
        }];
        NSLog(@"hideDialBtn");
    }
    
}

-(void)reSearch:(NSString*)s{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PhonePadModel* shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
        if (s == nil) {
            [shared_phonepadmodel setInputNumber:shared_phonepadmodel.input_number];
        }else{
            [shared_phonepadmodel setInputNumber:s];
        }
        
    });
    
}



#pragma mark UIViewController代理
-(void)viewDidLoad{
    [super viewDidLoad];
    self.disposableArray = [NSMutableArray array];
    [self reloadUI];
    [self configureTab];
    [self setupNotifications];
    [self showDialBtn:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self tpd_enableSlideReturn];
    self.navigationController.navigationBarHidden = YES;
    
    if (self.dialPad.hidden) {
        // 拨打电话后，自然会收起拨号盘，会走到这里
        // 如果是切换到其他tab再切回来，切换之前必然上收起的，也会走过来
        // 如果上push进入其他vc，不会收起拨号盘，不会走进来
        [self rdv_tabBarController].tabBarHidden = NO;
        [self showDialBtn:YES];
    }
    

    
    self.gestureGuideView.hidden = YES;
    
    
    // view appear的时候，可能在别的界面打过电话，所以要重新搜索calllog
    [self reSearch:nil];
    
    if ([FeedsSigninManager shouldShowSignin]) {
        [[SignBtnManager instance] showSignBtnWithAnimation];
    }
    
    [self refreshBiBiView];

    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    

    [[NewFeatureGuideManager sharedManager] checkNewFeatureGuide];
    
    [self loadViewMenu];
    [self configurePanda:!self.dialPad.hidden];
    [self.menu hello];
    //状态栏皮肤化
    [FunctionUtility updateStatusBarStyle];

//    [self loadDoubleBtnYunYing];
}




-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.menu.hidden = YES;
//    self.navigationController.navigationBarHidden = NO;
    [self rdv_tabBarController].tabBarHidden = YES;
    [self showDialBtn:NO];
    
//    [self clearInput];
//    [self.dialPad foldPad:YES];
}


#pragma mark cell高亮配置
-(NSString*)generateTimeString:(CallLogDataModel*)item{
    
    
    if ([item respondsToSelector:@selector(callTime)]) {
        NSString *dateString = @"";
        NSDate *now = [NSDate date];
        NSDate *date = [[NSDate date] initWithTimeIntervalSince1970:item.callTime];
        NSTimeInterval delta = [now timeIntervalSinceDate:date];
        dateString = [self getDateStringByDate:date];
        if (delta >= 0) {
            NSTimeInterval todayElapsed = [DateTimeUtil timeElapsedInToday];
            if (delta <= todayElapsed) {
                NSDateComponents *comps = [DateTimeUtil dateComponentsFromDate:date];
                NSString *minuteString = [@(comps.minute) stringValue];
                NSString *hourString = [@(comps.hour) stringValue];
                if (minuteString.length < 2) {
                    minuteString = [@"0" stringByAppendingString:minuteString];
                }
                if (hourString.length < 2) {
                    hourString = [@"0" stringByAppendingString:hourString];
                }
                dateString = [NSString stringWithFormat:@"%@:%@", hourString, minuteString];
                
            } else if (delta <= todayElapsed + 1 * DAY_IN_SECOND) {
                dateString = NSLocalizedString(@"Yesterday", @"昨天");
                
            } else if (delta <= 7 * DAY_IN_SECOND) {
                dateString = [DateTimeUtil weekdayStringFromDate:date];
            }
        }
        return dateString;
    }else{
        return nil;
    }
    
}
- (NSString *)callerIDType:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data{
    NSString *callerType = @"";
    if ([data respondsToSelector:@selector(callerID)]) {
        CallerIDInfoModel  *callerIDModel = data.callerID;
        if([callerIDModel isCallerIdUseful] &&(SmartDailerSettingModel.isChinaSim)){
            callerType = callerIDModel.localizedTag;
        }
    }
    return callerType;
}

- (NSString *)callerIDName:(id<BaseContactsDataSource,BaseCallerIDDataSource>)data {
    NSString *callerName = @"";
    if ([data respondsToSelector:@selector(callerID)]) {
        CallerIDInfoModel  *callerIDModel = data.callerID;
        if([callerIDModel isCallerIdUseful] &&(SmartDailerSettingModel.isChinaSim)){
            callerName = callerIDModel.name;
        }
    }
    return callerName;
}

-(void)configNameLabel:(UILabel*)label callModel:(CallLogDataModel*)data{
    NSString  *name = data.name;
    
    if (data.personID <= 0 && data.callerID.name.length > 0) {
        name = data.callerID.name;
    }
    if ([name length] == 0) {
        name = data.number;
    }
    label.numberOfLines = 1;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    NSString* displayString = name;
    if ([data isKindOfClass:[CallLogDataModel class]]){
        if (data.callType == CallLogIncomingMissedType) {
            displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@" (%ld)", data.missedCount]];
            [label setAttributedText:[NSAttributedString tpd_attributedString:displayString withRegExp:name normalColor:RGB2UIColor2(153,153,153) normalFont:[UIFont systemFontOfSize:13] highlightColor:[UIColor redColor] highlightFone:[UIFont boldSystemFontOfSize:17]]];
        }else{
//            if (data.callCount > 1) {
//                displayString = [displayString stringByAppendingString:[NSString stringWithFormat:@" (%ld)", data.callCount]];
//                [label setAttributedText:[NSAttributedString tpd_attributedString:displayString withRegExp:name normalColor:RGB2UIColor2(153,153,153) normalFont:[UIFont systemFontOfSize:13] highlightColor:RGB2UIColor2(26, 26, 26) highlightFone:[UIFont boldSystemFontOfSize:17]]];
//            }else{
                [label tpd_withText:name color:RGB2UIColor2(26, 26, 26) font:17];
                label.font = [UIFont boldSystemFontOfSize:17];
//            }
        }
    }else{
        [label tpd_withText:name color:RGB2UIColor2(26, 26, 26) font:17];
        label.font = [UIFont boldSystemFontOfSize:17];
    }
    

}



-(void)configNumberLabel:(UILabel*)label callModel:(CallLogDataModel*)data{
    NSInteger personID = data.personID;
    NSString  *number = data.number;
    NSString *callerName = [data respondsToSelector:@selector(callerID)]? data.callerID.name:@"";
    
    NSString  *display = number;
    AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
    if (appSettingsModel.display_location) {
        NSString *numberAttr =[[PhoneNumber sharedInstance] getNumberAttribution:number withType:attr_type_short];
        if ([numberAttr length] > 0) {
            if (personID > 0 || [callerName length] > 0) {
                display = [NSString stringWithFormat:@"%@ · %@", display,numberAttr];
            }else{
                display = numberAttr;
            }
        }
        
        NSString* mark = [self callerIDType:data];
        if (![mark isEqualToString:@""]) {
            display = [[display stringByAppendingString:@" · "] stringByAppendingString:mark];
        }
    }
    
    NSString* timeString = [self generateTimeString:data];
    if (timeString!=nil) {
        display = [display stringByAppendingString:[NSString stringWithFormat:@" · %@",timeString]];
    }
    
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:@"诈骗钓鱼|业务推销|骚扰电话|房产中介|快递外卖" options:NSRegularExpressionCaseInsensitive error:nil];
    [label tpd_withAttributedText:display normalColor:RGB2UIColor2(153, 153, 153) normalFont:[UIFont systemFontOfSize:12] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"]  highlightFone:[UIFont systemFontOfSize:12] ofPattern:reg];
    
}

-(void)configNameLabelForSearch:(UILabel*)label callModel:(SearchItemModel*)data{
    NSInteger personID = data.personID;
    NSString  *name = data.name;
    
    if (!(personID >0)) {
        name = [self callerIDName:data];
    }
    if ([name length] == 0) {
        NSRange range = data.hitNumberInfo;
        
        NSString* substring = [data.number substringWithRange:range];
        
        NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:substring options:NSRegularExpressionCaseInsensitive error:nil];
        [label tpd_withAttributedText:data.number normalColor:RGB2UIColor2(26, 26, 26) normalFont:[UIFont boldSystemFontOfSize:17] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"]  highlightFone:[UIFont boldSystemFontOfSize:17] ofPattern:reg];
        
    }else{
        if ([data.hitNameInfo count] > 0) {
            NSString* substring = @"";
            
            for (int i=0; i<[data.hitNameInfo count];i+=2) {
                NSRange range = NSMakeRange([data.hitNameInfo[i] integerValue], [data.hitNameInfo[i+1] integerValue]);
                
                substring = [substring stringByAppendingString:[data.name substringWithRange:range]];
            }
            
            
            NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:substring options:NSRegularExpressionCaseInsensitive error:nil];
            [label tpd_withAttributedText:data.name normalColor:RGB2UIColor2(26, 26, 26) normalFont:[UIFont boldSystemFontOfSize:17] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"] highlightFone:[UIFont boldSystemFontOfSize:17] ofPattern:reg];
        }else{
            if (!(personID >0)) {
                [label tpd_withText:name color:RGB2UIColor2(26, 26, 26) font:17];
            }else{
                [label tpd_withText:data.name color:RGB2UIColor2(26, 26, 26) font:17];
            }
            
            label.font = [UIFont boldSystemFontOfSize:17];
        }

    }

    label.numberOfLines = 1;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
}

-(void)configNumberLabelForSearch:(UILabel*)label callModel:(SearchItemModel*)data{
    NSInteger personID = data.personID;
    NSString  *number = data.number;
    
    NSString  *display = number;
    AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
    if (appSettingsModel.display_location) {
        NSString *numberAttr =[[PhoneNumber sharedInstance] getNumberAttribution:number withType:attr_type_short];
        if ([numberAttr length] > 0) {
            if (personID > 0 ) {
                display = [NSString stringWithFormat:@"%@ · %@", display,numberAttr];
            }else{
                display = numberAttr;
            }
        }
        
        NSString* mark = [self callerIDType:data];
        if (![mark isEqualToString:@""]) {
            display = [[display stringByAppendingString:@" · "] stringByAppendingString:mark];
        }
        
    }
    
    NSRange range = data.hitNumberInfo;
    NSString* substring = [data.number substringWithRange:range];
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:[@"诈骗钓鱼|业务推销|骚扰电话|房产中介|快递外卖|" stringByAppendingString:substring] options:NSRegularExpressionCaseInsensitive error:nil];
    [label tpd_withAttributedText:display normalColor:RGB2UIColor2(153, 153, 153) normalFont:[UIFont systemFontOfSize:12] highlightColor:[TPDialerResourceManager getColorForStyle:@"skinDefaultHighlightText_color"]  highlightFone:[UIFont systemFontOfSize:12] ofPattern:reg];
    
}

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.phoneCallList) {
        CallLogDataModel* item = self.phoneCallListData[indexPath.row];
        
        [self makeCallWithMultiEntry:item];
    }else{
        CallLogDataModel* item = self.searchListData[indexPath.row];
        
        [self makeCallWithMultiEntry:item];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK(self)
    if (tableView == self.phoneCallList) {
        CallLogDataModel* item = self.phoneCallListData[indexPath.row];

        UITableViewCell* cell = [[UITableViewCell tpd_tableViewCellStyleImageLabel2:@[@"", @"", @""] action:^(id sender) {
            
        } reuseId:@""] tpd_withSeperateLine].cast2UITableViewCell;
        cell.tpd_container.userInteractionEnabled = NO;
        cell.tpd_label1.numberOfLines = 1;
        cell.tpd_label1.lineBreakMode = NSLineBreakByTruncatingTail;

        
        
        
        [cell addGestureRecognizer:[UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if (state == UIGestureRecognizerStateBegan) {
                [self showSheet:item];
            }
            
        }]];
        
        [self configNameLabel:cell.tpd_label1 callModel:item];
        [self configNumberLabel:cell.tpd_label2 callModel:item];
        
        // 从别处copy的代码。设定日期。待重构
        
        WEAK(cell)
        UIButton* infoBtn = [[[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
            if (weakcell.editing == UITableViewCellEditingStyleDelete) {
                return;
            }
            if (item) {
                if (item.personID > 0) {
                    [[TPDContactInfoManagerCopy instance] showContactInfoByPersonId:item.personID inNav:self.navigationController];
                }else if (item.personID <= 0) {
                    [[TPDContactInfoManagerCopy instance] showContactInfoByPhoneNumber:item.number];
                }
            }
        }] tpd_withSize:CGSizeMake(40, 40)].cast2UIButton;
//        infoBtn.backgroundColor = [UIColor orangeColor];
        [infoBtn setImage:[UIImage imageNamed:@"listitem_detail_icon_normal"] forState:UIControlStateNormal];
        [infoBtn setImage:[UIImage imageNamed:@"listitem_detail_icon_pressed"] forState:UIControlStateSelected];

        UIButton* callBtn =[[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
            if (weakcell.editing == UITableViewCellEditingStyleDelete) {
                return;
            }
            if (![item isKindOfClass:[SearchItemModel class]] && item.ifVoip) {
                if (![[PhoneNumber sharedInstance] isCNSim]) {
                    item.number = [PhoneNumber getCNnormalNumber:item.number];
                }
                [VOIPCall makeCall:item.number];
            }else{
                [[TPCallActionController controller] makeCallAfterVoipChoice:item isGestureCall:NO];
            }
            
        }].cast2UIButton;
        if (![item isKindOfClass:[SearchItemModel class]] && item.ifVoip) {
            [callBtn setImage:[UIImage imageNamed:@"快捷拨号-免费-正常"] forState:UIControlStateNormal];
            [callBtn setImage:[UIImage imageNamed:@"快捷拨号-免费-按下"] forState:UIControlStateSelected];
        }else{
            [callBtn setImage:[UIImage imageNamed:@"快捷拨号-普通-正常"] forState:UIControlStateNormal];
            [callBtn setImage:[UIImage imageNamed:@"快捷拨号-普通-按下"] forState:UIControlStateSelected];
        }
        [cell addSubview:infoBtn];
        [cell addSubview:callBtn];
        [cell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
            make.right.lessThanOrEqualTo(infoBtn.left).offset(-20);
            make.left.equalTo(cell.tpd_img1);
        }];

        [callBtn makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell);
            make.width.equalTo(50);
            make.right.equalTo(cell.tpd_container);
        }];
        [infoBtn makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell);
            make.right.equalTo(callBtn.left).offset(5);
        }];
        
        return cell;
        
    }else{
        SearchItemModel* item = self.searchListData[indexPath.row];
        
        UITableViewCell* cell = [UITableViewCell tpd_tableViewCellStyleImageLabel2:@[@"", @"", @""] action:^(id sender) {
        } reuseId:@""];
        [cell.tpd_img1 updateConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(0);
        }];
//        [PersonDBA getDefaultColorImageWithoutPersonID]
        [cell tpd_withSeperateLine];
        cell.tpd_container.userInteractionEnabled = NO;
        [cell.tpd_label1 updateConstraints:^(MASConstraintMaker *make) {
            make.right.lessThanOrEqualTo(cell).offset(-80);
        }];
        
        [cell addGestureRecognizer:[UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            if (state == UIGestureRecognizerStateBegan) {
                [self showSheet:item];
            }
            
        }]];
        
        if ([item isKindOfClass:[SearchItemModel class]]) {
            [self configNumberLabelForSearch:cell.tpd_label2 callModel:item];
            [self configNameLabelForSearch:cell.tpd_label1 callModel:item];
        }else{
            [self configNameLabel:cell.tpd_label1 callModel:((CallLogDataModel*)item)];
            [self configNumberLabel:cell.tpd_label2 callModel:((CallLogDataModel*)item)];
        }
        
        WEAK(cell)
        UIButton* infoBtn = [[[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
            if (weakcell.editing == UITableViewCellEditingStyleDelete) {
                return;
            }
            if (item) {
                if (item.personID > 0) {
                    [[TPDContactInfoManagerCopy instance] showContactInfoByPersonId:item.personID inNav:self.navigationController];
                }else if (item.personID <= 0) {
                    [[TPDContactInfoManagerCopy instance] showContactInfoByPhoneNumber:item.number];
                }
            }
        }] tpd_withSize:CGSizeMake(40, 40)].cast2UIButton;
        [infoBtn setImage:[UIImage imageNamed:@"listitem_detail_icon_normal"] forState:UIControlStateNormal];
        [infoBtn setImage:[UIImage imageNamed:@"listitem_detail_icon_pressed"] forState:UIControlStateSelected];
        
        [cell addSubview:infoBtn];
        
        [infoBtn makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell);
            make.right.equalTo(cell.tpd_container).offset(-15);
        }];
        
        return cell;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.phoneCallList) {
        return [self.phoneCallListData count];
    }else{
        return [self.searchListData count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

#pragma mark 左滑删除相关
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return TRUE;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-  (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.phoneCallList) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            int row = [indexPath row];
            // delete from data base.
            NSMutableArray *condition_arr = [NSMutableArray arrayWithCapacity:3];
            CallLogDataModel *m_calllog = [self.phoneCallListData objectAtIndex:row];
            if(m_calllog.personID>0){
                WhereDataModel *condition_pid = [[WhereDataModel alloc] init];
                condition_pid.fieldKey = [DataBaseModel getKWhereKeyPersonID];
                condition_pid.oper = [DataBaseModel getKWhereOperationEqual];
                condition_pid.fieldValue = [NSString stringWithFormat:@"%d", m_calllog.personID];
                [condition_arr addObject:condition_pid];
            }else{
                WhereDataModel *condition_num = [[WhereDataModel alloc] init];
                condition_num.fieldKey = [DataBaseModel getKWhereKeyPhoneNumber];
                
                if ([[[PhoneNumber sharedInstance] getOriginalNumber:m_calllog.number] length] >= 7) {
                    condition_num.oper = [DataBaseModel getKWhereOperationLike];
                    condition_num.fieldValue = [[PhoneNumber sharedInstance] getOriginalNumber:m_calllog.number];
                } else {
                    condition_num.oper = [DataBaseModel getKWhereOperationEqual];
                    condition_num.fieldValue = [DataBaseModel getFormatNumber:[NSString stringWithFormat:@"%@", m_calllog.number]];
                }
                
                [condition_arr addObject:condition_num];
            }
            if ([self.phoneCallListData count] > 1) {
                [CallLog deleteCalllogByConditionalWithoutNotification:condition_arr];
            }else{
                [CallLog deleteCalllogByConditional:condition_arr];
            }
            [self reSearch:nil];
        }
    }else{
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            int row = [indexPath row];
            // delete from data base.
            NSMutableArray *condition_arr = [NSMutableArray arrayWithCapacity:3];
            SearchItemModel *m_calllog = [self.searchListData objectAtIndex:row];
            if(m_calllog.personID>0){
                WhereDataModel *condition_pid = [[WhereDataModel alloc] init];
                condition_pid.fieldKey = [DataBaseModel getKWhereKeyPersonID];
                condition_pid.oper = [DataBaseModel getKWhereOperationEqual];
                condition_pid.fieldValue = [NSString stringWithFormat:@"%d", m_calllog.personID];
                [condition_arr addObject:condition_pid];
            }else{
                WhereDataModel *condition_num = [[WhereDataModel alloc] init];
                condition_num.fieldKey = [DataBaseModel getKWhereKeyPhoneNumber];
                
                if ([[[PhoneNumber sharedInstance] getOriginalNumber:m_calllog.number] length] >= 7) {
                    condition_num.oper = [DataBaseModel getKWhereOperationLike];
                    condition_num.fieldValue = [[PhoneNumber sharedInstance] getOriginalNumber:m_calllog.number];
                } else {
                    condition_num.oper = [DataBaseModel getKWhereOperationEqual];
                    condition_num.fieldValue = [DataBaseModel getFormatNumber:[NSString stringWithFormat:@"%@", m_calllog.number]];
                }
                
                [condition_arr addObject:condition_num];
            }
            if ([self.searchListData count] > 1) {
                [CallLog deleteCalllogByConditionalWithoutNotification:condition_arr];
            }else{
                [CallLog deleteCalllogByConditional:condition_arr];
            }
            [self reSearch:nil];
        }
    }
    
}

#pragma mark UIScrollViewDelegate方法
// 收键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //    [self clearInput];
    [self.dialPad foldPad:YES];
    [self cancelLongPress];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}


#pragma mark helper


static NSDictionary* operationsDic = nil;

+ (void)initialize
{
    NSDictionary *operDics = [[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"multiSelectOperations.plist"]];
    operationsDic = operDics;
}

- (NSString *) getDateStringByDate:(NSDate *)date {
    NSDateComponents *comps = [DateTimeUtil dateComponentsFromDate:date];
    NSMutableString *dayString = [[NSMutableString alloc] initWithString:[@(comps.day) stringValue]];
    if (dayString.length == 1) {
        [dayString insertString:@"0" atIndex:0];
    }
    
    NSMutableString *monthString = [[NSMutableString alloc] initWithString:[@(comps.month) stringValue]];
    if (monthString.length == 1) {
        [monthString insertString:@"0" atIndex:0];
    }
    
    NSString *yearString = [@(comps.year) stringValue];
    NSInteger len = yearString.length;
    if (len > 2) {
        yearString = [yearString substringFromIndex:(len -2)];
    }
    return [NSString stringWithFormat:@"%@/%@/%@", yearString, [monthString copy], [dayString copy]];
}

#pragma mark 系统操作相关
- (void)sendMessage:(NSString*)number
{
    NSString *numStr = number;
    [self cancelLongPress];
    if ([numStr isEqualToString:[UserDefaultsManager stringForKey:PASTEBOARD_LAST_STRING]]) {
        if ([UserDefaultsManager intValueForKey:PASTEBOARD_STRING_STATE defaultValue:0]==1) {
            [DialerUsageRecord recordpath:PATH_PASTEBOARD_OPERATE kvs:Pair( PASTEBOARD_AFTER_DO_YES_OPERATE, @(1)), nil];
        }
    }
    UIViewController *aViewController = [UIViewController tpd_topViewController];
    [TPMFMessageActionController sendMessageToNumber:numStr
                                         withMessage:@""
                                         presentedBy:aViewController];
}


- (void)addContact:(NSString*)number
{
    [self cancelLongPress];
    NSString *numStr = number;
    if ([numStr isEqualToString:[UserDefaultsManager stringForKey:PASTEBOARD_LAST_STRING]]) {
        if ([UserDefaultsManager intValueForKey:PASTEBOARD_STRING_STATE defaultValue:0]==1) {
            [DialerUsageRecord recordpath:PATH_PASTEBOARD_OPERATE kvs:Pair( PASTEBOARD_AFTER_DO_YES_OPERATE, @(2)), nil];
            [UserDefaultsManager setIntValue:1 forKey:PASTEBOARD_STRING_STATE];
        }
    }
    [self clearInput];
    [self showKeyPad:NO];
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    UIViewController *aViewController = [UIViewController tpd_topViewController];
    
    CallerIDInfoModel *callerInfo = [PhonePadModel getSharedPhonePadModel].caller_id_info;
    NSString *name = nil;
    if(callerInfo != nil&&[callerInfo isCallerIdUseful]){
        name = callerInfo.name;
    }
    [[TPABPersonActionController controller] addNewPersonWithNumber:numStr name:name presentedBy:aViewController];
    
}

- (void)addToExistingContact:(NSString*)number
{
    [self cancelLongPress];
    NSString *numStr = number;
    if ([numStr isEqualToString:[UserDefaultsManager stringForKey:PASTEBOARD_LAST_STRING]]) {
        if ([UserDefaultsManager intValueForKey:PASTEBOARD_STRING_STATE defaultValue:0]==1) {
            [DialerUsageRecord recordpath:PATH_PASTEBOARD_OPERATE kvs:Pair( PASTEBOARD_AFTER_DO_YES_OPERATE, @(3)), nil];
        }
    }
    [self clearInput];
    [self showKeyPad:NO];
    if ( [FunctionUtility judgeContactAccessFail])
        return;
    UIViewController *aViewController = [UIViewController tpd_topViewController];
    [[TPABPersonActionController controller] addToExistingContactWithNewNumber:numStr presentedBy:aViewController];
}

-(void)makeCallWithMultiEntry:(id)data{
    if ([AppSettingsModel appSettings].listClick  == CellListFunctionTypeShowAllnumbers) {
        [self loadMultiEntryMaskView:data];
    }else{
        [self makeCall:data];
    }
    
}

-(void)makeCall:(id)data{
    CallLogDataModel* item = data;
    [self cancelLongPress];
    CallLogDataModel *callog = [[CallLogDataModel alloc] initWithPersonId:item.personID phoneNumber:item.number loadExtraInfo:NO];
    [TPCallActionController logCallFromSource:@"CustomizeAction"];
    [[TPCallActionController controller] makeCall:callog appear:^(){
        NSLog(@"1");
    } disappear:^(){
        NSLog(@"2");
    }];
}

-(void)makeCallWithNumber:(NSString*)number{
    [self cancelLongPress];
    NSString* phoneNum = number;
    if (phoneNum.length>0) {
        CallLogDataModel *callog = [[CallLogDataModel alloc] initWithPersonId:-1 phoneNumber:phoneNum loadExtraInfo:NO];
        [TPCallActionController logCallFromSource:@"CustomizeAction"];
        [[TPCallActionController controller] makeCall:callog appear:^(){} disappear:^(){}];
    }
}

-(void)copyPhoneNumber:(id<BaseContactsDataSource>)data{
    if ([data isKindOfClass:[CallLogDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CALLLOG_ACTION, @"copy"), nil];
    }
    NSString *phoneNumber = [data number];
    if(phoneNumber!=nil){
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
        pasteBoard.string = phoneNumber;
        [pasteBoard setPersistent:YES];
    }
}
@end
