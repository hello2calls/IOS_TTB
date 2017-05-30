//
//  AntiharassmentViewController_iOS10.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/18.
//
//

#import "AntiharassmentViewController_iOS10.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"

#import "TPDialerResourceManager.h"
#import "AntiHarassLogoCell.h"
#import "AntiHarassCell.h"
#import "AntiNormalItem.h"
#import "AntiSwitchItem.h"
#import "AntiLogoItem.h"

#import "TodayWidgetAnimationViewController.h"
#import "AntiharassChooseCityViewController.h"

#import "GuideAlertView.h"
#import "VoipShareAllView.h"

#import "AntiharassUtil.h"
#import "Reachability.h"
#import "AntiharassDataManager.h"
#import "AntiharassAdressbookUtil.h"

#import <CallKit/CallKit.h>
#import "NSString+Color.h"
#import "CootekNotifications.h"
#import "FunctionUtility.h"
#import "CitySelectViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "LocalStorage.h"
#import "AntiAninationGuideViewController_iOS10.h"
#import "YellowPageLocationManager.h"
#import "Reachability.h"
#import "DefaultUIAlertViewHandler.h"
#import "NewsBanner.h"
#define CIRCLEANIMATIONTIME (10)
#define CIRCLEANIMATIONTIMEROUT (30000)
@interface AntiharassmentViewController_iOS10 ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong)UIButton *actionButton;
@property (nonatomic,strong)UILabel  *dbVersionDateLable;
@property (nonatomic,strong) NSMutableArray *settingArr;
@property (nonatomic,assign) BOOL closeTips;
@property (nonatomic,strong)UIImageView *statusImageView;

@property (nonatomic,strong)UIView *statusNumberAndStringBgView;
@property (nonatomic,strong)UILabel *downloadIngStringlable;
@property (nonatomic,strong)CACustomTextLayer *textLayer;
@property (nonatomic,strong)CATextLayer *persentStringLayer;


@property (nonatomic,strong)UIImageView *bgCirlleStepView;
@property (nonatomic,strong)UIImageView *bgCirlleView;
@property (nonatomic,strong)UIImageView *statusStartImageView;
@property (nonatomic,strong)UIView *stringTranstarencyView;
@property (nonatomic,strong)UIView *stringTranstarencyUpDownView;
@property (nonatomic,strong)UILabel *stayLable1;
@property (nonatomic,strong)UILabel *stayLable2;
@property (nonatomic,strong)NewsBanner *autoScrollCellUp;
@property (nonatomic,strong)YYCycleViewCell *autoScrollCellDown;


@property (nonatomic,strong)NSString *stayLable1String;
@property (nonatomic,strong)NSString *stayLable2String;
@property (nonatomic,strong)NSString *dbDateString;
@property (nonatomic,strong)NSString *actionButtonString;
@property (nonatomic,strong)NSString *topViewBackgroundColorString;

@property (nonatomic,assign) BOOL dbVersionDateLableHidden;
@property (nonatomic,assign) BOOL statusSafe;
@property (nonatomic,copy) HandleBlock handleblock;
@property(nonatomic,strong) NSArray *messageArrayUp;
@property(nonatomic,strong) NSArray *messageArrayDown;
@property (nonatomic,assign) BOOL isCircleAnimation;
@property (nonatomic,assign)NSInteger countTick;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)NSTimer *outTimer;
@property (nonatomic,strong)UIAlertView *alertView;
@end

@implementation AntiharassmentViewController_iOS10

- (instancetype)init{
    if (self = [super init]) {
        _notCheckDBVersion = NO;
        self.headerTextColor = [UIColor whiteColor];
        _messageArrayUp = @[@"房产中介239562个号码",@"诈骗电话34536个号码",@"业务推销324312个号码",@"诈骗电话324312个号码",@"骚扰电话电话324312个号码"];
        _messageArrayDown = @[@"2015.8到2016.7，触宝电话共拦截骚扰电话322亿通",
                              @"电信诈骗中有6成受害者是通过接打电话上当受骗的",
                              @"2015年，全国接到诈骗信息的人数高达4.38亿",
                              @"触宝电话每天为用户拦截超过9000万通骚扰电话",
                              @"开启触宝电话骚扰拦截，将拦截95%以上的骚扰电话",
                              @"和全国3亿用户一起体验触宝安全通话",
                              @"2015年，北上广共有84.1%的用户接到过骚扰电话",
                              @"诈骗电话中， 假冒身份的诈骗类型占比高达26%",
                              @"诈骗电话中，金融理财诈骗数量最多，占比接近4成"];
        
        self.skinDisabled = YES;
    }
    return self;
}

#pragma mark - Setter / Getter

- (NSMutableArray *)settingArr{
    
    if (!_settingArr) {
        _settingArr = [NSMutableArray array];
    }
    return _settingArr;
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self updateActionButtonStatus];
    //[self viewFirstLoadChangeStringAndImage];
    
    [self setupHeaderBar];
    
    [self setupTopView];
    
    [self setupTableView];
    
    [self getAntiharassStatus];
    [self setupAntiItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEnterForgroundShouldChangeView) name:N_CALLEXTENSION_STATUS_REFRESH object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadFileError) name:N_DOWNLOAD_DB_FILE_FAIL object:nil];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_OPENED_FROM, @"center_cell"), nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAntiharassStatus) name:ANTIHARASS_UPDATE_SUCCESS_NOTICE  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(antiharassNeedHandUpdate) name:ANTIHARASS_NEED_HAND_UPDATE_NOTICE  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self getAntiharassStatus];
    if (!_notCheckDBVersion) {
        [[AntiharassDataManager sharedManager] checkUpdateAntiDataInBackground];
    }

}


