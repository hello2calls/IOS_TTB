//
//  PersonInfoDescViewController.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/9/5.
//
//

#import "PersonInfoDescViewController.h"
#import "TPDialerResourceManager.h"
#import "VoipTopSectionHeaderBar.h"
#import "FunctionUtility.h"
#import "UILabel+DynamicHeight.h"
#import "UserDefaultsManager.h"
#import "HandlerWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TouchPalVersionInfo.h"
#import "TPHeaderButton.h"
#import "FreeDialSettingViewController.h"
#import "CTUrl.h"
#import "SeattleFeatureExecutor.h"
#import "LocalStorage.h"
#import "DialerUsageRecord.h"
#import "CootekNotifications.h"
#import "CootekWebHandler.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "UILabel+DynamicHeight.h"
#import "YellowPageWebViewController.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "VoipInvitationCodeView.h"
#import "HandlerWebViewController.h"
#define EXCHANGE_MOBILE_URL @"http://touchlife.cootekservice.com/native_index/cash_button_redirect?_token=%@"
#define EXCHANGE_FLOW_URL @"http://search.cootekservice.com/page/mobilerecharge.html?flag=mobiledata"

#define WALLET_HTML      @"page_v3/wallet_coin.html"
#define VIP_HTML        @"page_v3/wallet_vip.html"
#define MINUTE_HTML      @"page_v3/wallet_free_minute.html"
#define FLOW_HTML       @"page_v3/wallet_flow.html"


@interface PersonInfoDescViewController () <VoipTopSectionHeaderBarProtocol>

@end

@implementation PersonInfoDescViewController {
    PersonInfoDescModel *_model;
    CGFloat _pageMarginLeft;
    CGFloat _pageMarginRight;
    CGFloat _markerSize;
    BOOL _viewDidAppear;
    UIView* myPropertyRedPointView;
    TPHeaderButton *rightButton;
    HandlerWebViewController *_detailWebCon;
}

- (id)initWithModel:(PersonInfoDescModel *)model {
    self = [super init];
    if (self) {
        _model = model;
        _pageMarginLeft = 20;
        _pageMarginRight = 20;
        _markerSize = 20;
        _viewDidAppear = NO;
    }
    return self;
}

- (id)initWithModel:(PersonInfoDescModel *)model andPageType:(NSString*) type {
    self = [super init];
    if (self) {
        _model = model;
        _pageMarginLeft = 20;
        _pageMarginRight = 20;
        _markerSize = 20;
        _viewDidAppear = NO;
        self.pageType = type;
    }
    return self;
}

- (id)initWithLinkDictionary:(NSDictionary *)dic{
    NSString *modelName = [dic objectForKey:@"model"];
    PersonInfoDescModel *model = [PersonInfoDescModel getModelByName:modelName];
    if (model == nil)
        return nil;
    return [self initWithModel:model];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_model.title isEqualToString:@"VIP"] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWithPrivilege:) name:REFRESH_INFOCONTROLLER_WITHPRIVILEGE object:nil];
    }
    // add observer for account info change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVoipAccountInfoChange) name:N_VOIP_ACCOUNT_INFO_CHANGED object:nil];
    
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];

    CGFloat topBgHeight = 220;
    CGFloat labelX = 34;
    CGFloat label1H = 15;
    CGFloat gap1 = 12;
    CGFloat label2Size = 50;
    CGFloat gap2 = 12;
    CGFloat label3H = 15;
    CGFloat bottomGap = 34;
    CGFloat label2H = label2Size/1.3;
    CGFloat iconHGap = 10;
    CGFloat iconVGap = 10;
    BOOL ifShowWeichatLable = NO;
    if (TPScreenHeight() < 500) {
        topBgHeight -= 20;
        label2H = label2Size;
        gap1 = 5;
        gap2 = 5;
        _model.iconSize *= 0.8;
        iconHGap = 0;
    }
    if ([_model.title isEqualToString:@"免费流量"]) {
        iconHGap = 0;
        iconVGap = 0;
    }
