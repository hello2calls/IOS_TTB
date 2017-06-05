//
//  ContactTouchpalViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/4/22.
//
//

#import "ContactTouchpalViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"
#import "ContactModelNew.h"
#import "SectionIndexView.h"
#import "ClearView.h"
#import "TouchpalMembersManager.h"
#import "ContactItemCell.h"
#import "ContactInfoManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "VoipShareAllView.h"
#import "PullDownSheet.h"
#import "GroupOperationCommandCreator.h"
#import "SmartGroupNode.h"
#import "CootekNotifications.h"
#import "HandlerWebViewController.h"
#import "TouchPalVersionInfo.h"
#import "FavoriteNopersonHintView.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "AllViewController.h"
#import "FunctionUtility.h"
#import "GroupDeleteContactCommand.h"

@interface ContactTouchpalViewController()
<UITableViewDelegate,
UITableViewDataSource,
SectionIndexDelegate,
PullDownSheetDelegate,
LongGestureStatusChangeDelegate,
ContactItemCellProtocol>{
    TPHeaderButton *_cancelButton;
    UITableView *_tableView;
    NSMutableDictionary *section_map;
    SectionIndexView *section_index_view;
    ClearView *clear_view;
    
    NSMutableDictionary *valuesDic;
    NSMutableArray *keyArray;
    
    LongGestureController *longGestureController_;
    BaseContactCell *longModeCell;
    UILabel* headerTitle;
    
    PullDownSheet *_pullDownSheet;
    TPHeaderButton *_operation_button;
    
    UIView *loadingView;
    UIImageView *loadingDissy;
    FavoriteNopersonHintView *noResisterView;
    UIView *shareView;
}

@end

@implementation ContactTouchpalViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    valuesDic = [NSMutableDictionary dictionary];
    keyArray = [NSMutableArray array];
    
    [self.view setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"]];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // HeaderBar
    HeaderBar* headBar = [[HeaderBar alloc] initHeaderBar];
    [headBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headBar];
    
    // back button
    
    _cancelButton = [[TPHeaderButton alloc] initWithFrame:CGRectMake(0,3, 50, 45) ];
    [_cancelButton setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [_cancelButton addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
    [headBar addSubview:_cancelButton];
    
    headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, TPHeaderBarHeightDiff(), TPScreenWidth() - 60*2, 50)];
    [headerTitle setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    if ([TouchpalMembersManager getTouchpalerArrayCount]>0) {
        headerTitle.text = [NSString stringWithFormat:@"触宝好友(%d)",[TouchpalMembersManager getTouchpalerArrayCount]];
    }else{
        headerTitle.text = [NSString stringWithFormat:@"触宝好友"];
    }
    
    [headBar addSubview:headerTitle];
    
    //operation button
    CGSize buttonSize = CGSizeMake(50, 45);
    CGRect buttonFrame = CGRectMake(TPScreenWidth()-50, 0, buttonSize.width, buttonSize.height);
    
    _operation_button = [[TPHeaderButton alloc] initWithFrame:buttonFrame];
    [_operation_button setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [_operation_button setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
    _operation_button.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    _operation_button.selected = NO;
    [_operation_button addTarget:self action:@selector(onClickOperateButton) forControlEvents:UIControlEventTouchUpInside];
    [headBar addSubview:_operation_button];
    
    PullDownSheet *sheet = [[PullDownSheet alloc] initWithContent:nil];
    sheet.delegate = self;
    _pullDownSheet = sheet;

    [self.view addSubview:_pullDownSheet];
    
    shareView = [[UIView alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), 44)];
    shareView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"contact_touchpaler_view_share_view_bg_color"];
    [self.view addSubview:shareView];
    
    UIFont *font =[UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_3];
    CGSize size = [@"好友间免时长，邀请得200分钟" sizeWithFont:font];
    UILabel *shareLabel = [[UILabel alloc]initWithFrame:CGRectMake(CONTACT_CELL_LEFT_GAP, 0, size.width, shareView.frame.size.height)];
    shareLabel.text = @"好友间免时长，邀请得200分钟";
    shareLabel.backgroundColor = [UIColor clearColor];
    if ([[TPDialerResourceManager sharedManager] isUsingDefaultSkin]) {
        shareLabel.textColor = [UIColor whiteColor];
    } else {
        shareLabel.textColor = [TPDialerResourceManager getColorForStyle:@"defaultCellMainText_color"];
    }
    shareLabel.font = font;
    [shareView addSubview:shareLabel];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 76, 9, 66, 26)];
    shareButton.layer.masksToBounds = YES;
    shareButton.layer.cornerRadius = 4.0f;
    [shareButton setTitle:NSLocalizedString(@"invite_friends", @"邀请有奖") forState:UIControlStateNormal];
    [shareButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"contact_touchpal_share_button_text_color"] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_4_5];
    [shareButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"contact_touchpal_share_button_bg_image"] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"contact_touchpal_share_button_hl_bg_image"] forState:UIControlStateHighlighted];
    [shareView addSubview:shareButton];
    [shareButton addTarget:self action:@selector(shareToFriend) forControlEvents:UIControlEventTouchUpInside];
    shareView.hidden = YES;
    
    //TTB修改
