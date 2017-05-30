//
//  ContactInfoViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/16.
//
//

#import "ContactInfoViewController.h"
#import "TPDialerResourceManager.h"
#import "ContactInfoMainView.h"
#import "ContactInfoButtonView.h"
#import "ContactInfoCellModel.h"
#import "ContactInfoCell.h"
#import "ContactInfoHeaderView.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#import "TouchpalMembersManager.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"

#define MAIN_HEIGHT ((TPScreenHeight()>600)?280:(240+TPHeaderBarHeightDiff()))

@interface ContactInfoViewController()
<ContactInfoMainViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
ContactInfoCellProtocol,
ContactInfoHeaderViewDelegate>{
    ContactInfoMainView *_mainView;
    ContactInfoHeaderView *_headerView;
    UITableView *_tableView;
    
    NSString *_copyStr;
    BOOL _scrollDown;
    CGFloat _lastMainHeight;
}

@end


@implementation ContactInfoViewController

- (void)viewDidLoad{
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    
    NSDictionary *propertyDict = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"KnownContactInforViewController_style"];
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDict objectForKey:@"backgroundColor"]];
    
    _mainView = [[ContactInfoMainView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), MAIN_HEIGHT) infoModel:_infoModel];
    _mainView.delegate = self;
    [self.view addSubview:_mainView];
    _lastMainHeight = _mainView.frame.size.height;
    
    _headerView = [[ContactInfoHeaderView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 45 +TPHeaderBarHeightDiff()) andInfoModel:_infoModel];
    _headerView.delegate = self;
    [self.view addSubview:_headerView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _mainView.frame.size.height, TPScreenWidth(), TPScreenHeight()-_mainView.frame.size.height)];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    [self.view addSubview:_tableView];
    
    //long press copy
    UILongPressGestureRecognizer *longPressReger = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onTableViewLongPress:)];
    [_tableView addGestureRecognizer:longPressReger];
    longPressReger.minimumPressDuration = 0.8;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void) refreshButtonView{
    [_mainView refreshButtonView:_infoModel];
    [_headerView refreshHeaderView:_infoModel];
}

- (void) refreshView{
    [_mainView refreshView:_infoModel];
    [_headerView refreshHeaderView:_infoModel];
    [_tableView reloadData];
}

- (void) refreshTableView{
    [_tableView reloadData];
}

-(void)dealloc{
    [_delegate deallocTheController];
}

- (void)onTableViewLongPress:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    if(gesture.state == UIGestureRecognizerStateBegan){
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        ContactInfoCell *cell = (ContactInfoCell *)[_tableView cellForRowAtIndexPath:indexPath];
        [self becomeFirstResponder];
        UIMenuController *copy  = [UIMenuController sharedMenuController];
        [copy setTargetRect:[cell frame] inView:_tableView];
        [copy setMenuVisible:YES animated:YES];
        ContactInfoCellModel *info = [self getInfoBySection:section row:row];
        _copyStr = info.mainStr;
    }
}

#pragma mark ContactInfoHeaderViewDelegate

- (void)onLeftButtonAction{
    [_delegate popViewController];
}

- (void)onRightButtonAction{
    [_delegate onRightButtonAction];
}

#pragma mark ContactInfoMainViewDelegate

- (void)onIconButtonAction{
    [_delegate onIconButtonAction];
}

#pragma mark ContactInfoButtonViewDelegate

- (void)onButtonPressed:(NSInteger)tag{
    [_delegate onButtonPressed:tag];
}


#pragma mark ContactInfoCellProtocol
- (void)onCellRightButtonPressed:(ContactInfoCellModel *)model{
    [_delegate onCellRightButtonPressed:model];
}
#pragma mark tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    int sectionCount = 2; //for number array
//    if (_subArray.count > 0) {
//        sectionCount++;
//    }
//    if (_shareArray.count > 0) {
//        sectionCount++;
//    }