//    if ([_model.title isEqualToString:@"免费时长"]
//        &&[UserDefaultsManager intValueForKey:have_join_wechat_public_status]==0
//        &&[UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME ]==1){
//            ifShowWeichatLable= YES;
//        } else{
//            ifShowWeichatLable= NO;
//    }
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), topBgHeight)];
    topBgView.backgroundColor = [TPDialerResourceManager getColorForStyle:_model.themeColor];
    [self.view addSubview:topBgView];

    VoipTopSectionHeaderBar *headBar = [[VoipTopSectionHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth() , TPHeaderBarHeight())];
    headBar.delegate = self;
    headBar.headerTitle.text = _model.title;
    headBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:headBar];
    
    int extraPaddingLeft = 0;
    if([self.pageType isEqualToString:FIND_WALLET_PROPERTY_MINUTES_KEY]) {
        extraPaddingLeft = 40;
    }
    
    // 兑换码 button
    TPHeaderButton *exchangeButton = [[TPHeaderButton alloc]
                                   initWithFrame:CGRectMake(TPScreenWidth() - 90 - extraPaddingLeft, 0, 50, 45)];
    NSString *exchangeButtonString = @"e";
    exchangeButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:24];
    [exchangeButton setTitle:exchangeButtonString forState:UIControlStateNormal];
    [exchangeButton addTarget:self action:@selector(showInvitationCodeView) forControlEvents:UIControlEventTouchUpInside];
    [exchangeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exchangeButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"] forState:UIControlStateHighlighted];
    
    [headBar addSubview:exchangeButton];
    
    // 流水 button
    rightButton = [[TPHeaderButton alloc]
                                   initWithFrame:CGRectMake(TPScreenWidth() - 50 - extraPaddingLeft, 0, 50, 45)];
    NSString *buttonString = @"a";
    rightButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    [rightButton setTitle:buttonString forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(myPropertyRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"] forState:UIControlStateHighlighted];
    
    if (self.pageType != nil && [UserDefaultsManager boolValueForKey:self.pageType]) {
        UIView* iconView = [[UIView alloc] initWithFrame:CGRectMake(rightButton.frame.size.width - 16,8, 8,8)];
        iconView.layer.masksToBounds = YES;
        iconView.layer.cornerRadius = 4;
        iconView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
        [rightButton addSubview:iconView];
        myPropertyRedPointView = iconView;
    }
    
    [headBar addSubview:rightButton];

    if (_model.topRightIconString) {
        TPHeaderButton *actionBut = [[TPHeaderButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 50, 0, 50, 45)];
        //[actionBut setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
        actionBut.titleLabel.font = [UIFont fontWithName:_model.actionFontName size:24];
        [actionBut setTitle:_model.topRightIconString forState:UIControlStateNormal];
        [actionBut addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [actionBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [actionBut setTitleColor:[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"] forState:UIControlStateHighlighted];
        [headBar addSubview:actionBut];
    }

    CGFloat height = label1H + gap1 + label2H + bottomGap;
    if (_model.headerDesc3.length > 0) {
        height += (label3H + gap2);
    }
    CGFloat labelY = topBgView.frame.size.height - height;
    if (!isIPhone5Resolution()) {
        labelY += 10;
    }

    UILabel *label1 = [FunctionUtility labelNoBgWithRect:CGRectMake(labelX, labelY, 150, label1H) font:[UIFont systemFontOfSize:label1H] align:NSTextAlignmentLeft textColor:[UIColor whiteColor] andText:_model.headerDesc1];
    [topBgView addSubview:label1];

    labelY += (label1.frame.size.height + gap1);
    _label2 = [FunctionUtility labelNoBgWithRect:CGRectMake(labelX, labelY, 250, label2H) font:[UIFont systemFontOfSize:label2Size] align:NSTextAlignmentLeft textColor:[UIColor whiteColor] andText:nil];
    _label2.attributedText = _model.headerDesc2;
    [topBgView addSubview:_label2];

    if (_model.headerDesc3.length > 0) {
        labelY += (label2H + gap2);
        UILabel *label3 = [FunctionUtility labelNoBgWithRect:CGRectMake(labelX, labelY, 250, label3H) font:[UIFont systemFontOfSize:label3H] align:NSTextAlignmentLeft textColor:[UIColor whiteColor] andText:_model.headerDesc3];
        [topBgView addSubview:label3];
    }

    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    if (!isIPhone5Resolution()) {
        _model.iconSize = 1.2 * _model.iconSize;
    }



    UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _model.iconSize, _model.iconSize)];
    iconLabel.backgroundColor = [UIColor clearColor];
    iconLabel.font = [UIFont fontWithName:_model.iconFontName size:_model.iconSize];
    iconLabel.text = _model.iconString;
    iconLabel.textColor = color;
    CGSize realSize = [iconLabel sizeOfMultiLineLabel];
        iconLabel.frame = CGRectMake(topBgView.frame.size.width - iconHGap - realSize.width, topBgView.frame.size.height - iconVGap - realSize.height, realSize.width, realSize.height);
    [topBgView addSubview:iconLabel];
    cootek_log(@"%@",iconLabel);

    if (ifShowWeichatLable){
        topBgHeight+=36;
        topBgView.frame = CGRectMake(0, 0, TPScreenWidth(), topBgHeight);
    }
    UIScrollView *bottomBgView;
    if (TPScreenHeight()>500) {
        bottomBgView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,  topBgHeight, TPScreenWidth(), TPScreenHeight() - topBgHeight)];
    }else{
        bottomBgView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,  topBgHeight, TPScreenWidth(), TPScreenHeight() - topBgHeight)];
    }
    bottomBgView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    bottomBgView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bottomBgView];

    CGFloat contentX = 15;
    CGFloat contentY = 0;
    
    CGFloat descSize = 15;

    if (ifShowWeichatLable){
        CGFloat fontSize=descSize;
        if (TPScreenHeight()<600) {
            fontSize=14;
        }
            _labelToWeichat = [[UILabel alloc] initWithFrame:CGRectMake(0, topBgHeight-36, TPScreenWidth(), 36)];
            _labelToWeichat.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_150"];
            _labelToWeichat.userInteractionEnabled= YES;
            [topBgView addSubview:_labelToWeichat];
            UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentX, (36-20)/2, 20, 20)];
            iconLabel.backgroundColor = [UIColor clearColor];
            iconLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:20];
            iconLabel.text = @"F";

            iconLabel.textAlignment = NSTextAlignmentCenter;
            iconLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
            [_labelToWeichat addSubview:iconLabel];

        UILabel *desLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconLabel.frame), CGRectGetMinY(iconLabel.frame), 10, 20)];
        desLable.backgroundColor = [UIColor clearColor];
        desLable.text = @"您还有200分钟注册奖励未激活";
        desLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        desLable.font =[UIFont systemFontOfSize:fontSize];
        CGSize size = [desLable.text sizeWithFont:desLable.font];
        desLable.frame = CGRectMake(CGRectGetMaxX(iconLabel.frame)+5, (36-size.height)/2, size.width, size.height) ;
         [_labelToWeichat addSubview:desLable];

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(desLable.frame)+4,(36-(size.height-4))/2 , 1, size.height-4)];
        lineView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"];
        [_labelToWeichat addSubview:lineView];

        UILabel *tapLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame)+4,CGRectGetMinY(iconLabel.frame), 140, 20)];
        tapLable.backgroundColor = [UIColor clearColor];
        tapLable.text = @"立即激活>>";
        tapLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_yellow_300"];
        tapLable.font =[UIFont systemFontOfSize:fontSize];

        [_labelToWeichat addSubview:tapLable];

        UIButton *tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tapButton.frame  = tapLable.frame;
        tapButton.backgroundColor = [UIColor clearColor];
        [tapButton addTarget:self action:@selector(tapToWeichatGuide) forControlEvents:(UIControlEventTouchUpInside)];
        [_labelToWeichat addSubview:tapButton];


    }
    
    if (_model.detailUrl.length>0) {
        _detailWebCon= [[HandlerWebViewController alloc] init];
        _detailWebCon.url_string =_model.detailUrl;
        _detailWebCon.ifHideHeaderBar = YES;
        
        _detailWebCon.viewFrame = bottomBgView.bounds;
        [bottomBgView addSubview:_detailWebCon.view];
    }
    /*if (_model.contentTitle) {
        contentY += 20;
        UIView *contentTitleView = [self getContentTitleView];
        if (contentTitleView) {
            contentTitleView.frame = CGRectMake(
                                     _pageMarginLeft, contentY,
                                    contentTitleView.frame.size.width, contentTitleView.frame.size.height);
            [bottomBgView addSubview:contentTitleView];
            contentY += contentTitleView.frame.size.height;
        }
    }

    for (InfoDescModel *info in _model.contentDescs) {
        NSMutableArray *title = [[NSMutableArray alloc] initWithCapacity:info.title.count];
        cootek_log(@"info.count: %d", info.title.count);
        for (NSAttributedString *attrString in info.title) {
            cootek_log(@"attrString : %@", attrString);
            [title addObject:attrString.string];
        }
        UIView *itemHolder = [self getDescHolderView:[title copy] desc:info.desc tag:info.tag];
        if (itemHolder) {
            itemHolder.frame = CGRectMake(_pageMarginLeft, contentY,
                                          itemHolder.frame.size.width, itemHolder.frame.size.height);
            [bottomBgView addSubview:itemHolder];
            contentY += itemHolder.frame.size.height;
        }

    }

    if (_model.actionModel) {
        contentY += 46;
        CGFloat gap = 50;
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(gap , contentY, TPScreenWidth() - 2 *gap, 50);
        [_button setTitle:_model.actionModel.actionText forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:_model.themeColor]] forState:UIControlStateNormal];
        [_button setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:_model.actionModel.actionHighColor]] forState:UIControlStateHighlighted];
        _button.layer.cornerRadius = 4;
        _button.layer.masksToBounds = YES;
        [_button addTarget:self action:@selector(onActionPress) forControlEvents:UIControlEventTouchUpInside];
        [bottomBgView addSubview:_button];
        contentY += 50;
    }
     */
    cootek_log(@"PersonInfoDescController, contentY: %@", [@(contentY) stringValue]);
    if (contentY > bottomBgView.frame.size.height) {
        [bottomBgView setContentSize:CGSizeMake(TPScreenWidth(), contentY + 20 - TPHeaderBarHeightDiff())];
    }
    cootek_log(@"PersonInfoDescController, scroll, frame: %@, content: %@",\
               NSStringFromCGRect(bottomBgView.frame), NSStringFromCGSize(bottomBgView.contentSize));
}