//    float globayY = TPHeaderBarHeight() + shareView.frame.size.height;
    float globayY = TPHeaderBarHeight() ;

    

    noResisterView = [[FavoriteNopersonHintView alloc] initWithContactNoUnRegFrame:CGRectMake(0, globayY, TPScreenWidth(), 200)];
    [noResisterView setSkinStyleWithHost:self forStyle:@"noGroupmemberHint_style"];
    [noResisterView.fav_button setTitle:NSLocalizedString(@"invite_friends", @"邀请有奖") forState:UIControlStateNormal];
    [noResisterView.fav_button addTarget:self action:@selector(shareToFriend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:noResisterView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, globayY, TPScreenWidth(), TPScreenHeight()-globayY)];
    [_tableView setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = CELL_HEIGHT;
    _tableView.sectionHeaderHeight = 23;
    [self.view addSubview:_tableView];
    
    // set section index view.
    CGFloat indexSearchHeight = TPScreenHeight() * INDEX_SECTION_VIEW_HEIGHT_PERCENT;
    CGFloat searchY = _tableView.frame.origin.y  + (_tableView.frame.size.height - indexSearchHeight ) / 2;
    SectionIndexView *tmpsection_index_view = [[SectionIndexView alloc] initSectionIndexView:CGRectMake(
            TPScreenWidth() - INDEX_SECTION_VIEW_WIDTH, searchY,
            INDEX_SECTION_VIEW_WIDTH, indexSearchHeight)];
    section_index_view = tmpsection_index_view;
    [section_index_view setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
    section_index_view.delegate = self;
    [self.view addSubview:section_index_view];
    
    // init clear view. when sectionindexview touching, show this.
    ClearView *tmp_clear = [[ClearView alloc] initWithFrame:CGRectMake(TPScreenWidth()-150, 150, 70, 70)];
    clear_view = tmp_clear;
    [clear_view setSkinStyleWithHost:self forStyle:@"ClearViewBackground_color"];
    clear_view.alpha = 0.8;
    clear_view.layer.masksToBounds = YES;
    clear_view.layer.cornerRadius = clear_view.frame.size.width / 2 ;
    
    longGestureController_ = [[LongGestureController alloc] initWithViewController:((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController
                                                                         tableView:_tableView
                                                                        delegate:self
                                                                     supportedType:LongGestureSupportedTypeAllContact];
    
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frame.origin.y , _tableView.frame.size.width, _tableView.frame.size.height)];
    [self.view addSubview:loadingView];
    
    loadingDissy = [[UIImageView alloc] initWithFrame:CGRectMake(loadingView.frame.size.width/2 - 16.5, loadingView.frame.size.height/2 - 40, 33, 33)];
    loadingDissy.image = [[TPDialerResourceManager sharedManager] getImageByName:@"loading_circle@2x.png"];
    [loadingView addSubview:loadingDissy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDefaultValue) name:N_PERSON_DATA_CHANGED object:nil];



}


- (void)shareToFriend{
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    
    
    
    HandlerWebViewController *webVC = [[HandlerWebViewController alloc] init];
    NSString *url = USE_DEBUG_SERVER ? TEST_INVITE_REWARDS_WEB : INVITE_REWARDS_WEB;
    webVC.url_string = [url stringByAppendingString:@"?share_from=ContactFriend"];
    webVC.header_title = NSLocalizedString(@"invite_friends", @"邀请有奖");
    [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:YES];

    [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(0)), nil];
}

