//
//  FuWuHaoDetailController.m
//  TouchPalDialer
//
//  Created by tanglin on 15-8-4.
//
//

#import <Foundation/Foundation.h>
#import "PublicNumberDetailController.h"
#import "UITableView+TP.h"
#import "PublicNumberMessage.h"
#import "PublicNumberMessageView.h"
#import "PushConstant.h"
#import "PublicNumberProvider.h"
#import "TPDialerResourceManager.h"
#import "SeattleFeatureExecutor.h"
#import "TouchPalVersionInfo.h"
#import "NetworkUtility.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "FunctionUtility.h"

@interface PublicNumberDetailController()
{
    BOOL moreData;
    NSMutableArray* loadMoreMessages;
    NSMutableArray* tempMessages;
    NSMutableArray* deleteMessages;
    PublicNumberMessage* firstMsg;
    UIActionSheet *sheet;
    NSIndexPath* selectedPath;
    CGRect savedFrame;
    int contentSize;
    
    NSMutableArray* _noahArray;
    NSMutableArray* _displayArray;
}

@end
@implementation PublicNumberDetailController
@synthesize displayTableView;
@synthesize publicNumberMesssages;
@synthesize gobackBtn;
@synthesize model;
@synthesize refreshControl;
@synthesize confirmButton;
@synthesize cancelButton;

- (void)loadView
{
    cootek_log(@"PublicNumberDetailController->loadView");
    
    [super loadView];
    
    NSString* title = self.model.name;
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
    
    gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];
   
    int bottomBarOffset = 0;
    if(model.menus && model.menus.length > 0) {
        NSArray* menusDic = [NSJSONSerialization JSONObjectWithData:[model.menus dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        // bottom bar
        TPBottomBar *bottomBar = [[TPBottomBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - PUBLIC_NUMBER_BOTTOM_BAR_HEIGHT, TPScreenWidth(), PUBLIC_NUMBER_BOTTOM_BAR_HEIGHT) andArray:menusDic];
        [self.view addSubview:bottomBar];
        if (!bottomBar.hidden) {
            bottomBarOffset = PUBLIC_NUMBER_BOTTOM_BAR_HEIGHT;
        }
    }
    
    // content view
    UITableView *tmp_view_content = [[UITableView alloc] initWithFrame:CGRectMake(0,self.headerView.frame.size.height, TPScreenWidth(), self.view.frame.size.height - bottomBarOffset - TPHeaderBarHeight()) style:UITableViewStylePlain];
    
    [tmp_view_content setExtraCellLineHidden];
    tmp_view_content.delegate = self;
    tmp_view_content.dataSource = self;
    tmp_view_content.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tmp_view_content setSeparatorColor:[UIColor grayColor]];
    [tmp_view_content setBackgroundColor:[ImageUtils colorFromHexString:MSG_ITEM_DETAIL_BG_COLOR andDefaultColor:nil]];
    tmp_view_content.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, MSG_ITEM_MARGIN_BOTTOM)];
    [tmp_view_content.tableFooterView setBackgroundColor:[ImageUtils colorFromHexString:MSG_ITEM_DETAIL_BG_COLOR andDefaultColor:nil]];
    
    self.publicNumberMesssages = [[NSMutableArray alloc]init];
    [self.view addSubview:tmp_view_content];
    self.displayTableView = tmp_view_content;
    _noahArray = [[NSMutableArray alloc]init];
    _displayArray = [[NSMutableArray alloc]init];
    
    [PublicNumberProvider getPublicNumberMsgs:self.publicNumberMesssages withNoahArray:_noahArray withSendId:self.model.sendId count:REQUEST_MSG_DATA_COUNT fromMsgId:nil];
    moreData = YES;
    [self generateDisplayArray];
    if ( self.publicNumberMesssages.count != 0 )
        firstMsg = [self.publicNumberMesssages objectAtIndex:0];

    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.displayTableView addSubview:refreshControl];
    
    [self.displayTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"编辑服务号消息"
                                        delegate:self
                               cancelButtonTitle:@"取消"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"删除选中消息", @"删除全部消息", nil];
    deleteMessages = [NSMutableArray new];
    tempMessages = [NSMutableArray new];
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 0.5;
    [self.displayTableView addGestureRecognizer:longPressGr];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FunctionUtility updateStatusBarStyle];
}