//    return sectionCount;
    BOOL isRegistered = NO;
    NSInteger personId = _infoModel.personId;
    if (personId > 0) {
        // only for contacts
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        for (PhoneDataModel *phone in personData.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                isRegistered = YES;
            }
        }
    }

     if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON] && !isRegistered) {
      
         return 3;
         
     }else{
         return 2;
     }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BOOL isRegistered = NO;
    NSInteger personId = _infoModel.personId;
    if (personId > 0) {
        // only for contacts
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        for (PhoneDataModel *phone in personData.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                isRegistered = YES;
            }
        }
    }
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON] && !isRegistered) {
        // if logged in;
        // the first section is the number array, the second array is the share array
        // the third section only exsits only if the number is in the contact list.
        switch (section) {
            case 0: {
                return _numberArray.count;
            }
            case 1: {
                return _shareArray.count;
            }
            case 2: {
                return _subArray.count;
            }
            default:
                break;
        }
        
    } else {
        // not logged in, do not contain the share array section
        switch (section) {
            case 0: {
                return _numberArray.count;
            }
            case 1: {
                return _subArray.count;
            }
                
            default:
                break;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    ContactInfoCellModel *info = [self getInfoBySection:section row:row];
    
    if ( info.cellType == CellPhone || info.cellType == CellFaceTime) {
        return 66;
    } else if (info.cellType == CellInviting) {
        //in the share array
        return 66;
    }
    
    CGSize mainSize = [info.mainStr sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:17]
                               constrainedToSize:CGSizeMake(TPScreenWidth()-32, 100)];
    NSInteger mainLabelHeight = ceil(mainSize.height) > 20? ceil(mainSize.height) : 20;
    return mainLabelHeight + 46 > 66 ? mainLabelHeight + 46 : 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"contact_info";
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    ContactInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    ContactInfoCellModel *info = [self getInfoBySection:section row:row];
    if (cell == nil ){
        cell = [[ContactInfoCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellIdentifier
                                ContactInfoCellModel:info
                                            personId:_infoModel.personId];
        cell.delegate = self;
    }else{
        [cell refreshView:info];
    }
    
    if ((int)[indexPath row]+1 == (int)[tableView numberOfRowsInSection:[indexPath section]]) {
        [cell hideBottomLine];
    } else {
        [cell showBottomLine];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if ( section == 0 ) {
//        return 0;
//    }
    
    NSInteger totlalSection = [self numberOfSectionsInTableView:tableView];
    if (totlalSection == 3) {
        // if logged in;
        // the first section is the number array, the second array is the share array
        // the third section only exsits only if the number is in the contact list.
        switch (section) {
            case 0: {
                return 0 ;
            }
            case 1: {
                return _shareArray.count ? 20 : 0;
            }
            case 2: {
                return 20;
            }
            default:
                break;
        }
        
    } else {
        // not logged in, do not contain the share array section
        switch (section) {
            case 0: {
                return 0;
            }
            case 1: {
                return 20;
            }
                
            default:
                break;
        }
    }

    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 20)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    ContactInfoCellModel *info = [self getInfoBySection:section row:row];
    [_delegate onSelectCell:info];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOffset = scrollView.contentOffset.y;
    cootek_log(@"offset:%.2f", yOffset);
    if ( yOffset == 0 )
        return;
    CGRect mainFrame = _mainView.frame;
    CGRect tableFrame = _tableView.frame;
    CGFloat moveHeight = mainFrame.size.height - yOffset;
    CGFloat mainHeight = 0;
    
    if ( mainFrame.size.height > _lastMainHeight )
        _scrollDown = YES;
    else
        _scrollDown = NO;
    _lastMainHeight = mainFrame.size.height;
    
    if ( moveHeight < 45 + TPHeaderBarHeightDiff() ){
        mainHeight = 45 + TPHeaderBarHeightDiff();
    }else if ( moveHeight > MAIN_HEIGHT ){
        mainHeight = MAIN_HEIGHT;
    }else{
        mainHeight = moveHeight;
        //scrollView.contentOffset = CGPointMake(0, 0);
    }
    _mainView.frame = CGRectMake(mainFrame.origin.x, mainFrame.origin.y , mainFrame.size.width, mainHeight);
    _tableView.frame = CGRectMake(tableFrame.origin.x, mainHeight, tableFrame.size.width, TPScreenHeight() - mainHeight);
    
    [_mainView doViewShrunk];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter]postNotificationName:N_SCROLL_ENABLE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:KEY_SCROLL]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ( !decelerate )
        [self scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollView];
}