- (void)startTimer {
    [self invalidateTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
}

- (void)startOutTimer {
    [self invalidateOutTimer];
    self.outTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(waitUntilCompletedLoadDb) userInfo:nil repeats:YES];
}

- (void)startTimerAndResetCountTick{
    [self invalidateTimerAndResetCountTick];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
}

- (void)invalidateTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)invalidateOutTimer {
    [self.outTimer invalidate];
    self.outTimer = nil;
}


- (void)invalidateTimerAndResetCountTick {
    [self.timer invalidate];
    self.timer = nil;
    self.countTick = 0;
}


- (void)timeTick {
    self.countTick++;
    if (self.countTick>=CIRCLEANIMATIONTIME+1) {
        [self timeStop];

    }
}

- (void)timeStop {
    [self invalidateTimerAndResetCountTick];
    [self checkIfCompletedLoadingToExtention];
}




- (void)checkIfCompletedLoadingToExtention {
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION defaultValue:NO]) {
        [self startOutTimer];
    } else {
        [self changeToSafeAnimationCompleted];
    }
}

- (void)waitUntilCompletedLoadDb {
    if (![UserDefaultsManager boolValueForKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION defaultValue:NO]) {
        [self invalidateOutTimer];
        [self changeToSafeAnimationCompleted];
        
    }
}


- (void)EnterForeground {
    [self startTimer];
    [self resumeLayer:self.topView.layer];
    [self resumeLayer:_bgCirlleStepView.layer];
}

- (void)DidEnterBackground {

    [self invalidateTimer];
    [self pauseLayer:self.topView.layer];
    [self pauseLayer:_bgCirlleStepView.layer];
}



- (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
 
    [self setupAntiItems];

}

- (void)setupHeaderBar {
    
    self.headerTitle = @"骚扰识别";
    
    UIView *headerBarBackView = [self.headerBar valueForKey:@"backView"];
    UIView *headerBarBgView = [self.headerBar valueForKey:@"bgView"];
    headerBarBackView.backgroundColor = [UIColor clearColor];
    headerBarBgView.hidden = YES;
    
}

- (void)setupTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topView.bounds.size.height, TPScreenWidth(), TPScreenHeight()-_topView.bounds.size.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = tableView;
    UIView *blueBgView = [[UIView alloc] initWithFrame:CGRectMake(0, -TPScreenHeight(), TPScreenWidth(), TPScreenHeight())];
    blueBgView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    //[tableView insertSubview:blueBgView atIndex:1];
    
    [self.view insertSubview:tableView atIndex:1];
}

- (BOOL)ifHaveNetWork {
    if ([Reachability network]>0) {
        return YES;
    }
    [DefaultUIAlertViewHandler showAlertViewWithTitle:nil message:@"网络无连接，请开启网络后下载" cancelTitle:nil
                                              okTitle:@"我知道了" okButtonActionBlock:nil];
    return NO;
}

