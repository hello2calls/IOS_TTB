//
//  FuWuHaoListController.m
//  TouchPalDialer
//
//  Created by tanglin on 15-8-4.
//
//

#import <Foundation/Foundation.h>
#import "PublicNumberListController.h"
#import "UITableView+TP.h"
#import "PublicNumberListItemView.h"
#import "PushConstant.h"
#import "PublicNumberProvider.h"
#import "TouchPalVersionInfo.h"
#import "SeattleFeatureExecutor.h"
#import "NetworkUtility.h"
#import "UserDefaultsManager.h"
#import "PublicNumberMessage.h"
#import "TPDialerResourceManager.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "CootekNotifications.h"

#define GET_INFO_INTERVAL 10 * 60
@implementation PublicNumberListController
@synthesize displayTableView;
@synthesize gobackBtn;
@synthesize publicNumberInfos;
@synthesize blankImage;
@synthesize emptyTitleLabel;
@synthesize emptyContentLabel;

- (void)loadView
{
    cootek_log(@"FuWuHaoListController->loadView");
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    [self getBackGroundView].backgroundColor = [UIColor whiteColor];
    
    NSString* title = @"服务号";
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    self.headerView = headerBar;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:titleLabel];
    
    
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if(isVersionSix) {
        // back button
        UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        backBtn.autoresizingMask = UIViewAutoresizingNone;
        [backBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];
        gobackBtn = backBtn;
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
        self.backButton.hidden = YES;
        
    } else {
        // HeaderBar - cancel
        gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
        [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
        [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:gobackBtn];
        
    }

    
    // content view
    UITableView *tmp_view_content = [[UITableView alloc] initWithFrame:CGRectMake(0,TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415)) style:UITableViewStylePlain];
    
    [tmp_view_content setExtraCellLineHidden];
    tmp_view_content.delegate = self;
    tmp_view_content.dataSource = self;
    [tmp_view_content setBackgroundColor:[ImageUtils colorFromHexString:PUBLIC_NUMBER_LIST_BG_COLOR andDefaultColor:nil]];
    tmp_view_content.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:tmp_view_content];
    self.displayTableView = tmp_view_content;
    
    self.publicNumberInfos = [[NSMutableArray alloc]init];
    
    
    BOOL hasInfos = [UserDefaultsManager boolValueForKey:@"get_publicnumber_infos"];
    
    NSInteger now = [[NSDate date]timeIntervalSince1970];
    NSInteger saveTime = [UserDefaultsManager intValueForKey:@"get_publicnumber_infos_time"];
    BOOL shouldReset = (now - saveTime) > GET_INFO_INTERVAL;
    if (hasInfos && !shouldReset) {
        [self performSelectorInBackground:@selector(initPublicNumberMessages) withObject:nil];
    } else {
        [self performSelectorInBackground:@selector(initPublicNumberInfo) withObject:nil];
    }
    
    blankImage = [[UIImageView alloc]init];
    blankImage.image = [[TPDialerResourceManager sharedManager] getImageByName:@"fuwuhao_blank@2x.png"];
    float iconWidth = self.view.bounds.size.width - 40;
    float iconHeight = (self.view.bounds.size.height - TPHeaderBarHeight()) / 2 - 20;
    float _scaleRatio = iconWidth / iconHeight;
    float _scaleRatio2 = blankImage.image.size.width / blankImage.image.size.height;
    

    if (_scaleRatio > _scaleRatio2) {
        int startX = (iconWidth - iconHeight * _scaleRatio2) / 2;
        blankImage.frame = CGRectMake(startX, TPHeaderBarHeight() + 10, iconHeight * _scaleRatio2, iconHeight);
    } else {
        int startY = TPHeaderBarHeight() + (iconHeight - iconWidth / _scaleRatio2) /2;
        blankImage.frame = CGRectMake(20, startY , iconWidth, iconWidth / _scaleRatio2);
    }
    emptyTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, blankImage.frame.origin.y + blankImage.frame.size.height + 10, self.view.bounds.size.width, 30)];
    emptyTitleLabel.textAlignment = NSTextAlignmentCenter;
    emptyTitleLabel.font = [UIFont systemFontOfSize:20];
    emptyTitleLabel.text = @"暂无内容";
    emptyContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, emptyTitleLabel.frame.origin.y + 35, self.view.bounds.size.width, 25)];
    emptyContentLabel.textAlignment = NSTextAlignmentCenter;
    emptyContentLabel.font = [UIFont systemFontOfSize:14];
    emptyContentLabel.text = @"服务产生的消息会出现在这里";
    [self.view addSubview:emptyTitleLabel];
    [self.view addSubview:emptyContentLabel];
    emptyTitleLabel.hidden = YES;
    emptyContentLabel.hidden = YES;
    
    blankImage.hidden = YES;
    
    [self.view addSubview:blankImage];

    
}

