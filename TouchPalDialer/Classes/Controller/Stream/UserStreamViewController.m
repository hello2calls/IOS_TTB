//
//  UserStreamViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/26.
//
//

#import "UserStreamViewController.h"
#import "TPDialerResourceManager.h"
#import "TouchpalHistoryManager.h"
#import "TouchpalStreamCell.h"
#import "SeattleFeatureExecutor.h"
#import "VoipTopSectionHeaderBar.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"


@interface UserStreamViewController() <VoipTopSectionHeaderBarProtocol,UITableViewDataSource,UITableViewDelegate>{
    UITableView *streamTableView;
    VoipTopSectionHeaderBar *_headBar;
    
    UIButton *headerButton;
    
    TouchpalHistoryManager *manager;
    UIView *noThingsView;
    NSString __strong *_headerTitle;
    UIColor __strong *_bgColor;
}

@end


@implementation UserStreamViewController

- (id)initWithBonusType:(NSInteger)bonusType andHeaderTitle:(NSString*)headerTitle bgColor:(UIColor*)color{
    self = [super init];
    if ( self ){
        _bonusType = bonusType;
        _headerTitle = headerTitle;
        _bgColor = color;
        manager = [[TouchpalHistoryManager alloc]init];
        [manager loadArrayWithBonusType:_bonusType];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getHistory];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    _headBar = [[VoipTopSectionHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth() , 45+TPHeaderBarHeightDiff())];
    _headBar.delegate = self;
    _headBar.headerTitle.text = _headerTitle;
    _headBar.backgroundColor = _bgColor;
    [self.view addSubview:_headBar];
    
    [_headBar setButtonText:@"J"];
    
    streamTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headBar.frame.size.height , TPScreenWidth(), TPScreenHeight() - _headBar.frame.size.height) style:UITableViewStylePlain];
    streamTableView.backgroundColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"defaultBackground_color"];
    streamTableView.delegate = self;
    streamTableView.dataSource = self;
    streamTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    streamTableView.rowHeight = VOIP_CELL_HEIGHT;
    [self.view addSubview:streamTableView];
    
    [self.view bringSubviewToFront:_headBar];
    
    noThingsView = [[UIView alloc]initWithFrame:CGRectMake(0, (TPScreenHeight()-_headBar.frame.size.height-120)/2+_headBar.frame.size.height, TPScreenWidth(), 120)];
    noThingsView.hidden = YES;
    [self.view addSubview:noThingsView];
    
    UIImage *image = [TPDialerResourceManager getImage:@"stream_no_record@2x.png"];
    UIImageView *noThingsImageView = [[UIImageView alloc]initWithFrame:CGRectMake((TPScreenWidth()-image.size.width)/2, 0, image.size.width,image.size.height)];
    noThingsImageView.image = image;
    [noThingsView addSubview:noThingsImageView];
    
    UILabel *noThingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90 , TPScreenWidth(), FONT_SIZE_1_5)];
    noThingsLabel.text = NSLocalizedString(@"stream_no_things", "");;
    noThingsLabel.textAlignment = NSTextAlignmentCenter;
    noThingsLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_subLabel_text_color"];
    noThingsLabel.font = [UIFont systemFontOfSize:FONT_SIZE_1_5];
    noThingsLabel.backgroundColor = [UIColor clearColor];
    [noThingsView addSubview:noThingsLabel];
    
    if ( [manager.touchpalHistoryCacheArray count] == 0 ){
        noThingsView.hidden = NO;
    }
    if (_bonusType == FLOW_HISTORY)
        [DialerUsageRecord recordpath:EV_FLOW_STREAM_PAGE kvs:Pair(@"count", @(1)), nil];
}

- (void)gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getHistory{
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSArray *resultArray = [SeattleFeatureExecutor getHistory:_bonusType];
        if ( [resultArray count] > 0 ){
            [manager loadArrayWithBonusType:_bonusType];
            dispatch_sync(dispatch_get_main_queue(), ^(){
                if ( [manager.touchpalHistoryCacheArray count] == 0 ){
                    noThingsView.hidden = NO;
                }else{
                    noThingsView.hidden = YES;
                }
                [streamTableView reloadData];
            });
        }
    });
}

- (void)headerButtonAction{
    [self getHistory];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = [manager.touchpalHistoryCacheArray count];
    return count < 100 ? count : 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"touchpal_user_stream";
    int row = [indexPath row];
    C2CHistoryInfo *info = [manager.touchpalHistoryCacheArray objectAtIndex:row];
    
    TouchpalStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TouchpalStreamCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:cellIdentifier
                                                   info:info];

    }else{
        [cell setData:info];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