-(void)tapToWeichatGuide{
    HandlerWebViewController *weichatGuide = [[HandlerWebViewController alloc]init];
    weichatGuide.header_title= @"领取教程";
    weichatGuide.url_string = @"http://dialer.cdn.cootekservice.com/web/internal/activities/register_wechat_guide/index.html";
    [[TouchPalDialerAppDelegate naviController] pushViewController:weichatGuide animated:YES];
}

- (void) myPropertyRecordAction {
    HandlerWebViewController *webController = [[HandlerWebViewController alloc] init];
    if ([self.pageType isEqualToString:FIND_WALLET_PROPERTY_VIP_KEY]) {
        webController.url_string = @"http://dialer-voip.cootekservice.com/voip/user_account_details_view?type=vip";
    } else if ([self.pageType isEqualToString:FIND_WALLET_PROPERTY_WALLET_KEY]) {
        webController.url_string = @"http://dialer-voip.cootekservice.com/voip/user_account_details_view?type=coin";
    } else if ([self.pageType isEqualToString:FIND_WALLET_PROPERTY_TRAFFIC_KEY]) {
        webController.url_string = @"http://dialer-voip.cootekservice.com/voip/user_account_details_view?type=traffic";
    } else if ([self.pageType isEqualToString:FIND_WALLET_PROPERTY_MINUTES_KEY]) {
        webController.url_string = @"http://dialer-voip.cootekservice.com/voip/user_account_details_view?type=minutes";
    } else {
        webController.url_string = @"http://dialer-voip.cootekservice.com/voip/user_account_details_view";
    }
    [webController setRefreshButton:NO];
    webController.header_title = @"";
    if (self.pageType.length > 0) {
        [UserDefaultsManager setBoolValue:NO forKey:self.pageType];
    }
    if (myPropertyRedPointView != nil) {
        myPropertyRedPointView.hidden = YES;
    }
    [[TouchPalDialerAppDelegate naviController] pushViewController:webController animated:YES];
}

