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

@interface HistoryViewController ()

@property (strong, nonatomic) NSMutableArray *datas;

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
    NSString *url = @"http://121.52.250.39:30007/voip/ttbpay_history";
    [[TPHttpRequest sharedTPHttpRequest] post:url content:nil success:^(id respondObj) {
        
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
    UITableView *tableView = [[UITableView alloc]init];
    tableView.frame = CGRectMake(0, TPHeaderBarHeightDiff() + 45, TPScreenWidth(), TPScreenHeight()-(TPHeaderBarHeightDiff() + 45));
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
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
    return cell;
}

- (void) gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