- (void)beginLoadingAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = HUGE_VALF;
    [loadingDissy.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


//TTB修改
- (void)getDefaultValue{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableDictionary *temptDic = [NSMutableDictionary dictionary];
        NSMutableArray *temptArray = [NSMutableArray array];
        [TouchpalMembersManager getTouchpaler:temptDic andKeys:temptArray];
        [TouchpalMembersManager removeAllNewTouchpaler];
        dispatch_async(dispatch_get_main_queue(), ^{
            valuesDic = temptDic;
            keyArray = temptArray;
            if (keyArray.count==0) {
                noResisterView.hidden = NO;
                _tableView.hidden = YES;
                shareView.hidden = YES;
            }else{
                noResisterView.hidden = YES;
                _tableView.hidden = NO;
//                shareView.hidden = NO;
                shareView.hidden = YES;
            }
            [self buildSectionIndexView];
            if ([TouchpalMembersManager getTouchpalerArrayCount]>0) {
                headerTitle.text = [NSString stringWithFormat:@"触宝好友(%d)",[TouchpalMembersManager getTouchpalerArrayCount]];
            }else{
                headerTitle.text = [NSString stringWithFormat:@"触宝好友"];
            }
            [self closeAnimation];
            [_tableView reloadData];
        });
    });
}

- (void)startAnimation{
    loadingView.hidden = NO;
    [self beginLoadingAnimation];
}

- (void)closeAnimation{
    loadingView.hidden = YES;
    [loadingDissy.layer removeAllAnimations];
}


- (void)viewWillAppear:(BOOL)animated{
    [self startAnimation];
    [self getDefaultValue];
    [self removePullDownSheet];
    [[TPDialerResourceManager sharedManager]makeSureStatusBarChanged];
    [super viewWillAppear:animated];
}

-(void)goToBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buildSectionIndexView {
    NSArray *marr = [NSArray arrayWithObjects:@"♡", @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"*", nil];
    NSMutableDictionary *section_navigate_dic = [NSMutableDictionary dictionaryWithCapacity:[marr count]];
    int section = -1;
    for (int i = 0; i < [marr count]; i++) {
        if ([keyArray indexOfObject:[marr objectAtIndex:i]] != NSNotFound){
            section++;
        }
        NSString *content = [marr objectAtIndex:i];
        [section_navigate_dic setObject:[NSNumber numberWithInt:(section == -1 ? 0 : section)] forKey:content];
    }
    section_map = section_navigate_dic;
    section_index_view.hidden = section == -1 ? YES : NO;
}

- (void)onClickOperateButton {
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    _operation_button.selected = YES;
    NSString *title = [[[GroupDeleteContactCommand alloc] init] getCommandName];
    [GroupOperationCommandCreator executeCommandWithTitle:title AndCurrentNode:nil withPersonArray:nil];
}


#pragma mark PullDownSheetDelegate
- (void)doClickOnPullDownSheet:(int)index{
    NSArray *title =[GroupOperationCommandCreator getCommandList:OperationSheetTypeSmartGroup withContacts:YES withPhones:YES];
    if (index < title.count) {
        [GroupOperationCommandCreator executeCommandWithTitle:title[index] AndCurrentNode:nil withPersonArray:nil];
    }
}

- (void)removePullDownSheet{
    _operation_button.selected = NO;
    [_pullDownSheet removeFromSuperview];
}