- (void)showInvitationCodeView{
    VoipInvitationCodeView *invitationCodeView = [[VoipInvitationCodeView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    [self.view addSubview:invitationCodeView];
}


-(void)refreshWithPrivilege:(NSNotification *)noti{
    NSString *day ;
    if (((NSString *)(noti.userInfo[@"day"])).length>0) {
        day = noti.userInfo[@"day"];
    }else{
        day =[NSString stringWithFormat:@"%d",[UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY defaultValue:0]];
    }
    
    NSString *unit = _model.unit;
    NSString  *text = [NSString stringWithFormat:@"%@%@", day, unit];

    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:[text rangeOfString:unit]];
    InfoActionModel *actionModel;
    if (noti.userInfo[@"actionModel"] != nil ) {
        actionModel = noti.userInfo[@"actionModel"];
        _model.actionModel =actionModel;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        _label2.attributedText = attrText;
        if (actionModel) {
            [_button setTitle:_model.actionModel.actionText forState:UIControlStateNormal];
        }
    });
}


-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [super viewWillAppear:animated];
    if (_viewDidAppear) {
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            [SeattleFeatureExecutor getAccountNumbersInfo];
            [SeattleFeatureExecutor queryVOIPAccountInfo];
        });
    }
}

- (void)onActionPress {
    _model.actionModel.actionBlock();
    [FunctionUtility setAppHeaderStyle];

}

- (void)gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction {
    _model.topRightAction();
}

- (void)jumpSomeWhereAfterLogin:(BOOL)animate{
    PersonInfoDescViewController *controll = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel trafficModel]];
    [[TouchPalDialerAppDelegate naviController] pushViewController:controll animated:animate];
}
- (LoginControllerType)getIdentifyController {
    return MARKET;
}

- (void) viewDidAppear:(BOOL)animated {
    if (!_viewDidAppear) {
        _viewDidAppear = YES;
    }
    [super viewDidAppear:animated];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark observer
- (void) onVoipAccountInfoChange {
    NSDictionary *accountInfoChanges = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO_DIFF defaultValue:nil];
    if (!accountInfoChanges) {
        return;
    }
    NSString *currentKey = [self getAccountInfoKey];
    if (!currentKey) {
        return;
    }
    NSString *value = [accountInfoChanges objectForKey:currentKey];
    if (!value || value.length == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        if (_label2) {
            NSAttributedString *attrText = _label2.attributedText;
            if (!attrText) {
                return;
            }
            NSMutableAttributedString *mutableAttrText = [[NSMutableAttributedString alloc] initWithAttributedString:attrText];
            NSRange range = NSMakeRange(0, attrText.length - _model.unit.length);
            [mutableAttrText replaceCharactersInRange:range withString:value];
            _label2.attributedText = [mutableAttrText copy];
            
            UIView* iconView = [[UIView alloc] initWithFrame:CGRectMake(rightButton.frame.size.width - 16,8, 8,8)];
            iconView.layer.masksToBounds = YES;
            iconView.layer.cornerRadius = 4;
            iconView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
            [rightButton addSubview:iconView];
            myPropertyRedPointView = iconView;
        }
    });
}

#pragma mark helper: get views
- (NSString *) getAccountInfoKey {
    NSString *currentModelName = _model.modelName;
    if (!currentModelName) {
        return nil;
    }
    
    if ([MODEL_TRAFFIC isEqualToString:currentModelName]) {
        return CENTER_DETAIL_BYTES_F;
    } else if ([MODEL_FREE_FEE isEqualToString:currentModelName]) {
        return CENTER_DETAIL_MINUTES;
    } else if ([MODEL_BACK_FEE isEqualToString:currentModelName]) {
        return CENTER_DETAIL_COINS;
    } else if ([MODEL_VIP_PRIVILEGE isEqualToString:currentModelName]) {
        return nil;
    }
    
    return nil;
}

- (UIView *) getDescHolderView:(NSArray<NSString *> *) title desc:(NSArray<NSString *> *) desc tag:(NSInteger)tag{
    if (!title || !desc) {
        return nil;
    }
    CGFloat contentY = 20;
    CGFloat pageWidth = TPScreenWidth() - _pageMarginLeft - _pageMarginRight;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pageWidth, 0)];

    UIView *titleView = [self getDescTitleView:title tag:tag];
    if (!titleView) {
        return nil;
    }
    titleView.frame = CGRectMake(0, contentY, titleView.frame.size.width, titleView.frame.size.height);
    contentY += titleView.frame.size.height;

    [container addSubview:titleView];
    //desc is a array
    NSUInteger itemCount = desc.count;
    for(int i=0; i < itemCount; i++) {
        //common item
        CGFloat marginTop = 6;
        if (i == 0) {
            // the first item
            marginTop = 12;
        }
        UIView *itemView = [self getDescItemView:desc[i]];
        if (itemView) {
            contentY += marginTop;
            itemView.frame = CGRectMake(0, contentY,
                                        itemView.frame.size.width, itemView.frame.size.height);
            [container addSubview:itemView];
            contentY += itemView.frame.size.height;
        }
    }
    container.frame = CGRectMake(0, 0, pageWidth, contentY);
    return container;
}

- (UIView *) getContentTitleView {
    if (!_model) {
        return nil;
    }
    NSString *contentTitle = _model.contentTitle ;
    if (!contentTitle) {
        return nil;
    }
    UILabel *targetView = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    UIColor *color = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_900"];
    targetView.textColor = color;
    targetView.font = font;
    targetView.text = contentTitle;
    targetView.backgroundColor = [UIColor clearColor]; // for ios 6.0
    [targetView adjustSizeByFillContent];

    return targetView;
}