- (void)setupTopView {
    [_topView removeFromSuperview];
    
    UIImage *Image = [TPDialerResourceManager getImage:@"antiharasss10_bg@2x.png"];
    CGFloat logoHeight = Image.size.height / Image.size.width * TPScreenWidth();
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), logoHeight+175)];
    [self.view insertSubview:_topView atIndex:1];
    _topView.backgroundColor = [TPDialerResourceManager getColorForStyle:_topViewBackgroundColorString];

    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.userInteractionEnabled = YES;
    bgImageView.frame = CGRectMake(17, CGRectGetMaxY(self.headerBar.frame)-10, TPScreenWidth()-2*17, logoHeight);
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = Image;
    [_topView addSubview:bgImageView];
    
    
    
    
    
    Image = [TPDialerResourceManager getImage:@"antiharasss10_circlebg@2x.png"];
    CGFloat logoWidth = Image.size.width/Image.size.height * (bgImageView.bounds.size.height);
    logoHeight = Image.size.height / Image.size.width * (bgImageView.bounds.size.height);
    self.bgCirlleView = [[UIImageView alloc] init];
    _bgCirlleView.hidden = YES;
    _bgCirlleView.userInteractionEnabled = YES;
    _bgCirlleView.frame = CGRectMake(0,0, logoWidth, logoHeight);
    _bgCirlleView.contentMode = UIViewContentModeScaleAspectFill;
    _bgCirlleView.image = Image;
    _bgCirlleView.center = bgImageView.center;
    [_topView addSubview:_bgCirlleView];
    
    
    self.bgCirlleStepView = [[UIImageView alloc] init];
    Image = [TPDialerResourceManager getImage:@"antiharasss10_circle_step@2x.png"];
    logoWidth = Image.size.width/Image.size.height * (bgImageView.bounds.size.height);
    logoHeight = Image.size.height / Image.size.width * (bgImageView.bounds.size.height);
    _bgCirlleStepView.userInteractionEnabled = YES;
    _bgCirlleStepView.frame = CGRectMake(0,0, logoWidth, logoHeight);
    _bgCirlleStepView.contentMode = UIViewContentModeScaleAspectFill;
    _bgCirlleStepView.image = Image;
    _bgCirlleStepView.center = bgImageView.center;
    _bgCirlleStepView.hidden = YES;
    [_topView addSubview:_bgCirlleStepView];

    
    
    self.statusImageView = [[UIImageView alloc] init];
    _statusImageView.userInteractionEnabled = YES;
    if(_statusSafe) {
        Image = [TPDialerResourceManager getImage:@"antiharasss10_status_safe@2x.png"];
    } else {
        Image = [TPDialerResourceManager getImage:@"antiharasss10_status_unsafe@2x.png"];
    }
   
    _statusImageView.contentMode   = UIViewContentModeScaleToFill;
    _statusImageView.image = Image;
    _statusImageView.tp_width = 230;
    _statusImageView.tp_height = 230;
    _statusImageView.hidden = YES;
    _statusImageView.center = bgImageView.center;
    [_topView addSubview:_statusImageView];
    
    
    _statusNumberAndStringBgView = [[UIView alloc] init];
    _statusNumberAndStringBgView.tp_width = 230;
    _statusNumberAndStringBgView.tp_height = 230;
    _statusNumberAndStringBgView.center = bgImageView.center;
    [_topView addSubview:_statusNumberAndStringBgView];
    
    
    UIFont *stringFont = [UIFont systemFontOfSize:18];
    CGSize stringSize = [@"号码库下载" sizeWithFont:stringFont];
    self.downloadIngStringlable =[[UILabel alloc] initWithFrame:CGRectMake(0, 80, stringSize.width, stringSize.height)];
    _downloadIngStringlable.tp_x =(_statusNumberAndStringBgView.tp_width-stringSize.width)/2;
    _downloadIngStringlable.font = stringFont;
    _downloadIngStringlable.textColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    _downloadIngStringlable.backgroundColor = [UIColor clearColor];
    _downloadIngStringlable.text = @"号码库下载";
    _statusNumberAndStringBgView.hidden = YES;
    [_statusNumberAndStringBgView addSubview:_downloadIngStringlable];
    
    stringFont = [UIFont systemFontOfSize:35];
    //stringSize = [@"100%" sizeWithFont:stringFont];
    _textLayer = [[CACustomTextLayer alloc] init];
    _textLayer.frame = CGRectMake((_statusNumberAndStringBgView.tp_width-stringSize.width)/2, CGRectGetMaxY(_downloadIngStringlable.frame)+10, 100, 100);
    _textLayer.alignmentMode = kCAAlignmentLeft;
    _textLayer.font = (__bridge CFTypeRef _Nullable)(stringFont);
    //_textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    [_statusNumberAndStringBgView.layer addSublayer:_textLayer];

    stringSize = [@"%" sizeWithFont:stringFont];
    self.persentStringLayer =[[CATextLayer alloc] init];
    _persentStringLayer.frame = CGRectMake(CGRectGetMaxX(_textLayer.frame), _textLayer.frame.origin.y, stringSize.width, stringSize.height);
    _persentStringLayer.font = (__bridge CFTypeRef _Nullable)(stringFont);
    _persentStringLayer.foregroundColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_white"].CGColor;
    _persentStringLayer.backgroundColor = [UIColor clearColor].CGColor;
    _persentStringLayer.string = @"%";
    _persentStringLayer.hidden = YES;
    [_statusNumberAndStringBgView.layer addSublayer:_persentStringLayer];
    
    
    
    
    
    self.statusStartImageView = [[UIImageView alloc] init];
    _statusStartImageView.userInteractionEnabled = YES;
    Image = [TPDialerResourceManager getImage:@"antiharasss10_status_start@2x.png"];
    _statusStartImageView.contentMode = UIViewContentModeScaleToFill;
    _statusStartImageView.image=Image;
    _statusStartImageView.tp_width=33;
    _statusStartImageView.tp_height=33;
    _statusStartImageView.frame=CGRectMake(156, 54, 30, 30);
    [_statusImageView addSubview:_statusStartImageView];

    
    
    self.stringTranstarencyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgImageView.frame)-50, TPScreenWidth(), self.topView.bounds.size.height-CGRectGetMaxY(bgImageView.frame)+50)];
    _stringTranstarencyView.backgroundColor = [UIColor clearColor];
    [self.topView addSubview:_stringTranstarencyView];
    
    

    
    
    
    self.stayLable1 = [[UILabel alloc] init];
    stringFont = [UIFont systemFontOfSize:22];
    stringSize = [_stayLable1String sizeWithFont:stringFont];
    _stayLable1.frame = CGRectMake((TPScreenWidth()-stringSize.width)/2, 25, stringSize.width,20);
    _stayLable1.text = _stayLable1String;
    _stayLable1.font = stringFont;
    _stayLable1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    [_stringTranstarencyView addSubview:_stayLable1];

    
    
    self.stayLable2 = [[UILabel alloc] init];
    stringFont = [UIFont systemFontOfSize:14];
    stringSize = [_stayLable2String sizeWithFont:stringFont];
    _stayLable2.frame = CGRectMake(0, 0, stringSize.width, stringSize.height);
    _stayLable2.text = _stayLable2String;
    _stayLable2.font = stringFont;
    _stayLable2.frame = CGRectMake((TPScreenWidth()-stringSize.width)/2, CGRectGetMaxY(_stayLable1.frame)+6, stringSize.width, stringSize.height);
    _stayLable2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"];
    [_stringTranstarencyView addSubview:_stayLable2];

    
    //动画
    _stringTranstarencyUpDownView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgImageView.frame)-50, TPScreenWidth(), self.topView.bounds.size.height-CGRectGetMaxY(bgImageView.frame)+50)];
    _stringTranstarencyUpDownView.backgroundColor = [UIColor clearColor];
    _stringTranstarencyUpDownView.hidden = YES;
    [self.topView addSubview:_stringTranstarencyUpDownView];
    
    
    
    
    _autoScrollCellUp = [[NewsBanner alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width ,_stringTranstarencyUpDownView.tp_height-100)];
    _autoScrollCellUp.leftAndNumberStringList = @[@[@"房产中介",@"诈骗电话",@"业务推销",@"黄页识别",@"骚扰电话"],@[@"96314",@"56215",@"61312",@"85454",@"79546"]];
    _autoScrollCellUp.lableDuration = CIRCLEANIMATIONTIME/5-0.3;
    _autoScrollCellUp.pushDuration = 0.5;
    _autoScrollCellUp.hidden = YES;
    [_stringTranstarencyUpDownView addSubview:_autoScrollCellUp];
    
    
    _autoScrollCellDown = [[YYCycleViewCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_autoScrollCellUp.frame)-20, [UIScreen mainScreen].bounds.size.width ,_stringTranstarencyUpDownView.tp_height-100) font:[UIFont systemFontOfSize:14]contentArray:_messageArrayDown fullDuriation:CIRCLEANIMATIONTIME animationDuration:0];
    _autoScrollCellDown.hidden = YES;
    [_stringTranstarencyUpDownView addSubview:_autoScrollCellDown];
    
    
    self.actionButton = [[UIButton alloc] init];
    CGFloat tipsButtonW         =   180;
    CGFloat tipsButtonH         =   44;
    _actionButton.frame = CGRectMake((TPScreenWidth()-tipsButtonW)/2, CGRectGetMaxY(_stayLable2.frame)+34, tipsButtonW, tipsButtonH);
    [_actionButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:_actionButton.bounds] forState:UIControlStateHighlighted];
    _actionButton.titleLabel.font      = [UIFont systemFontOfSize:18];
    _actionButton.backgroundColor      = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    _actionButton.layer.masksToBounds  = YES;
    _actionButton.layer.cornerRadius   = 22;
    [_actionButton setTitle:_actionButtonString forState:UIControlStateNormal];
    [_actionButton setTitleColor:[[TPDialerResourceManager sharedManager]getUIColorFromNumberString:_topViewBackgroundColorString] forState:(UIControlStateNormal)];
    [_actionButton addTarget:self action:@selector(tryToUpdateAntiharassDate) forControlEvents:UIControlEventTouchUpInside];
    [_stringTranstarencyView addSubview:_actionButton];

    
    
    
    self.dbVersionDateLable = [[UILabel alloc] init];
    stringSize = [_dbDateString sizeWithFont:[UIFont systemFontOfSize:12]];
    _dbVersionDateLable.frame = CGRectMake((TPScreenWidth()-stringSize.width)/2, CGRectGetMaxY(_actionButton.frame)+5, stringSize.width, 20);
    _dbVersionDateLable.font = [UIFont systemFontOfSize:12];
    _dbVersionDateLable.text = _dbDateString;
    _dbVersionDateLable.hidden = _dbVersionDateLableHidden;
    _dbVersionDateLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"];
    [_stringTranstarencyView addSubview:_dbVersionDateLable];

}