- (void) generateDisplayArray{
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    [mutableArray addObjectsFromArray:self.publicNumberMesssages];
    [mutableArray addObjectsFromArray:_noahArray];
    
    NSArray *sortArray = [mutableArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PublicNumberMessage *msg1 = obj1;
        PublicNumberMessage *msg2 = obj2;
        if ([msg1.createTime integerValue] > [msg2.createTime integerValue]) {
            return NSOrderedDescending;
        } else {
            if([msg1.createTime integerValue] == [msg2.createTime integerValue]){
                if ([msg1.msgId compare:msg2.msgId]) {
                    return NSOrderedDescending;
                }
            }
            return NSOrderedAscending;
        }
    }];
    
    _displayArray = [NSMutableArray arrayWithArray:sortArray];
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:self.displayTableView];
        selectedPath = [self.displayTableView indexPathForRowAtPoint:point];
        if(selectedPath == nil) return ;
        
        // Show the sheet
        [sheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(!_displayArray || _displayArray.count <= 0) {
        return;
    }
    
    NSLog(@"Button %d", buttonIndex);
    PublicNumberMessage* message = [_displayArray objectAtIndex:selectedPath.section];
    switch (buttonIndex) {
        case 0:
        {
            [PublicNumberProvider deletePublicNumberMsg:message];
            [PublicNumberProvider updatePublicInfoDescriptionWithSendId:message.sendId];
            [_displayArray removeObjectAtIndex:selectedPath.section];
            if ( message.ifNoah ){
                int removePos = 0;
                for ( int i = 0 ; i < _noahArray.count ; i ++ ){
                    PublicNumberMessage *msg = [_noahArray objectAtIndex:i];
                    if ( [msg.msgId isEqualToString:message.msgId] ){
                        removePos = i;
                        break;
                    }
                }
                [_noahArray removeObjectAtIndex:removePos];
            }else{
                int removePos = 0;
                for ( int i = 0 ; i < self.publicNumberMesssages.count ; i ++ ){
                    PublicNumberMessage *msg = [self.publicNumberMesssages objectAtIndex:i];
                    if ( [msg.msgId isEqualToString:message.msgId] ){
                        removePos = i;
                        break;
                    }
                }
                [self.publicNumberMesssages removeObjectAtIndex:removePos];
            }
            [self.displayTableView reloadData];
            break;
        }
        case 1:
        {
            [PublicNumberProvider deleteAllPublicNumberByServiceId:self.model.sendId];
            [self.publicNumberMesssages removeAllObjects];
            [_noahArray removeAllObjects];
            [_displayArray removeAllObjects];
            [self.displayTableView reloadData];
            break;
        }
        default:
            break;
    }
    
}

- (void) refresh:(UIRefreshControl *)refreshContrl
{
    savedFrame = self.displayTableView.bounds;
    contentSize = self.displayTableView.contentSize.height;
    if (!moreData) {
        [refreshContrl endRefreshing];
        return;
    }
    
    if (!firstMsg && _displayArray.count <= 0) {
        return;
    }
    
    loadMoreMessages = [[NSMutableArray alloc] init];
    [PublicNumberProvider getPublicNumberMsgs:loadMoreMessages withNoahArray:_noahArray withSendId:model.sendId count:REQUEST_MSG_DATA_COUNT fromMsgId:firstMsg.msgId];
    if (loadMoreMessages.count == 0) {
        if (self.publicNumberMesssages.count > 0 || firstMsg) {
            [self performSelectorInBackground:@selector(requestMessagesFromNetwork) withObject:nil];
        } else {
            [refreshControl endRefreshing];
        }
        return;
    } else if(loadMoreMessages.count > 0 && loadMoreMessages.count < REQUEST_MSG_DATA_COUNT) {
        [self performSelectorInBackground:@selector(requestMessagesFromNetwork) withObject:nil];
    }
    
    for (int i = loadMoreMessages.count - 1; i < loadMoreMessages.count; i--){
        [self.publicNumberMesssages insertObject:[loadMoreMessages objectAtIndex:i] atIndex:0];
    }
    if ( self.publicNumberMesssages.count != 0 )
        firstMsg = [self.publicNumberMesssages objectAtIndex:0];
    [self generateDisplayArray];
    [self.displayTableView reloadData];
    CGSize temp = self.displayTableView.contentSize;
    if (savedFrame.size.width > 0) {
        savedFrame.origin.y = temp.height - contentSize + savedFrame.origin.y;
        [self.displayTableView scrollRectToVisible:savedFrame animated:NO];
    }
    [refreshContrl endRefreshing];
    
}