- (UIView *) getDescTitleView:(NSArray<NSString *> *) info tag:(NSInteger)tag{
    if (!_model || !info) {
        return nil;
    }
    NSUInteger count = info.count;
    CGSize mainLabelSize = CGSizeZero;

    NSString *mainTitle = nil;;
    NSString *altTitle = nil;;
    NSString *lineString = nil;
    if (count == 1) {
        mainTitle = info.firstObject;
    } else {
        mainTitle = info.firstObject;
        lineString = info[1];
        altTitle = info.lastObject;
    }
    // prepare subviews
    UILabel *mainLabel = nil;
    UILabel *lineLabel = nil;
    UIButton *altLabel = nil;

    if (mainTitle) {
        mainLabel = [self getUILabelByString:mainTitle fontSize:16 isBold:YES];
        cootek_log(@"mainlabel, %@", NSStringFromCGRect(mainLabel.frame));
        [mainLabel adjustSizeByFillContent];
        mainLabelSize = mainLabel.bounds.size;
    }
    if (lineString) {
        lineLabel = [self getUILabelByString:lineString fontSize:14]; //a work-aroud for a single Chinsese character's height
        lineLabel.frame = CGRectMake(lineLabel.frame.origin.x, lineLabel.frame.origin.y,
                                     12, lineLabel.frame.size.height);
        lineLabel.textAlignment = NSTextAlignmentCenter;
        lineLabel.text = lineString;
    }
    if (altTitle) {
        altLabel = [self getUIButtonByString:altTitle fontSize:14];
    }

    // set-up view trees
    CGFloat containerWidth = TPScreenWidth() - _pageMarginLeft - _pageMarginRight - _markerSize - 4;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, mainLabelSize.height)];
    CGFloat contentX = 0;
    if(mainTitle.length>0){
        UIView *markLabel = [self getDescTitleMarker];
        [container addSubview:markLabel];
        contentX += markLabel.frame.size.width + 4;
        }
    if (mainLabel) {
        mainLabel.frame = CGRectMake(contentX, mainLabel.frame.origin.y,
                                     mainLabel.frame.size.width, mainLabel.frame.size.height);
        contentX += mainLabel.frame.size.width;
        [container addSubview:mainLabel];
    }
    if (lineLabel) {
        CGFloat topOffset = (mainLabelSize.height - lineLabel.frame.size.height) / 1;
        lineLabel.frame = CGRectMake(contentX, topOffset, lineLabel.frame.size.width, lineLabel.frame.size.height);
        contentX += lineLabel.frame.size.width;
        lineLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_300"];
        [container addSubview:lineLabel];
    }
    if (altLabel) {
        altLabel.tag = tag;
        CGFloat topOffset = (mainLabelSize.height - altLabel.frame.size.height) / 1;
        altLabel.frame = CGRectMake(contentX, topOffset, altLabel.frame.size.width, altLabel.frame.size.height);
        UIColor *normalColor = [TPDialerResourceManager getColorForStyle:_model.themeColor];
        NSString *altString = altLabel.titleLabel.text;
        cootek_log(@"title: %@", altLabel.titleLabel.text);

        NSMutableArray *components = [[_model.themeColor componentsSeparatedByString:@"_"] mutableCopy];
        NSString *normalColorString =  components.lastObject;
        int normalValue = [normalColorString intValue];
        if (normalValue != 0 ) {
            normalValue += 200;
        }
        [components removeLastObject];
        [components addObject:[@(normalValue) stringValue]];
        NSString *hlcolorString = [[components copy] componentsJoinedByString:@"_"];
        cootek_log(@"hlcolor: %@, theme: %@", hlcolorString, _model.themeColor);
        UIColor *hlcolor = [TPDialerResourceManager getColorForStyle:hlcolorString];

        [altLabel setTitleColor:normalColor forState:UIControlStateNormal];
        [altLabel setTitleColor:hlcolor forState:UIControlStateHighlighted];

        [altLabel setTitle:altString forState:UIControlStateNormal];
        [altLabel setTitle:altString forState:UIControlStateHighlighted];

        [container addSubview:altLabel];
        contentX += altLabel.frame.size.width;
        
        [altLabel addTarget:self action:@selector(onItemActionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cootek_log(@"last, mainlabel: %@", NSStringFromCGRect(mainLabel.frame));
    cootek_log(@"container, %@", NSStringFromCGRect(container.frame));
    return container;
}

- (void) onItemActionClick: (UIButton *)button {
    if (!button) {
        return;
    }
    NSInteger targetTag = button.tag;
    for(InfoDescModel *model in _model.contentDescs) {
        if (!model) {
            continue;
        }
        if (targetTag == model.tag) {
            if (model.actionBlock) {
                model.actionBlock();
                break;
            }
        } else {
            continue;
        }
    }
}

- (UIView *) getDescItemView:(NSString *) itemString hideMarker: (BOOL) hideMarker {
    if (!_model || !itemString) {
        return nil;
    }
    CGFloat pageWidth = TPScreenWidth() - _pageMarginRight - _pageMarginLeft;
    CGFloat infoWidth = pageWidth;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pageWidth, 0)];

    UILabel *itemInfoLabel = [self getUILabelByString:itemString fontSize:14];
    UILabel *itemMarker = [self getDescItemMarker];

    if (!itemInfoLabel || !itemMarker) {
        return nil;
    }
    CGFloat contentX = 0;
    container.frame = CGRectMake(0, 0, container.frame.size.width, itemInfoLabel.frame.size.height);
    
    CGFloat containerHeight = 0;
    if (itemMarker) {
        [container addSubview:itemMarker];
        contentX += itemMarker.frame.size.width;
        itemMarker.hidden = hideMarker;
        
        infoWidth = pageWidth - itemMarker.frame.size.width;
        containerHeight = itemMarker.frame.size.height;
    }

    // adjust views for vertical align
    CGFloat markerHeight = itemMarker.frame.size.height;
    CGFloat infoHeight = itemInfoLabel.frame.size.height;
    CGFloat topOffset = 0;
    UIView *ajustView = nil;
    if (markerHeight > infoHeight ) {
        topOffset = (markerHeight - infoHeight) / 2;
        ajustView = itemInfoLabel;
    } else {
        topOffset = (infoHeight - markerHeight) / 2;
        ajustView = itemMarker;
    }
    cootek_log(@"topOffeset: %f", topOffset);
    if (topOffset != 0 && ajustView) {
        ajustView.frame = CGRectMake(ajustView.frame.origin.x, ajustView.frame.origin.y + topOffset,
            ajustView.frame.size.width, ajustView.frame.size.height);
    }
    itemInfoLabel.frame = CGRectMake(contentX, itemInfoLabel.frame.origin.y,
                                     infoWidth, itemInfoLabel.frame.size.height);
    [itemInfoLabel adjustSizeByFixedWidth];
    CGSize properSize = itemInfoLabel.frame.size;
    // end: adjust size
    
    if (properSize.height > containerHeight) {
        containerHeight = properSize.height;
    }
    container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y, pageWidth, containerHeight);
    
    UIColor *greyColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
    itemMarker.textColor = greyColor;
    itemInfoLabel.textColor = greyColor;
    
    [container addSubview:itemInfoLabel];
    
    return container;
}