- (void)scrollView{
    if ( _tableView.contentOffset.y != 0 )
        [[NSNotificationCenter defaultCenter]postNotificationName:N_SCROLL_ENABLE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:KEY_SCROLL]];
    else
        [[NSNotificationCenter defaultCenter]postNotificationName:N_SCROLL_ENABLE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:KEY_SCROLL]];
    
    if ( _mainView.frame.size.height >= MAIN_HEIGHT || _mainView.frame.size.height <= 45 + TPHeaderBarHeightDiff() ){
        return;
    }
    CGRect mainFrame = _mainView.frame;
    CGRect tableFrame = _tableView.frame;
    CGFloat mainHeight = 0;
    if ( _scrollDown ){
        if ( _mainView.frame.size.height > 45 + TPHeaderBarHeightDiff() + (MAIN_HEIGHT - 45 - TPHeaderBarHeightDiff())*0.4  )
            mainHeight = MAIN_HEIGHT;
        else
            mainHeight = 45 + TPHeaderBarHeightDiff();
    }else{
        if ( _mainView.frame.size.height > 45 + TPHeaderBarHeightDiff() + (MAIN_HEIGHT - 45 - TPHeaderBarHeightDiff())*0.7 )
            mainHeight = MAIN_HEIGHT;
        else
            mainHeight = 45 + TPHeaderBarHeightDiff();
    }
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(){
                         _mainView.frame = CGRectMake(mainFrame.origin.x, mainFrame.origin.y , mainFrame.size.width, mainHeight);
                         _tableView.frame = CGRectMake(tableFrame.origin.x, mainHeight, tableFrame.size.width, TPScreenHeight() - mainHeight);
                         [_mainView doViewShrunk];
                     }
                     completion:^(BOOL finish){
                         if ( finish )
                             [[NSNotificationCenter defaultCenter]postNotificationName:N_SCROLL_ENABLE object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:KEY_SCROLL]];
                     }];
}

#pragma mark UIResponderStandardEditActions
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}

- (void)copy:(id)sender {
    if (_copyStr == nil) {
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
    [pasteboard setString:_copyStr];
    [self resignFirstResponder];
}

- (ContactInfoCellModel *) getInfoBySection:(NSInteger) section row:(NSInteger)row {
    ContactInfoCellModel * info = nil;
    
    BOOL isRegistered = NO;
    NSInteger personId = _infoModel.personId;
    if (personId >= 0) {
        // only for contacts
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        for (PhoneDataModel *phone in personData.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                isRegistered = YES;
            }
        }
    }
    
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON] && !isRegistered) {
        // if logged in;
        // the first section is the number array, the second array is the share array
        // the third section only exsits only if the number is in the contact list.
        switch (section) {
            case 0: {
                info = [_numberArray objectAtIndex:row];
                break;
            }
            case 1: {
                info = [_shareArray objectAtIndex:row];
                break;
            }
            case 2: {
                info = [_subArray objectAtIndex:row];
                break;
            }
            default:
                break;
        }
        
        return info;
    } else {
        // not logged in, do not contain the share array section
        switch (section) {
            case 0: {
                info = [_numberArray objectAtIndex:row];
                break;
            }
            case 1: {
                info = [_subArray objectAtIndex:row];
                break;
            }
            default:
                break;
        }
        return info;
    }
    return info;
}

@end

