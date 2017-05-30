//
//  LoginPassViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 14-10-24.
//
//

#import "LoginPassViewController.h"
#import "TPDialerResourceManager.h"
#import "CallLogDBA.h"
#import "VoipCommonModel.h"
#import "VoipTopSectionHeaderBar.h"
#import "VoipFriendViewCell.h"

@interface LoginPassViewController () <VoipTopSectionHeaderBarProtocol, UIGestureRecognizerDelegate, UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    UIScrollView *_frontView;
    UITableView *_cootekFriendTableView;
}

@end

@implementation LoginPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    //self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"defaultBackground_color"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    VoipTopSectionHeaderBar *headerBar = [[VoipTopSectionHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 45 + TPHeaderBarHeightDiff())];
    headerBar.delegate = self;
    headerBar.backgroundColor = [UIColor greenColor];
    [self.view addSubview:headerBar];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _frontView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, headerBar.frame.size.height, TPScreenWidth(), TPScreenHeight()-headerBar.frame.size.height)];
    [self.view addSubview:_frontView];
    
    //scrollView的content长度
    int totalHeight = 544;
    if (totalHeight > _frontView.frame.size.height){
        _frontView.scrollEnabled = YES;
        _frontView.bounces = YES;
        _frontView.showsHorizontalScrollIndicator = NO;
        _frontView.showsVerticalScrollIndicator = NO;
        [_frontView setContentSize:CGSizeMake(TPScreenWidth() , totalHeight)];
    }else{
        [_frontView setContentSize:CGSizeMake(TPScreenWidth() , TPScreenHeight())];
    }
    
    _cootekFriendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headerBar.frame.size.height , TPScreenWidth(), TPScreenHeight() - headerBar.frame.size.height) style:UITableViewStylePlain];
    _cootekFriendTableView.backgroundColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"defaultBackground_color"];
    _cootekFriendTableView.delegate = self;
    _cootekFriendTableView.dataSource = self;
    _cootekFriendTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _cootekFriendTableView.rowHeight = VOIP_CELL_HEIGHT;
    [self.view addSubview:_cootekFriendTableView];

}

- (void) gotoBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"voip_pass_queue_invite";
    int section = [indexPath section];
    int row = [indexPath row];
    int number = section * 3 + row;
    VoipFriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[VoipFriendViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:cellIdentifier
                                                personId:number
                                                    size:CGSizeMake(TPScreenWidth(), VOIP_CELL_HEIGHT)
                                                   image:[TPDialerResourceManager getImage:@"bing_validation_icon@2x.png"]];
    }else{
        [cell setData:number];
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, VOIP_LINE_HEIGHT)];
    headerView.backgroundColor = [UIColor grayColor];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, TPScreenWidth()-32, headerView.frame.size.height)];
    if (section == 0 ){
        textLabel.text = NSLocalizedString(@"voip_now_invite_friend_to_get_more_time", "");
        textLabel.textColor = [UIColor greenColor];
    }else{
        textLabel.text = NSLocalizedString(@"voip_call_cootek_user_not_stop", "");
        textLabel.textColor = [UIColor blueColor];
    }
    [headerView addSubview:textLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return VOIP_LINE_HEIGHT;
}



@end