- (UIView *) getDescItemView:(NSString *) itemString {
    return [self getDescItemView:itemString hideMarker:NO];
}

- (UILabel *) getDescItemMarker {
    UILabel *marker = [self getUILabelByString:@"·" fontSize:18];
    if (marker) {
        marker.frame = CGRectMake(marker.frame.origin.x, marker.frame.origin.y, _markerSize, _markerSize);
        marker.textAlignment = NSTextAlignmentCenter;
    }
    return marker;
}

- (UIView *) getDescTitleMarker {
    if (!_model) {
        return nil;
    }
    UILabel *markerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _markerSize, _markerSize)];
    markerLabel.text = @"l";
    markerLabel.textColor = [TPDialerResourceManager getColorForStyle:_model.themeColor];
    markerLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:18];
    markerLabel.textAlignment = NSTextAlignmentCenter;
    markerLabel.layer.cornerRadius = _markerSize / 2;
    markerLabel.layer.masksToBounds = YES;

    return markerLabel;
}

- (UILabel *) getUILabelByString:(NSString *) contentString fontSize:(CGFloat) fontSize  isBold:(BOOL) isBold{
    if (!contentString || contentString.length < 1) {
        return nil;
    }
    if (fontSize < 0) {
        return nil;
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    if (isBold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = font;
    label.text = contentString;
    label.font = font;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    [label adjustSizeByFillContent];
    return label;
}

- (UILabel *) getUILabelByString:(NSString *) contentString fontSize:(CGFloat) fontSize {
    return [self getUILabelByString:contentString fontSize:fontSize isBold:NO];
}

- (UIButton *) getUIButtonByString:(NSString *) contentString fontSize:(CGFloat) fontSize {
    return [self getUIButtonByString:contentString fontSize:fontSize isBold:NO];
}

- (UIButton*) getUIButtonByString:(NSString *) contentString fontSize:(CGFloat) fontSize isBold:(BOOL)isBold {
    UILabel *label = [self getUILabelByString:contentString fontSize:fontSize isBold:isBold];
    if (!label) {
        return nil;
    }
    UIButton *button = [[UIButton alloc] initWithFrame:label.frame];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.text = label.text;
    button.titleLabel.textColor = label.textColor;
    button.titleLabel.font = label.font;
    return button;
}

+ (void(^)()) getProfitCenterActionBlock {
    return ^{
        NSString *urlString = [VIP_URL stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
        if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
            urlString = [urlString stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
        }
        urlString =[urlString  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        CTUrl *ctUrl = [[CTUrl alloc] initWithUrl:urlString];
        UIViewController *webController = [ctUrl startWebView];
        if ([webController isKindOfClass:[YellowPageWebViewController class]]) {
            ((YellowPageWebViewController *)webController).needTitle = YES;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    };
}

@end

@implementation PersonInfoDescModel

+ (PersonInfoDescModel *)backFeeModel {
    PersonInfoDescModel *model = [[PersonInfoDescModel alloc] init];
    model.modelName = MODEL_BACK_FEE;
    model.title = @"零钱";
    model.themeColor = @"tp_color_orange_800";
    model.iconString = @"j";
    model.iconSize = 140.0;
    model.iconFontName = @"iPhoneIcon1";
    model.headerDesc1 = @"当前可用余额";
    model.unit = @"元";
    NSString *token = [SeattleFeatureExecutor getToken];
    model.detailUrl = [NSString stringWithFormat:@"%@/%@?_token=%@",TOUCHLIFE_SITE,WALLET_HTML,token];

    NSString *unit = model.unit;
    NSString *coins = [[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO] objectForKey:@"coins"];
    NSString *text = [NSString stringWithFormat:@"%@%@", coins, model.unit];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:[text rangeOfString:unit]];
    model.headerDesc2 = attrText;

    InfoDescModel *content = [[InfoDescModel alloc] init];
    content.tag = ID_FEE_MORE;
    content.actionBlock = [PersonInfoDescViewController getProfitCenterActionBlock];
    content.title = @[
                       [[NSAttributedString alloc] initWithString:@"赚取更多零钱"],
                       [[NSAttributedString alloc] initWithString:@"|"],
                       [[NSAttributedString alloc] initWithString:@"立即赚取>>"],
                       ];
    content.desc = @[
                     @"完成带有奖励的任务即可获得零钱",
                     @"完成还有免费时长、免费流量以及VIP可以赚取"
                     ];

    InfoDescModel *content2 = [[InfoDescModel alloc] init];
    content2.tag = ID_FEE_USE;
    content2.actionBlock = ^{
        NSString *targetUrlString = EXCHANGE_MOBILE_URL;
        if ([targetUrlString rangeOfString:@"_token=%@"].location != NSNotFound) {
           targetUrlString = [NSString stringWithFormat:targetUrlString, [SeattleFeatureExecutor getToken]];
        }
        CTUrl *ctUrl = [[CTUrl alloc] initWithUrl:targetUrlString];
        [ctUrl startWebView];
    };
    content2.title = @[
                       [[NSAttributedString alloc] initWithString:@"使用零钱"],
                       [[NSAttributedString alloc] initWithString:@"|"],
                       [[NSAttributedString alloc] initWithString:@"立即使用>>"],
                       ];
    content2.desc = @[
                      @"充话费或使用其他生活服务，均可使用零钱抵扣"
                      ];

    model.contentDescs = @[content, content2];
    model.contentTitle = @"如何赚取与使用零钱?";

    return model;
}

+ (PersonInfoDescModel *)PrivilegaModel {
    PersonInfoDescModel *model = [[PersonInfoDescModel alloc] init];
    model.modelName = MODEL_VIP_PRIVILEGE;
    model.title = @"VIP";
    model.themeColor = @"tp_color_amber_700";
    model.iconString = @"S";
    model.iconSize = 140;
    model.iconFontName = @"iPhoneIcon2";
    model.headerDesc1 = @"VIP剩余天数";
    model.unit = @"天";
    NSString *token = [SeattleFeatureExecutor getToken];
    model.detailUrl = [NSString stringWithFormat:@"%@/%@?_token=%@",TOUCHLIFE_SITE,VIP_HTML,token];
    
    __block NSString *day ;
    if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]) {
        day =[NSString stringWithFormat:@"%d",[UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY defaultValue:0]];
    }else{
        day = @"0";
    }

    NSString *unit = model.unit;
    NSString *text = [NSString stringWithFormat:@"%@%@", day, unit];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:[text rangeOfString:unit]];
    model.headerDesc2 = attrText;

    InfoDescModel *content = [[InfoDescModel alloc] init];
    content.title = @[
                      [[NSAttributedString alloc] initWithString:@"VIP有什么特权？"]
                      ];
    content.desc = @[
                     @"高清通话专线",
                     @"线路紧张时正常通话不中断",
                     @"去电显号特权"
                     ];
    model.contentDescs = @[content];

    InfoActionModel *action = [[InfoActionModel alloc] init];
    __block InfoActionModel *block_action = action;
    action.actionText = @"获取VIP";
    action.actionHighColor = @"tp_color_amber_800";
    action.actionBlock = ^ {
        if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]){
            [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(KEY_ACTION , RENEWAL), nil];
        }else{
            [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(KEY_ACTION , GET_VIP), nil];
        }
        NSString *string = [VIP_URL stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
        if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
            string = [string stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
        }
        HandlerWebViewController  *vipWebViewVC = [[HandlerWebViewController alloc]init];
        vipWebViewVC.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
        vipWebViewVC.header_title = @"赚钱中心";
        [[TouchPalDialerAppDelegate naviController] pushViewController:vipWebViewVC animated:YES];
    };
    model.actionModel = action;


    dispatch_async([SeattleFeatureExecutor getQueue], ^{
            [SeattleFeatureExecutor getAccountNumbersInfo];
            [SeattleFeatureExecutor queryVOIPAccountInfo];
            day =[NSString stringWithFormat:@"%d",[UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY defaultValue:0]];
                action.actionText = @"获取VIP";
            action.actionBlock = ^ {
               if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]){
                    [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(KEY_ACTION , RENEWAL), nil];
                }else{
                    [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(KEY_ACTION , GET_VIP), nil];
                }
                NSString *string = [VIP_URL stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
                if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
                    string = [string stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
                }

                HandlerWebViewController  *vipWebViewVC = [[HandlerWebViewController alloc]init];
                vipWebViewVC.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                vipWebViewVC.header_title = @"赚钱中心";
                [[TouchPalDialerAppDelegate naviController] pushViewController:vipWebViewVC animated:YES];
            };
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_INFOCONTROLLER_WITHPRIVILEGE object:nil userInfo:@{@"day":day,@"actionModel":action}];

    });

    return model;
}