#pragma mark ContactItemCellProtocol
- (void)clickCell:(UITableViewCell*)cell{
    if(![longGestureController_ inLongGestureMode]) {
        NSIndexPath* indexPath = [_tableView indexPathForCell:cell];
        int section = [indexPath section];
        int rowIndex = [indexPath row];
        id personData;
        NSInteger person_id ;
        personData = [[valuesDic objectForKey:[keyArray objectAtIndex:section]] objectAtIndex:rowIndex];
        person_id = ((ContactCacheDataModel *)personData).personID;
        
        if (person_id > 0) {
            [[ContactInfoManager instance] showContactInfoByPersonId:person_id];
        }
        [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
    }else {
        [longGestureController_ exitLongGestureMode];
    }
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [keyArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[valuesDic objectForKey:[keyArray objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"contact_touchpal";
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    ContactCacheDataModel* cachePersonData = (ContactCacheDataModel *)([[valuesDic objectForKey:[keyArray objectAtIndex:section]] objectAtIndex:row]);
    ContactItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ( cell == nil ){
        cell = [[ContactItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier
                                             personId:cachePersonData.personID
                                      isRequiredCheck:NO
                                         withDelegate:self
                                                 size:CGSizeMake(TPScreenWidth(), CONTACT_CELL_HEIGHT)];
        [cell setSkinStyleWithHost:self forStyle:@"ContactItemCell_style"];
        [cell hidePartBLine];
    } else {
        cell.operView.hidden = YES;
        [cell hidePartBLine];
    }
    
    if ((int)[indexPath row]+1 == (int)[_tableView numberOfRowsInSection:[indexPath section]]) {
        [cell hidePartBLine];
    } else {
        [cell showPartBLine];
    }
    
    if ( [longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare: indexPath] == NSOrderedSame) {
        
        [cell.operView addSubview:longGestureController_.operView.bottomView];
        [cell hidePartBLine];
        cell.operView.hidden = NO;
        [cell showAnimation];
        longModeCell = cell;
    }
    
    [(ContactItemCell *)cell setMemberCellDataWithCacheItemData:cachePersonData displayType:DisplayTypeDefault];
    cell.is_checked = cell.person_data.isChecked;
    [cell updateCheckStatus:cell.person_data.isChecked];
    
    TPUIButton *photoButton = [[TPUIButton alloc] initWithFrame:CGRectMake(0, 0, CELL_HEIGHT, 50)];
    photoButton.backgroundColor = [UIColor clearColor];
    [cell addSubview:photoButton];
    photoButton.titleLabel.text =  [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
    [photoButton addTarget:self action:@selector(showOperView:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)showOperView:(UIButton *)sender {
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    } else {
        NSArray *tmp = [sender.titleLabel.text componentsSeparatedByString:@":"];
        NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:[tmp[1] integerValue] inSection:[tmp[0] integerValue]];
        NSArray *indexPathArray = [_tableView indexPathsForVisibleRows];
        for (int i = [indexPathArray count]-1; i >= [indexPathArray count]-2; i --) {
            if ([currentIndex compare:indexPathArray[i]] == NSOrderedSame) {
                longGestureController_.showScrollToShow = YES;
                break;
            }
        }
        longGestureController_.currentSelectIndexPath = currentIndex;
        [longGestureController_ enterLongGestureMode];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGRect holderFrame = CGRectMake(0, 0, tableView.frame.size.width - INDEX_SECTION_VIEW_WIDTH, CONTACT_CELL_SECTION_HEADER_HEIGHT);
    UIView *holderView = [[UIView alloc] initWithFrame:holderFrame];
    holderView.backgroundColor = [UIColor clearColor];
    
    UIView *container = [[UIView alloc]initWithFrame:holderFrame];
    
    container.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellHeaderBG_color"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CONTACT_CELL_LEFT_GAP, 0, holderFrame.size.width - CONTACT_CELL_LEFT_GAP, holderFrame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellSectionHeader_color"];
    
    NSString *keySection = [keyArray objectAtIndex:section];
    if ( [keySection isEqualToString:@"新增好友"] ){
        label.text = [NSString stringWithFormat:@"%@(%d)",keySection,[[valuesDic objectForKey:[keyArray objectAtIndex:section]] count]];
        label.textColor = [TPDialerResourceManager getColorForStyle:@"contact_touchpaler_new_header_color"];
    }else{
        label.text = [keyArray objectAtIndex:section];
    }
    
    [container addSubview:label];
    [holderView addSubview:container];
    
    return holderView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CONTACT_CELL_SECTION_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare:indexPath] == NSOrderedSame) {
        return 2 * CONTACT_CELL_HEIGHT;
    } else {
        return CONTACT_CELL_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark SectionIndexDelegate

- (void)addClearView{
    [self.view addSubview:clear_view];
}

- (void)beginNavigateSection:(NSString *)section_key{
    if ( [keyArray count] == 0 ){
        return;
    }
    NSInteger section_number = [[section_map objectForKey:section_key]integerValue];
    if([_tableView numberOfSections] ==0)
        return;
    int rows = [_tableView numberOfRowsInSection:section_number];
    if (rows >0 ) {
        if ([keyArray containsObject:@"新增好友"]){
            section_number = section_number + 1;
        }
        NSIndexPath *mpath = [NSIndexPath indexPathForRow:0 inSection:section_number];
        [_tableView scrollToRowAtIndexPath:mpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        NSString *clearStr = [keyArray objectAtIndex:section_number];
        [clear_view setSectionKey:clearStr];
    }
}

- (void)move:(double)top{
    clear_view.frame = CGRectMake(clear_view.frame.origin.x, top,clear_view.frame.size.width , clear_view.frame.size.height);
}

- (void)endNavigateSection{
    [clear_view removeFromSuperview];
}

#pragma  mark Enter_or_exit_multiselect_mode
- (void)enterLongGestureMode{
    if (longGestureController_.showScrollToShow) {
        longGestureController_.showScrollToShow = NO;
        [_tableView scrollToRowAtIndexPath:longGestureController_.currentSelectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    section_index_view.hidden = YES;
    [_tableView reloadData];
}

- (void)exitLongGestureMode
{
    [longModeCell exitAnimation];
    section_index_view.hidden = NO;
    [_tableView reloadData];
}

- (void)dealloc{
    [longGestureController_ tearDown];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
