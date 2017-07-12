//
//  HistoryViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/5/27.
//
//

#import "HistoryViewController.h"
#import "TPHttpRequest.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "HistoryCell.h"
#import <MJExtension.h>
#import "HistoryModel.h"
#import "TouchPalVersionInfo.h"


@interface HistoryViewController ()

@property (strong, nonatomic) NSMutableArray *datas;

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _datas = [[NSMutableArray alloc]init];
    [self initView];
}

-(void)initView
{
    [self.view setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"]];
    [self initHeader];
    [self initBody];
    [self requestList];
}


-(void)requestList
{
    NSString *url = USE_DEBUG_SERVER ? @"http://121.52.250.39:30007/voip/ttbpay_history" : @"http://ws2.cootekservice.com/voip/ttbpay_history";
    [[TPHttpRequest sharedTPHttpRequest] post:url content:nil success:^(id respondObj) {
        NSData *data = respondObj;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *resDic  = [resultDic objectForKey:@"result"];
        NSArray *resArray = [resDic objectForKey:@"result"];
        if(!IS_NS_COLLECTION_EMPTY(resArray))
        {
            for(id reslut in resArray)
            {
                HistoryModel *model  = [HistoryModel mj_objectWithKeyValues:reslut];
                [_datas addObject:model];
            }
        }
        NSArray *temps= [[_datas reverseObjectEnumerator] allObjects];
        [_datas removeAllObjects];
        [_datas addObjectsFromArray:temps];
        
        [_tableView reloadData];
    } fail:^(id respondObj, NSError *error) {
        
    }];
    
}


-(void)initHeader
{
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    
    TPHeaderButton *gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    titleLabel.text = @"充值历史记录";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerBar addSubview:titleLabel];
}


-(void)initBody
{
    _tableView = [[UITableView alloc]init];
    _tableView.frame = CGRectMake(0, TPHeaderBarHeightDiff() + 45, TPScreenWidth(), TPScreenHeight()-(TPHeaderBarHeightDiff() + 45) - 40);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.font = [UIFont systemFontOfSize:13.0f];
    tipLabel.frame = CGRectMake(0,TPScreenHeight() - 40 , TPScreenWidth(), 40);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"我们为您保留最近2个月的充值记录";
    [self.view addSubview:tipLabel];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(IS_NS_COLLECTION_EMPTY(_datas)){
        return 0;
    }
    return [_datas count];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *cell = [[HistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[HistoryCell identify]];
    if(!IS_NS_COLLECTION_EMPTY(_datas)){
        [cell setData:[_datas objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (void) gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
