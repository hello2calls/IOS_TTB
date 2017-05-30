//
//  ContactHistoryViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/23.
//
//

#import "ContactHistoryViewController.h"
#import "ContactHistoryHeaderBar.h"
#import "TPDialerResourceManager.h"
#import "ContactHistoryCell.h"
#import "ContactHistoryInfo.h"

@interface ContactHistoryViewController()
<ContactHistoryHeaderBarDelegate,
UITableViewDataSource,
UITableViewDelegate>{
    UITableView *_tableView;
    UIView *_noRecordView;
    ContactHistoryHeaderBar *_headerBar;
}

@end

@implementation ContactHistoryViewController

- (void)viewDidLoad{
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    _headerBar = [[ContactHistoryHeaderBar alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 45+TPHeaderBarHeightDiff()) andModel:_infoModel];
    _headerBar.delegate = self;
    [self.view addSubview:_headerBar];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _headerBar.frame.size.height, TPScreenWidth(), TPScreenHeight()-_headerBar.frame.size.height)];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    _tableView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    [self.view addSubview:_tableView];
    
    _noRecordView = [[UIView alloc]initWithFrame:CGRectMake(0, _headerBar.frame.size.height, TPScreenWidth(), TPScreenHeight()-_headerBar.frame.size.height)];
    _noRecordView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_noRecordView];
    
    float globayY = TPScreenHeight()*0.3-_headerBar.frame.size.height;
    
    UILabel *noRecordIcon = [[UILabel alloc]initWithFrame:CGRectMake(0, globayY, TPScreenWidth(), 100)];
    noRecordIcon.text = @"a";
    noRecordIcon.font = [UIFont fontWithName:@"iPhoneIcon3" size:100];
    noRecordIcon.textAlignment = NSTextAlignmentCenter;
    noRecordIcon.backgroundColor = [UIColor clearColor];
    noRecordIcon.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"];
    [_noRecordView addSubview:noRecordIcon];
    
    globayY += noRecordIcon.frame.size.height + 20;
    
    UILabel *noRecordLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globayY, TPScreenWidth(), 18)];
    noRecordLabel.text = @"暂无通话记录";
    noRecordLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
    noRecordLabel.textAlignment = NSTextAlignmentCenter;
    noRecordLabel.backgroundColor = [UIColor clearColor];
    noRecordLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_400"];
    [_noRecordView addSubview:noRecordLabel];
    
    [self refreshView];
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)refreshHeaderMode:(ContactHeaderMode)mode{
    [_headerBar refreshHeaderMode:mode];
}

- (void)refreshView{
    _noRecordView.hidden = _callList.count;
    _tableView.hidden = !_callList.count;
    if ( _callList.count == 0 )
        [_headerBar refreshHeaderMode:ContactHeaderNo];
    else
        [_headerBar refreshHeaderMode:ContactHeaderNormal];
    [_tableView reloadData];
}

- (void) showEditingMode{
    if ( _tableView.editing == NO )
        [_tableView setEditing:YES animated:YES];
}
- (void) exitEditingMode{
    if ( _tableView.editing == YES )
        [_tableView setEditing:NO animated:YES];
}

-(void)dealloc{
    [_delegate deallocHistoryViewController];
}

#pragma mark ContactHistoryHeaderBarDelegate
- (void) headerLeftButtonAction:(ContactHeaderMode)mode;{
    [_delegate headerLeftButtonAction:mode];
}

- (void) headerRightButtonAction:(ContactHeaderMode)mode;{
    [_delegate headerRightButtonAction:mode];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle==UITableViewCellEditingStyleDelete){
        int section = [indexPath section];
        int row = [indexPath row];
        ContactHistoryInfo *info = [_callList objectAtIndex:section];
        CallLogDataModel *item = [info.dateArray objectAtIndex:row];;
        [_delegate deleteCallLog:item];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_callList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ContactHistoryInfo *info = [_callList objectAtIndex:section];
    return info.dateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"contact_history_info";
    NSInteger section= [indexPath section];
    NSInteger row = [indexPath row];
    
    ContactHistoryInfo *info = [_callList objectAtIndex:section];
    CallLogDataModel *item = [info.dateArray objectAtIndex:row];;
    
    ContactHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ( cell == nil ){
        cell = [[ContactHistoryCell alloc]initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIdentifier
                                           callLogModel:item];
    }else{
        [cell refreshView:item];
    }
    
    if ((int)[indexPath row]+1 == (int)[_tableView numberOfRowsInSection:[indexPath section]]) {
        [cell hideBottomLine];
    } else {
        [cell showBottomLine];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ContactHistoryInfo *info = [_callList objectAtIndex:section];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 30)];
    view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, TPScreenWidth() - 32, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:11];
    label.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
    label.text = info.dateStr;
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section= [indexPath section];
    NSInteger row = [indexPath row];
    ContactHistoryInfo *info = [_callList objectAtIndex:section];
    CallLogDataModel *item = [info.dateArray objectAtIndex:row];;
    [_delegate onSelectHistoryCell:item];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