- (void)checkEnterForgroundShouldChangeView {
    [self setupAntiItems];
    [self updateActionButtonStatus];
    if (_isCircleAnimation) {
        return;
    }
    NSInteger antiharassStatus = [AntiharassmentViewController_iOS10 getStatus];
    [self changeStringAndImageWithStatus:antiharassStatus];
    [self refleshStringTranstarencyViewWithStatus:antiharassStatus];
}

- (void)startUpDownViewAnimation {
    _autoScrollCellUp.hidden = NO;
    _autoScrollCellDown.hidden = NO;
    [_autoScrollCellUp star];
    [_autoScrollCellDown.cyclelView  startAnimation];
}

- (void)stopUpDownViewAnimation {
    _autoScrollCellUp.hidden = YES;
    _autoScrollCellDown.hidden = YES;
    [_autoScrollCellUp stop];
    [_autoScrollCellDown.cyclelView stopAnimation];
}
- (void)startCircleViewAndBgColorAnimation {
    _bgCirlleView.hidden = NO;
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animation];
    colorAnimation.keyPath = @"backgroundColor";
    colorAnimation.duration = CIRCLEANIMATIONTIME;
    colorAnimation.values = @[
                              (__bridge id)[TPDialerResourceManager getColorForStyle:@"0xff7c2a"].CGColor,
                              (__bridge id)[TPDialerResourceManager getColorForStyle:@"0xf9aa00"].CGColor,
                              (__bridge id)[TPDialerResourceManager getColorForStyle:@"0x37c763"].CGColor
                              ,(__bridge id)[TPDialerResourceManager getColorForStyle:@"0x03a9f4"].CGColor                  ];
    colorAnimation.removedOnCompletion = NO;
    colorAnimation.fillMode = kCAFillModeForwards;
    [_topView.layer addAnimation:colorAnimation forKey:nil];
    
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = CIRCLEANIMATIONTIMEROUT+1;
    _bgCirlleStepView.hidden = NO;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    
    [_bgCirlleStepView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    _topViewBackgroundColorString = @"0x03a9f4";
}

- (void)changeUnsafeToSafeStatusWithAnimation {
    _isCircleAnimation = YES;
    [self stopUpDownViewAnimation];
    [self invalidateTimerAndResetCountTick];
    [self startUpDownViewAnimation];
    [self startCircleViewAndBgColorAnimation];
    [self startTimer];
    
}