- (void) viewWillAppear:(BOOL)animated
{
    [DialerUsageRecord recordpath:PATH_DAILY_REPORT kvs:Pair(ENTER_FUWUHAO, @(1)), nil];
    
    [super viewWillAppear:animated];
    self.publicNumberInfos = [NSMutableArray new];
    [PublicNumberProvider getPublicNumberInfos:self.publicNumberInfos];
    [self refreshUI];
    
}

- (void)gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

+(void)requestForPublicNumberInfos
{
    NSString* url = [NSString stringWithFormat:QUERY_PUBLIC_NUMBER_INFO, TOUCHLIFE_SITE];
    NSString* token = [SeattleFeatureExecutor getToken];
    if (ENABLE_YP_DEBUG) {
        NSString *hostAndPort = [NSString stringWithFormat:@"http://%@:%d", YP_DEBUG_SERVER_HOST, YP_DEBUG_HTTP_PORT];
        url = [NSString stringWithFormat:QUERY_PUBLIC_NUMBER_INFO_DEBUG, hostAndPort];
        token = [SeattleFeatureExecutor getToken];
    }
    
    
    NSURL *urlRequest=[NSURL URLWithString:[NSString stringWithFormat:@"%@?_token=%@&api_level=%@",url,token, WEBVIEW_JAVASCRIPT_API_LEVEL]];
    
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && [responseString length]>0) {
        NSMutableDictionary *returnData = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        NSDictionary* messagesData = [returnData objectForKey:@"result"];
        NSMutableArray* infos = [messagesData objectForKey:@"infos"];
        NSMutableArray* infoModels = [[NSMutableArray alloc]init];
        for (NSDictionary* info in infos) {
            @try {
                int available = [[info objectForKey:@"status"] isEqualToString:@"available"] ? 1: 0;
                NSString* iosDevice = [info objectForKey:@"os"];
                if (![@"ios" isEqual:iosDevice] && ![@"all" isEqual:iosDevice]) {
                    available = 0;
                }
              
                NSDictionary* me = [info objectForKey:@"menus"];
                NSString* mStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:me options:0 error:nil] encoding:NSUTF8StringEncoding];
                
                PublicNumberModel* m = [[PublicNumberModel alloc]initWithPhone:[info objectForKey:[PublicNumberProvider userPhone]] sendId:[info objectForKey:@"service_id"] name:[info objectForKey:@"title"] data:@"" menus:mStr errorUrl:[info objectForKey:@"error_url"] icon:[info objectForKey:@"icon_link"] logo:@"" compName:@"" desc:@"" andAvailible:available andFilter:[info objectForKey:@"filter"] andUrl:@""];
                if (![m isValid]) {
                    m.available = 0;
                }
                [infoModels addObject:m];
            }
            @catch (NSException *exception) {
                cootek_log(@"public number info json parse error: %@",info);
            }
            
        }
        [PublicNumberProvider addPublicNumberInfos:infoModels];
        
        [UserDefaultsManager setIntValue:[[NSDate date]timeIntervalSince1970] forKey:@"get_publicnumber_infos_time"];
        
        if(infoModels.count > 0) {
            [UserDefaultsManager setBoolValue:YES forKey:@"get_publicnumber_infos"];
        }
    }
}