+ (PersonInfoDescModel *)freeFeeModel {
    [UserDefaultsManager setBoolValue:YES forKey:ASK_LIKE_VIEW_COULD_SHOW];
    PersonInfoDescModel *model = [[PersonInfoDescModel alloc] init];
    model.modelName = MODEL_FREE_FEE;
    model.title = @"免费时长";
    model.themeColor = @"0x20a147";
    model.iconFontName = @"iPhoneIcon2";
    model.iconString = @"W";
    model.iconSize = 130.0;
    
    // right button
    model.headerDesc1 = @"剩余免费时长";
    model.topRightIconString = @"l";
    model.actionFontName = @"iPhoneIcon3";
    
    model.unit = @"分钟";
    NSString *token = [SeattleFeatureExecutor getToken];
    model.detailUrl = [NSString stringWithFormat:@"%@/%@?_token=%@",TOUCHLIFE_SITE,MINUTE_HTML,token];
    NSString *coins = [[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO] objectForKey:@"minutes"];
    NSString *unit = model.unit;
    NSString *text = [NSString stringWithFormat:@"%@%@", coins, unit];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:[text rangeOfString:unit]];
    model.headerDesc2 = attrText;

    int temporaryTime = [UserDefaultsManager intValueForKey:VOIP_MONTH_BALANCE defaultValue:-1];
    if (temporaryTime > 0) {
        NSString *desc3 = [NSString stringWithFormat:@"本月底到期时长：%d分钟", temporaryTime];
        model.headerDesc3 = desc3;
    }
    InfoDescModel *content = [[InfoDescModel alloc] init];
    content.title = @[
                      [[NSAttributedString alloc] initWithString:NSLocalizedString(@"invite_friends", @"邀请有奖")],
                      [[NSAttributedString alloc] initWithString:@"|"],
                      [[NSAttributedString alloc] initWithString:@"立即邀请>>"],
                      ];
    content.desc = @[
                     @"好友首次注册，邀请人即得200分钟奖励",
                     @"触宝好友间通话不扣时长，更享去电显号"
                     ];
    content.tag = ID_MINUTES_INVITE;
    content.actionBlock = ^{
        YellowPageWebViewController *webVC = [[YellowPageWebViewController alloc] init];
        
        webVC.url_string = [NSString stringWithFormat:@"%@%@",INVITE_REWARDS_WEB,@"?share_from=FreePhoneDetail"];;
        webVC.web_title = NSLocalizedString(@"invite_friends", @"邀请有奖");
        webVC.needTitle = YES;
        [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(2)), nil];
    };
    
    InfoDescModel *content2 = [[InfoDescModel alloc] init];
    content2.tag = ID_MINUTES_TASK;
    content2.actionBlock = [PersonInfoDescViewController getProfitCenterActionBlock];
    content2.title = @[
                       [[NSAttributedString alloc] initWithString:@"任务奖励"],
                       [[NSAttributedString alloc] initWithString:@"|"],
                       [[NSAttributedString alloc] initWithString:@"查看任务>>"],
                       ];
    content2.desc = @[
                      @"完成指定任务即可以领取时长奖励",
                      @"还有免费流量、零钱及VIP可以赚取"
                      ];
    
    model.contentTitle = @"如何赚取更多时长?";
    model.contentDescs = @[content, content2];

    model.topRightAction = ^ {
        FreeDialSettingViewController *con = [[FreeDialSettingViewController alloc] init];
        [[TouchPalDialerAppDelegate naviController] pushViewController:con animated:YES];
    };
    
    return model;

}