- (void)statusNumberAndStringViewAnimation{
    [_textLayer jumpNumberWithDuration:CIRCLEANIMATIONTIME-0.5  fromNumber:0 toNumber:99
        animationBlock:^{
        _statusNumberAndStringBgView.hidden = NO;
        _persentStringLayer.hidden = NO;
            CGSize stringSize;
            if (((NSString *)_textLayer.string).integerValue<10) {
                stringSize= [@"8" sizeWithFont:_textLayer.font];

            } else if(((NSString *)_textLayer.string).integerValue<100){
                 stringSize= [@"88" sizeWithFont:_textLayer.font];
            } else {
                stringSize= [@"100" sizeWithFont:_textLayer.font];
            }
            _textLayer.frame = CGRectMake( (_textLayer.superlayer.frame.size.width-stringSize.width-_persentStringLayer.frame.size.width)/2, _textLayer.frame.origin.y, stringSize.width, stringSize.height);
            _persentStringLayer.frame = CGRectMake(CGRectGetMaxX(_textLayer.frame), _persentStringLayer.frame.origin.y, _persentStringLayer.frame.size.width, _persentStringLayer.frame.size.height);
                }
            endBlock:^{
    }];

}




- (void)changeToSafeAnimationCompleted {
    __block AntiharassmentViewController_iOS10 *wkSelf = self;
    [_textLayer jumpNumberWithDuration:1  fromNumber:99 toNumber:100
                        animationBlock:^{
                            _statusNumberAndStringBgView.hidden = NO;
                            _persentStringLayer.hidden = NO;
                            CGSize stringSize;
                            if (((NSString *)_textLayer.string).integerValue<10) {
                                stringSize= [@"8" sizeWithFont:_textLayer.font];
                                
                            } else if(((NSString *)_textLayer.string).integerValue<100){
                                stringSize= [@"88" sizeWithFont:_textLayer.font];
                            } else {
                                stringSize= [@"100" sizeWithFont:_textLayer.font];
                            }
                            _textLayer.frame = CGRectMake( (_textLayer.superlayer.frame.size.width-stringSize.width-_persentStringLayer.frame.size.width)/2, _textLayer.frame.origin.y, stringSize.width, stringSize.height);
                            _persentStringLayer.frame = CGRectMake(CGRectGetMaxX(_textLayer.frame), _persentStringLayer.frame.origin.y, _persentStringLayer.frame.size.width, _persentStringLayer.frame.size.height);
                        }
                            endBlock:^{
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                      [wkSelf stopUpDownViewAnimation];
                                      _bgCirlleView.hidden = YES;
                                      _statusNumberAndStringBgView.hidden = YES;
                                      NSInteger antiharassStatus = [AntiharassmentViewController_iOS10 getStatus];
                                      [wkSelf changeStringAndImageWithStatus:antiharassStatus];
                                      [wkSelf refleshStringTranstarencyViewWithStatus:antiharassStatus];
                                      [wkSelf startPopstartAnimation];
                                      _isCircleAnimation = NO;
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                          if (_isCircleAnimation) {
                                              return;
                                          }
                                          if(![UserDefaultsManager boolValueForKey:ISFIRSTAUTOGUDIECON]) {
                                              if ([UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION defaultValue:NO]) {
                                                  [UserDefaultsManager setBoolValue:YES forKey:ISFIRSTAUTOGUDIECON];
                                                  return;
                                              }
                                              [wkSelf pushAntiAninationGuideViewController];
                                          }
                                          
                                      });
                                  });
                                  
                              }];
}


- (void)getAntiharassStatus {
    if (_isCircleAnimation) {
        return;
    }
    NSInteger antiharassStatus = [AntiharassmentViewController_iOS10 getStatus];
    [self changeStringAndImageWithStatus:antiharassStatus];
    [self refleshStringTranstarencyViewWithStatus:antiharassStatus];
}

-(void)readyForAnimation {
    _bgCirlleStepView.hidden = NO;
    _stringTranstarencyView.hidden = YES;
    _statusImageView.hidden = YES;
    _stringTranstarencyUpDownView.hidden = NO;
    _statusNumberAndStringBgView.hidden = NO;
}


- (void)cityChangedAnimation {
    if (_isCircleAnimation || ![self ifHaveNetWork]) {
        return;
    }
    [self readyForAnimation];
    [self changeUnsafeToSafeStatusWithAnimation];
    [self statusNumberAndStringViewAnimation];
}

- (void)reLoadCityChangedAnimation {
    if (![self ifHaveNetWork]) {
        return;
    }
    [self readyForAnimation];
    [self changeUnsafeToSafeStatusWithAnimation];
    _textLayer.ifStop = YES;
    [self statusNumberAndStringViewAnimation];

}


- (void)downLoadFileError {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:N_DOWNLOAD_DB_FILE_FAIL object:nil];
        [self DidEnterBackground];
        [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION];
        
        if (self.alertView==nil) {
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:@"防骚扰库下载失败 请重新下载" delegate:self cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
            [self.alertView show];
        }
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
    self.alertView= nil;
}


+ (NSInteger)getStatus {

    BOOL antiharassSwitchStatus =  [UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION defaultValue:NO];
    
    NSInteger dbIntVersion = [UserDefaultsManager intValueForKey:ANTIHARASS_DATAVERSION_iOS10NEW defaultValue:0];
    
    BOOL antiharassVersionStatus = dbIntVersion==0?NO:YES;
    NSInteger dbHandUpdateIntVersion = [UserDefaultsManager intValueForKey:ANTIHARASS_HAND_TOPVIEW_DATAVERSION defaultValue:0];
    BOOL antiharassUpdateStatus = dbIntVersion<dbHandUpdateIntVersion?YES:NO;
    NSInteger antiharassStatus = antiharassSwitchStatus+antiharassVersionStatus*2+ antiharassUpdateStatus*4;
    return antiharassStatus;
}