+(void)requestForPublicNumberInfoByServiceId:(NSString *)serviceId{
    
    NSString* url = [NSString stringWithFormat:QUERY_PUBLIC_NUMBER_INFO_SERVICE_ID, TOUCHLIFE_SITE];
    NSString* token = [SeattleFeatureExecutor getToken];
    if (ENABLE_YP_DEBUG) {
        NSString *hostAndPort = [NSString stringWithFormat:@"http://%@:%d", YP_DEBUG_SERVER_HOST, YP_DEBUG_HTTP_PORT];
        url = [NSString stringWithFormat:QUERY_PUBLIC_NUMBER_INFO_SERVICE_ID, hostAndPort];
        token = [SeattleFeatureExecutor getToken];
    }
    
    NSURL *urlRequest=[NSURL URLWithString:[NSString stringWithFormat:@"%@?_token=%@&service_id=%@",url,token,serviceId]];
    
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && [responseString length]>0) {
        NSMutableDictionary *returnData = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSDictionary* messagesData = [returnData objectForKey:@"result"];
        NSMutableArray* infos = [messagesData objectForKey:@"infos"];
        NSMutableArray* infoModels = [[NSMutableArray alloc]init];
        for (NSDictionary* info in infos) {
            @try {
                int available = [[info objectForKey:@"status"] isEqualToString:@"available"] ? 1: 0;
                NSString* iosDevice = [info objectForKey:@"os"];
                if (![@"ios" isEqual:iosDevice] && ![@"all" isEqual:iosDevice]) {
                    available = 0;
                }
                
                NSDictionary* me = [info objectForKey:@"menus"];
                NSString* mStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:me options:0 error:nil] encoding:NSUTF8StringEncoding];
                
                PublicNumberModel* m = [[PublicNumberModel alloc]initWithPhone:[info objectForKey:[PublicNumberProvider userPhone]] sendId:[info objectForKey:@"service_id"] name:[info objectForKey:@"title"] data:@"" menus:mStr errorUrl:[info objectForKey:@"error_url"] icon:[info objectForKey:@"icon_link"] logo:@"" compName:@"" desc:@"" andAvailible:available andFilter:[info objectForKey:@"filter"] andUrl:@""];
                if (![m isValid]) {
                    m.available = 0;
                }
                [infoModels addObject:m];
            }
            @catch (NSException *exception) {
                cootek_log(@"public number info json parse error: %@",info);
            }
            
        }
        [PublicNumberProvider addPublicNumberInfos:infoModels];
    }
}

+ (void)addPublicNumberMessage:(NSDictionary *)msg{
    NSMutableArray* messageModels = [[NSMutableArray alloc]init];
    @try {
        PublicNumberMessage* m = [[PublicNumberMessage alloc]initWithMsg:msg];
        if ([m isValid]) {
            if ([m.type isEqualToString:ADVERTISEMENT]) {
                m.sendId = [NSString stringWithFormat:@"ad_%@", m.sendId];
                [PublicNumberListController updateAdvertisementMsg:m];
            }
            [messageModels addObject:m];
        }
    }
    @catch (NSException *exception) {
        cootek_log(@"public number message json parse error: %@",msg);
    }
    [PublicNumberProvider addPublicNumberMsgs:messageModels withTheBeforeMsgId:nil andIfNoah:YES];
}

-(void) refreshUI
{
    if (self.publicNumberInfos.count > 0) {
        self.blankImage.hidden = YES;
        emptyTitleLabel.hidden = YES;
        emptyContentLabel.hidden = YES;
        self.displayTableView.hidden = NO;
        [self.displayTableView reloadData];
    } else {
        self.blankImage.hidden = NO;
        emptyTitleLabel.hidden = NO;
        emptyContentLabel.hidden = NO;
        self.displayTableView.hidden = YES;
    }
    
}
- (void) initPublicNumberInfo
{
    [PublicNumberListController requestForPublicNumberInfos];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.publicNumberInfos = [[NSMutableArray alloc]init];
        [PublicNumberProvider getPublicNumberInfos:self.publicNumberInfos];
        [self refreshUI];
    });
    [self initPublicNumberMessages];
}