- (void) requestMessagesFromNetwork
{
    NSString* url = [NSString stringWithFormat:QUERY_PUBLIC_NUMBER_MSG, OPEN_SITE];
    NSString* token = [SeattleFeatureExecutor getToken];
    if (USE_DEBUG_SERVER) {
        url = [NSString stringWithFormat:QUERY_PUBLIC_NUMBER_MSG_DEBUG, YP_DEBUG_SERVER];
    }

    NSURL *urlRequest=[NSURL URLWithString:[NSString stringWithFormat:@"%@?_token=%@&msg_id=%@&count=%d&service_id=%@&api_level=%@",url,token, firstMsg.msgId, REQUEST_MSG_DATA_COUNT, firstMsg.sendId, WEBVIEW_JAVASCRIPT_API_LEVEL]];
    
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && [responseString length] > 0) {
        NSMutableDictionary *returnData = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSDictionary* messagesData = [returnData objectForKey:@"result"];
        NSMutableArray* messages = [messagesData objectForKey:@"messages"];
        NSMutableArray* messageModels = [[NSMutableArray alloc]init];
        if (messages.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                return;
            });
        }
        for (NSDictionary* msg in messages) {
            @try {
                PublicNumberMessage* m = [[PublicNumberMessage alloc]initWithMsg:msg];
                if ([m isValid]) {
                    [messageModels addObject:m];
                }
            }
            @catch(NSException *exception)
            {
                cootek_log(@"json is invalid:",msg);
            }
        }
        [PublicNumberProvider addPublicNumberMsgs:messageModels withTheBeforeMsgId:firstMsg andIfNoah:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL refreshUI = NO;
            if (loadMoreMessages.count == 0) {
                refreshUI = YES;
                loadMoreMessages = [[NSMutableArray alloc]init];
            }
            
            if (refreshUI) {
                [PublicNumberProvider getPublicNumberMsgs:loadMoreMessages withNoahArray:_noahArray withSendId:self.model.sendId count:REQUEST_MSG_DATA_COUNT fromMsgId:firstMsg.msgId];
                
                for (int i = loadMoreMessages.count - 1; i < loadMoreMessages.count; i--){
                    [self.publicNumberMesssages insertObject:[loadMoreMessages objectAtIndex:i] atIndex:0];
                }
                [self generateDisplayArray];
                [self.displayTableView reloadData];
                if (self.publicNumberMesssages.count == 0) {
                    firstMsg = nil;
                } else {
                    firstMsg = [self.publicNumberMesssages objectAtIndex:0];
                    CGSize temp = self.displayTableView.contentSize;
                    if (savedFrame.size.width > 0) {
                        savedFrame.origin.y = temp.height - contentSize + savedFrame.origin.y;
                        [self.displayTableView scrollRectToVisible:savedFrame animated:NO];
                    }
                }
            }

            if (loadMoreMessages.count == 0) {
                moreData = NO;
            }
            [self.refreshControl endRefreshing];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }

}

- (void)gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _displayArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cootek_log(@"cellForRowAtIndexPath : %d, %d", indexPath.section, indexPath.row);
    NSString* identifier = @"fuwuhao_detail";
    
    cootek_log(@"identifier : %@", identifier);
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    PublicNumberMessage* message = [_displayArray objectAtIndex:indexPath.section];
    if (!cell) {
        cootek_log(@"cellForRowAtIndexPath : not reused");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        
        PublicNumberMessageView* view = [[PublicNumberMessageView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), [PublicNumberMessageView getRowHeight:message]) withPublicNumberMsg:message];
        cell.backgroundColor = [UIColor clearColor];
        [cell addSubview:view];
    } else {
        cootek_log(@"cellForRowAtIndexPath : reused : section -> %d, row -> %d", indexPath.section, indexPath.row);
        PublicNumberMessageView* view = (PublicNumberMessageView*)[cell viewWithTag:LIST_ITEM_FUWUHAO_DETAIL_TAG];
        [view drawView:message];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PublicNumberMessage* message = [_displayArray objectAtIndex:indexPath.section];
    return [PublicNumberMessageView getRowHeight:message];
}

@end