- (void)changeStringAndImageWithStatus:(ANTIHARASSTATUS)antiharassStatus {
    _dbDateString = [self getDBDateStringFormate];
    _dbVersionDateLableHidden = NO;
    _statusSafe = NO;
    switch (antiharassStatus) {
        case 0:
        case 4:
            _stayLable1String = @"安全通话尚未开启";
            _stayLable2String = @"暂时无法识别骚扰电话";
            _actionButtonString = @"开启防骚扰";
            _dbVersionDateLableHidden = YES;
            _topViewBackgroundColorString = @"0xff7c2a";
            break;
        //1
        case 2:
        case 6:
            _stayLable1String = @"安全通话尚未开启";
            _stayLable2String = @"暂时无法识别骚扰电话";
            _actionButtonString = @"开启防骚扰";
            _dbVersionDateLableHidden = NO;
            _topViewBackgroundColorString = @"0x03a9f4";
            break;
        case 3:
            _stayLable1String = @"安全通话已开启";
            _stayLable2String = @"你的通话正在保护中";
            _actionButtonString = @"已是最新版本";
            _statusSafe = YES;
            _dbVersionDateLableHidden = NO;
            _topViewBackgroundColorString = @"0x03a9f4";
            
            break;
        case 1:
        case 5:
        case 7:
            _stayLable1String = @"号码库有更新";
            _stayLable2String = @"本次新增2,335,476个号码";
            _actionButtonString = @"下载更新";
            _dbVersionDateLableHidden = NO;
            _statusSafe = YES;
            _topViewBackgroundColorString = @"0x03a9f4";
           break;
        default:
            break;
    }
    _dbVersionDateLableHidden = NO;
    
}

- (void)refleshStringTranstarencyViewWithStatus:(ANTIHARASSTATUS)antiharassStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        _stayLable1.text = _stayLable1String;
        _stayLable2.text = _stayLable2String;
        _dbVersionDateLable.text = _dbDateString;
        [_actionButton setTitle:_actionButtonString forState:(UIControlStateNormal)];
        _dbVersionDateLable.hidden = _dbVersionDateLableHidden;
        if(_statusSafe) {
            _statusImageView.image = [TPDialerResourceManager getImage:@"antiharasss10_status_safe@2x.png"];
        } else {
            _statusImageView.image = [TPDialerResourceManager getImage:@"antiharasss10_status_unsafe@2x.png"];
        }
        
        _topView.backgroundColor =[[TPDialerResourceManager sharedManager]getUIColorFromNumberString:_topViewBackgroundColorString];
        [_actionButton setTitleColor:[[TPDialerResourceManager sharedManager]getUIColorFromNumberString:_topViewBackgroundColorString] forState:(UIControlStateNormal)];
        if (_isCircleAnimation) {
            return;
        }
        switch (antiharassStatus) {
            case 0:
            case 4:
                _bgCirlleStepView.hidden = YES;
                _stringTranstarencyView.hidden = NO;
                _statusImageView.hidden = NO;
                _stringTranstarencyUpDownView.hidden = YES;
                
                break;
            //1
            case 2:
            case 6:
                _bgCirlleStepView.hidden = YES;
                _stringTranstarencyView.hidden = NO;
                _statusImageView.hidden = NO;
                _stringTranstarencyUpDownView.hidden = YES;
                break;
            case 3:
                _bgCirlleStepView.hidden = YES;
                _stringTranstarencyView.hidden = NO;
                _statusImageView.hidden = NO;
                _stringTranstarencyUpDownView.hidden = YES;
                break;
                
            case 1:
            case 5:
            case 7:
                _bgCirlleStepView.hidden = YES;
                _stringTranstarencyView.hidden = NO;
                _statusImageView.hidden = NO;
                _stringTranstarencyUpDownView.hidden = YES;
                break;
            default:
                break;
        }

        [self adjustViewSize];
        [self updateActionButtonStatus];
    });
}


- (void)adjustViewSize {
    CGSize stringSize = [_stayLable1String sizeWithFont:_stayLable1.font];
    _stayLable1.frame = CGRectMake((TPScreenWidth()-stringSize.width)/2, 25, stringSize.width,20);
    
    
    stringSize = [_stayLable2String sizeWithFont:_stayLable2.font];
    _stayLable2.frame = CGRectMake((TPScreenWidth()-stringSize.width)/2, _stayLable2.tp_y, stringSize.width, stringSize.height);
    
    stringSize = [_dbDateString sizeWithFont:_dbVersionDateLable.font];
    _dbVersionDateLable.frame = CGRectMake((TPScreenWidth()-stringSize.width)/2, CGRectGetMaxY(_actionButton.frame)+5, stringSize.width, 20);
    
}




- (void)startPopstartAnimation {
    _statusStartImageView.alpha = 0;
    _statusStartImageView.frame = CGRectMake(45*2, 45*4,30,30);
    [UIView animateWithDuration:0.5 animations:^{
        _statusStartImageView.alpha = 1;//1
    } completion:^(BOOL finished) {
        _statusStartImageView.alpha = 0;
         _statusStartImageView.frame = CGRectMake(45*4, 50*2,30,30);
        [UIView animateWithDuration:0.5 animations:^{
            _statusStartImageView.alpha = 1;//2
        } completion:^(BOOL finished) {
            _statusStartImageView.alpha = 0;
            _statusStartImageView.frame = CGRectMake(30, 40*2,30,30);
            [UIView animateWithDuration:0.5 animations:^{
                _statusStartImageView.alpha = 1;//3
            } completion:^(BOOL finished) {
                _statusStartImageView.alpha = 0;
                _statusStartImageView.frame = CGRectMake(156, 54, 30, 30);
                _statusStartImageView.alpha = 1;
            }];
        }];
    }];
}

- (void)antiharassNeedHandUpdate {
    [self updateActionButtonStatus];
    [self getAntiharassStatus];
}