- (void) initPublicNumberMessages
{
    [PublicNumberListController requestForPublicNumberMsgs:REQUEST_DATA_COUNT];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.publicNumberInfos = [[NSMutableArray alloc]init];
        [PublicNumberProvider getPublicNumberInfos:self.publicNumberInfos];
        [self refreshUI];
    });
}

+ (void)requestForPublicNumberMsgs:(int) count
{
    NSString* url = [NSString stringWithFormat:QUERY_PUBLIC_NUMBER_MSG, OPEN_SITE];
    NSString* token = [SeattleFeatureExecutor getToken];
    if (ENABLE_YP_DEBUG) {
        NSString *hostAndPort = [NSString stringWithFormat:@"http://%@:%d", YP_DEBUG_SERVER_HOST, YP_DEBUG_HTTP_PORT];
        url = [NSString stringWithFormat:QUERY_PUBLIC_NUMBER_MSG_DEBUG, hostAndPort];
        token = [SeattleFeatureExecutor getToken];
    }
    
    NSURL *urlRequest=[NSURL URLWithString:[NSString stringWithFormat:@"%@?_token=%@&count=%d&api_level=%@",url,token,count, WEBVIEW_JAVASCRIPT_API_LEVEL]];
    
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && [responseString length]>0) {
         NSMutableDictionary *returnData = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSDictionary* messagesData = [returnData objectForKey:@"result"];
        NSMutableArray* messages = [messagesData objectForKey:@"messages"];
        NSMutableArray* messageModels = [[NSMutableArray alloc]init];
        for (NSDictionary* msg in messages) {
            @try {
                PublicNumberMessage* m = [[PublicNumberMessage alloc]initWithMsg:msg];
                if ([m isValid]) {
                    if ([m.type isEqualToString:ADVERTISEMENT]) {
                        m.sendId = [NSString stringWithFormat:@"ad_%@", m.sendId];
                        [PublicNumberListController updateAdvertisementMsg:m];
                    }
                    [messageModels addObject:m];
                }
            }
            @catch (NSException *exception) {
                cootek_log(@"public number message json parse error: %@",msg);
            }
        }
        [PublicNumberProvider addPublicNumberMsgs:messageModels withTheBeforeMsgId:nil andIfNoah:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:N_PUBLIC_NUMBER_UPDATE object:nil];
        });
    }
}

+ (void)updateAdvertisementMsg:(PublicNumberMessage *)m
{
    PublicNumberModel* model = [[PublicNumberModel alloc] initWithPhone:[PublicNumberProvider userPhone] sendId:m.sendId name:m.title data:@"" menus:@"" errorUrl:@"" icon:m.iconLink logo:@"" compName:@"" desc:@"" andAvailible:1 andFilter:nil andUrl:m.url];
    model.newMsgTime = [m.createTime integerValue];
    [PublicNumberProvider addPublicNumberInfos:[NSArray arrayWithObject:model]];
}

#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.publicNumberInfos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cootek_log(@"cellForRowAtIndexPath : %d, %d", indexPath.section, indexPath.row);
    NSString* identifier = @"fuwuhao";
    
    cootek_log(@"identifier : %@", identifier);
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cootek_log(@"cellForRowAtIndexPath : not reused");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        PublicNumberModel* model = [self.publicNumberInfos objectAtIndex:indexPath.section];
        PublicNumberListItemView* view = [[PublicNumberListItemView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), LIST_ITEM_ROW_HEIGHT) withPublicNumber:model];
        cell.backgroundColor = [ImageUtils colorFromHexString:PUBLIC_NUMBER_LIST_BG_COLOR andDefaultColor:nil];
        [cell addSubview:view];
    } else {
        cootek_log(@"cellForRowAtIndexPath : reused : section -> %d, row -> %d", indexPath.section, indexPath.row);
        PublicNumberListItemView* view = (PublicNumberListItemView*)[cell viewWithTag:LIST_ITEM_FUWUHAO_TAG];
        PublicNumberModel* model = [self.publicNumberInfos objectAtIndex:indexPath.section];
        view.model = model;
        [view drawView];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LIST_ITEM_ROW_HEIGHT;
}
@end