+ (PersonInfoDescModel *)trafficModel {
    PersonInfoDescModel *model = [[PersonInfoDescModel alloc] init];
    model.modelName = MODEL_TRAFFIC;
    model.title = @"免费流量";
    model.themeColor = MY_TRAFFIC_INFO_COLOR;
    model.iconString = @"m";
    model.iconSize = 170.0;
    model.iconFontName = @"iPhoneIcon1";
    model.headerDesc1 = @"剩余免费流量";
    model.unit = @" MB";
    NSString *token = [SeattleFeatureExecutor getToken];
    model.detailUrl = [NSString stringWithFormat:@"%@/%@?_token=%@",TOUCHLIFE_SITE,FLOW_HTML,token];
    NSString *coins = [[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO] objectForKey:@"bytes_f"];
    NSString *unit = model.unit;
    NSString *text = [NSString stringWithFormat:@"%@%@", coins, unit];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:[text rangeOfString:unit]];
    model.headerDesc2 = attrText;

    InfoDescModel *content = [[InfoDescModel alloc] init];
    content.title = @[
                      [[NSAttributedString alloc] initWithString:@"赚取更多流量"],
                      [[NSAttributedString alloc] initWithString:@"|"],
                      [[NSAttributedString alloc] initWithString:@"立即赚取>>"],
                      ];
    content.desc = @[
                     @"完成带有流量奖励的任务即可以获得免费流量",
                     @"还有免费时长、零钱及VIP可以赚取"
                     ];
    content.tag = ID_TRAFFIC_MORE;
    content.actionBlock = [PersonInfoDescViewController getProfitCenterActionBlock];
    
    InfoDescModel *content2 = [[InfoDescModel alloc] init];
    content2.title = @[
                       [[NSAttributedString alloc] initWithString:@"使用免费流量"],
                       [[NSAttributedString alloc] initWithString:@"|"],
                       [[NSAttributedString alloc] initWithString:@"立即使用>>"],
                       ];
    content2.desc = @[
                      @"在充值流量时，可使用免费流量抵扣，抵扣规则见流量充值页面"
                      ];
    content2.tag = ID_TRAFFIC_USE;
    content2.actionBlock = ^ {
        NSString *flowUrl = USE_DEBUG_SERVER ? TEST_FLOW_WALLET_URL : FLOW_WALLET_URL;
        NSString *splits = [flowUrl rangeOfString:@"?"].length > 0 ? @"&" : @"?";
        NSString *token = [SeattleFeatureExecutor getToken];
        NSString *url = [NSString stringWithFormat:@"%@%@_v=3&_token=%@",flowUrl,splits,token ? token : @""];
        CTUrl *ctUrl = [[CTUrl alloc] initWithUrl:url];
        [ctUrl startWebView];
    };
    
    model.contentTitle = @"如何赚取与使用免费流量?";
    model.contentDescs = @[content, content2];
    
    return model;
}

+ (PersonInfoDescModel *) getModelByName: (NSString *)modelName {
    if ([modelName isEqualToString:MODEL_TRAFFIC]) {
        return [self trafficModel];
    } else if ([modelName isEqualToString:MODEL_BACK_FEE]) {
        return [self backFeeModel];
    } else if ([modelName isEqualToString:MODEL_FREE_FEE]) {
        return [self freeFeeModel];
    } else if ([modelName isEqualToString:MODEL_VIP_PRIVILEGE]) {
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            [SeattleFeatureExecutor getAccountNumbersInfo];
            [SeattleFeatureExecutor queryVOIPAccountInfo];
        });
        return [self PrivilegaModel];
    }
    return nil;
}

@end



@implementation InfoDescModel

@end

@implementation InfoActionModel

@end