- (NSString *)getDBDateStringFormate {
    NSInteger dbIntVersion = [UserDefaultsManager intValueForKey:ANTIHARASS_DATAVERSION_iOS10NEW];
    if (dbIntVersion<20160000) {
        return nil;
    }
    NSMutableString *dbStringVersion = [NSMutableString stringWithFormat:@"%ld",dbIntVersion];
    [dbStringVersion insertString:@"-" atIndex:4];
    [dbStringVersion insertString:@"-" atIndex:7];
    NSString *dateString = [NSString stringWithFormat:@"最近更新:%@",dbStringVersion];
    return dateString;
}

- (void)tryToUpdateAntiharassDate{
    if (_handleblock != nil) {
        _handleblock();
    }
}

- (void)updateActionButtonStatus {
    NSInteger dbIntVersion = [UserDefaultsManager intValueForKey:ANTIHARASS_DATAVERSION_iOS10NEW defaultValue:0];
    __weak AntiharassmentViewController_iOS10 *wkSelf  = self;
    if (![UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION defaultValue:NO]) {
        _handleblock = ^(void) {
            [wkSelf pushAntiAninationGuideViewController];
        };
    } else {
        NSInteger dbHandUpdateIntVersion = [UserDefaultsManager intValueForKey:ANTIHARASS_HAND_TOPVIEW_DATAVERSION defaultValue:0];
        if (dbHandUpdateIntVersion>dbIntVersion) {
            _handleblock = ^(void) {
                [[AntiharassDataManager sharedManager] checkUpdateAntiDataInHand];
                [wkSelf cityChangedAnimation];
                
            };
        } else {
            _handleblock = nil;
        }
    }
}

- (void)pushAntiAninationGuideViewController {
    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
        AntiAninationGuideViewController_iOS10* controller = [[AntiAninationGuideViewController_iOS10 alloc]init];
        [UserDefaultsManager setBoolValue:YES forKey:ISFIRSTAUTOGUDIECON];
        [self.navigationController pushViewController:controller animated:YES];

    }
   
}

- (void)setupAntiItems {
    
    [self.settingArr removeAllObjects];
    
    [self.settingArr addObject:[self setupForSection]];
    
    [self.tableView reloadData];

    
}

- (NSArray *)setupForSection {
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:[self creatFirstItem]];
    [arr addObject:[self creatSecondItem]];
    [arr addObject:[self creatThirdItem]];
    [arr addObject:[self creatFourthItem]];
    return arr;
}

- (AntiNormalItem *)creatFirstItem{
    
    NSString * _city = [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY];
    NSString * city = [LocalStorage getItemWithKey:QUERY_PARAM_CITY];
    NSString *antiharassOldExtensionCity = [UserDefaultsManager stringForKey:ANTIHARASSEXTENSIONCITY defaultValue:@""];
    NSString *antiharassNewExtensionCity = @"";
    if (city.length>0) {
        antiharassNewExtensionCity = city;
    } else if(_city.length>0){
        antiharassNewExtensionCity = _city;
    } else {
        [self checkCity];
    }
    [UserDefaultsManager setObject:antiharassNewExtensionCity forKey:ANTIHARASSEXTENSIONCITY];
    if(![antiharassOldExtensionCity isEqualToString:antiharassNewExtensionCity]) {
        //切换城市下载
        [[AntiharassDataManager sharedManager] checkUpdateAntiDataInHand];
        [self reLoadCityChangedAnimation];
    }

    AntiNormalItem *firstItem = [AntiNormalItem itemWithTitle:@"我的常住城市" subtitle:antiharassNewExtensionCity vcClass:nil clickHandle:^{
        if (_isCircleAnimation || [UserDefaultsManager boolValueForKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION defaultValue:NO]) {
            return ;
        }
         CitySelectViewController* controller = [[CitySelectViewController alloc]init];
        [[TouchPalDialerAppDelegate naviController]pushViewController:controller animated:YES];
    }];
    return firstItem;
    
}

- (void)checkCity {
    __weak AntiharassmentViewController_iOS10 *wkSelf = self;
    void(^locationBlock)(BOOL isLocation, CLLocationCoordinate2D location) = ^(BOOL isLocation, CLLocationCoordinate2D location) {
        
        
        if (isLocation) {
            [wkSelf updateCity];
        } else {
            if ([UserDefaultsManager boolValueForKey:@"LOCATE_FIRST" defaultValue:YES]) {
                CitySelectViewController* controller = [[CitySelectViewController alloc]init];
                [[TouchPalDialerAppDelegate naviController]pushViewController:controller animated:YES];
                
            }
            [LocalStorage setItemForKey:QUERY_PARAM_CITY andValue:@"全国"];
        }
        if ([UserDefaultsManager boolValueForKey:@"LOCATE_FIRST" defaultValue:YES]) {
            [UserDefaultsManager setBoolValue:NO forKey:@"LOCATE_FIRST"];
        }
    };
    [[YellowPageLocationManager instance] addCallBackBlock:locationBlock];
    [[YellowPageLocationManager instance] locate:YES checkPermission:NO];

}

- (void)selectCityIfChange {
    NSString * _city = [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY];
    NSString * city = [LocalStorage getItemWithKey:QUERY_PARAM_CITY];
    NSString *antiharassOldExtensionCity = [UserDefaultsManager stringForKey:ANTIHARASSEXTENSIONCITY defaultValue:@""];
    NSString *antiharassNewExtensionCity = @"";
    if (_city.length==0) {
        antiharassNewExtensionCity = city;
    } else if(_city.length>0) {
        antiharassNewExtensionCity = _city;
    } else {
        [self checkCity];
    }
    
    if(antiharassOldExtensionCity.length==0 || ![antiharassOldExtensionCity isEqualToString:antiharassNewExtensionCity]) {
        [self cityChangedAnimation];
    }
}
- (void)updateCity
{
    NSString * _city = [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY];
    NSString * city = [LocalStorage getItemWithKey:QUERY_PARAM_CITY];
    
    int now = [[NSDate date] timeIntervalSince1970];
    int locTime = [[LocalStorage getItemWithKey:QUERY_LAST_CACHE_TIME_CITY] intValue];
    
    NSString * lastCity = [LocalStorage getItemWithKey:QUERY_LAST_PARAM_CITY];
    
    if ((now - locTime > 24 * 60 * 60) || ![_city isEqualToString:lastCity])
    {
        //保存最后一次定位成功的时间和城市
        [LocalStorage setItemForKey:QUERY_LAST_CACHE_TIME_CITY andValue:[NSString stringWithFormat:@"%d", now]];
        [LocalStorage setItemForKey:QUERY_LAST_PARAM_CITY andValue:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
        
        //替换当前选择城市为当前定位城市
        [LocalStorage setItemForKey:QUERY_PARAM_CITY andValue:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
        
        //刷新页面
        if (![city isEqualToString:_city])
        {
            [UserDefaultsManager setObject:_city forKey:INDEX_CITY_SELECTED];
            [self setupAntiItems];
            [self cityChangedAnimation];
        }
    }
}


// data point
- (AntiNormalItem *)creatSecondItem {
    AntiSwitchItem *secondItem =[AntiSwitchItem itemWithTitle:@"自动更新" subtitle:nil settingKey:CALL_DIRECTORY_EXTENSION_AUTO_UPDATE willSwitchHandle:^(BOOL on) {
        if (![UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION defaultValue:NO] || [UserDefaultsManager boolValueForKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION defaultValue:NO]) {
            return ;
        }
        [UserDefaultsManager setBoolValue:![UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTO_UPDATE defaultValue:NO] forKey:CALL_DIRECTORY_EXTENSION_AUTO_UPDATE];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_CALLEXTENSION_STATUS_REFRESH object:nil];
        [DialerUsageRecord recordpath:PATH_ANTIHARASS_AUTO_UPDATE kvs:Pair(PATH_ANTIHARASS_AUTO_UPDATE, @([UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTO_UPDATE defaultValue:NO])), nil];
    }];
    return secondItem;
}

- (AntiNormalItem *)creatThirdItem {
    __weak typeof(self) weakSelf = self;
    NSString *badge = [UserDefaultsManager boolValueForKey:ANTIHARASS_SHOULD_HIDE_READ_ME_DOT defaultValue:NO] ? nil : @"NEW";
    AntiNormalItem *thirdItem = [AntiNormalItem itemWithTitle:@"使用必读" subtitle:@"" vcClass:nil clickHandle:^{
        [weakSelf onHelpPressed];
    }];
    thirdItem.badge = badge;
    return thirdItem;
}

- (AntiNormalItem *)creatFourthItem {
    AntiNormalItem *fourthItem = [AntiNormalItem itemWithTitle:@"分享给iPhone小伙伴" subtitle:@"" vcClass:nil clickHandle:^{
        
        UIImage *image = [TPDialerResourceManager getImage:@"antiharass_share_weixin@2x.png"];
        [VoipShareAllView shareWithTitle:@"iPhone也能识别骚扰电话了！" msg:@"" url:@"http://www.chubao.cn/s/1015_ios530/xxxxxx.html" imageUrl:@"" andFrom:@"antiharass" image:image];
        
    }];
    return fourthItem;
}



#pragma mark - Event

- (void) onHelpPressed {
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CLICK_FAQ, @(1)), nil];
    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOULD_HIDE_READ_ME_DOT];
    //    dotLabel.hidden = [UserDefaultsManager boolValueForKey:ANTIHARASS_SHOULD_HIDE_READ_ME_DOT defaultValue:NO];
    [AntiharassUtil showGuidePage];
}

- (void) onDatabasePressed {
    
}


- (void) onAntiharassSwitch {
    
}

- (void) onAntiHarassUpInWifiSwitch {
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AntiNormalItem *item = [self.settingArr objectAtIndex:indexPath.section][indexPath.item];
    if (item.clickHandle) {
        item.clickHandle();
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.settingArr objectAtIndex:section] count];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.settingArr.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AntiHarassCell *cell = nil;
    
    AntiNormalItem *item = [self.settingArr objectAtIndex:indexPath.section][indexPath.item];
    
    cell = [AntiHarassCell cellWithTableView:tableView settingItem:item];
    
    if (indexPath.item == 0 && indexPath.item == [_settingArr[indexPath.section] count] - 1) {
        cell.separateLineType = SettingCellSeparateLineTypeSingle;
    }else if(indexPath.item == 0){
        cell.separateLineType = SettingCellSeparateLineTypeHeader;
    }else if(indexPath.item == [_settingArr[indexPath.section] count] - 1){
        cell.separateLineType = SettingCellSeparateLineTypeFooter;
    }else{
        cell.separateLineType = SettingCellSeparateLineTypeNormal;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AntiNormalItem *item = [self.settingArr objectAtIndex:indexPath.section][indexPath.item];
    
    return item.height;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else if (section == 1 && self.closeTips != YES) {
        return 28;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == self.settingArr.count - 1) {
        return 20;
    }
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] init];
    if (section == 0) {
        headerView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    } else {
        headerView.backgroundColor = [UIColor clearColor];
    }
    return headerView;
    
}

- (void)dealloc {
    [self invalidateTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
