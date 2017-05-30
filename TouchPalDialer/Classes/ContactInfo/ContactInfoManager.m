//
//  ContactInfoFactory.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/16.
//
//

#import "ContactInfoManager.h"
#import "ContactInfoViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "ContactInfoModel.h"
#import "ContactInfoModelUtil.h"
#import "ContactInfoButtonModel.h"
#import "ContactInfoUtil.h"
#import "ContactInfoCellModel.h"
#import "ContactHistoryViewController.h"
#import "CootekNotifications.h"
#import "FunctionUtility.h"
#import "Person.h"
#import "DialerUsageRecord.h"
#import "InviteLoginController.h"

@interface ContactInfoManager()<ContactInfoViewControllerDelegate,ContactHistoryViewControllerDelegate>{
    __weak ContactInfoViewController *_con;
    __weak ContactHistoryViewController *_hisCon;
    
    NSInteger _personId;
    NSString *_phoneNumber;
    InfoType _infoType;
    
    NSInteger _conTime;
    NSInteger _conHisTime;
}

@end

static ContactInfoManager *instance = nil;

@implementation ContactInfoManager

+ (void)initialize{
    instance = [[ContactInfoManager alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:instance
                                             selector:@selector(refreshHistoryController)
                                                 name:N_CALL_LOG_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:instance
                                             selector:@selector(refreshByPersonDataChanged:)
                                                 name:N_PERSON_DATA_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:instance
                                             selector:@selector(refreshGroupChanged:)
                                                 name:N_PERSON_GROUP_CHANGE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:instance
                                             selector:@selector(refreshForShareSucceed)
                                                 name:N_INVITING_IN_CONATCT_DETAIL_SUCCEED
                                               object:nil];
}

+ (instancetype)instance{
    return instance;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showContactInfoByPersonId:(NSInteger)personId{
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    _conTime += 1;
    _personId = personId;
    _infoType = knownInfo;
    _phoneNumber = nil;
    ContactInfoViewController *con = [[ContactInfoViewController alloc]init];
    ContactInfoModel *info = [ContactInfoModelUtil getContactInfoModelByPersonId:personId];
    con.delegate = self;
    con.infoModel = info;
    con.numberArray = [ContactInfoModelUtil getPhoneNumberArrayByPersonId:personId];
    con.subArray = [ContactInfoModelUtil getSubArrayByPersonId:personId];
    con.shareArray = [ContactInfoModelUtil getShareArrayByPersonId:personId];
    if ( _con == nil ){
        [[TouchPalDialerAppDelegate naviController] pushViewController:con animated:YES];
        _con = con;
    }else{
        [[TouchPalDialerAppDelegate naviController] pushViewController:con animated:YES];
        [FunctionUtility removeFromStackViewController:_con];
        _con = con;
    }
    
}

- (void)showContactInfoByPhoneNumber:(NSString *)phoneNumber{
    _conTime += 1;
    _phoneNumber = phoneNumber;
    _infoType = unknownInfo;
    _personId = -1;
    ContactInfoViewController *con = [[ContactInfoViewController alloc]init];
    ContactInfoModel *info = [ContactInfoModelUtil getContactInfoModelByPhoneNumber:phoneNumber];
    con.delegate = self;
    con.infoModel = info;
    [DialerUsageRecord recordpath:PATH_UNKONW_PERSON kvs:Pair(PERSON_DETAIL, @(0)), nil];
    con.numberArray = [ContactInfoModelUtil getPhoneNumberArrayByPhoneNumber:phoneNumber];
    con.subArray = [NSArray array];
    con.shareArray = [ContactInfoModelUtil getShareArrayByPhoneNumber:phoneNumber];
    if ( _con == nil ){
        [[TouchPalDialerAppDelegate naviController] pushViewController:con animated:YES];
        _con = con;
    }else{
        [[TouchPalDialerAppDelegate naviController] pushViewController:con animated:YES];
        [FunctionUtility removeFromStackViewController:_con];
        _con = con;
    }
}

- (void)showCallHistoryByPersonId:(NSInteger)personId{
    _conHisTime += 1;
    ContactHistoryViewController *hisCon = [[ContactHistoryViewController alloc]init];
    ContactInfoModel *info = [ContactInfoModelUtil getContactInfoModelByPersonId:personId];
    hisCon.delegate = self;
    hisCon.infoModel = info;
    hisCon.callList = [ContactInfoModelUtil getCallListByPersonId:personId];
    if ( _hisCon == nil ){
        [[TouchPalDialerAppDelegate naviController] pushViewController:hisCon animated:YES];
        _hisCon = hisCon;
    }else{
        [[TouchPalDialerAppDelegate naviController] pushViewController:hisCon animated:YES];
        [FunctionUtility removeFromStackViewController:_hisCon];
        _hisCon = hisCon;
    }
}

- (void)showCallHistoryByPhoneNumber:(NSString *)phoneNumber{
    _conHisTime += 1;
    ContactHistoryViewController *hisCon = [[ContactHistoryViewController alloc]init];
    ContactInfoModel *info = [ContactInfoModelUtil getContactInfoModelByPhoneNumber:phoneNumber];
    hisCon.delegate = self;
    hisCon.infoModel = info;
    hisCon.callList = [ContactInfoModelUtil getCallListByPhoneNumber:phoneNumber];
    if ( _hisCon == nil ){
        [[TouchPalDialerAppDelegate naviController] pushViewController:hisCon animated:YES];
        _hisCon = hisCon;
    }else{
        [[TouchPalDialerAppDelegate naviController] pushViewController:hisCon animated:YES];
        [FunctionUtility removeFromStackViewController:_hisCon];
        _hisCon = hisCon;
    }
}

- (NSInteger)getPersonId{
    return _personId;
}



#pragma mark ContactInfoViewControllerDelegate

- (void)popViewController{
    [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
    [self deallocTheController];
}

- (void)onRightButtonAction{
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    if (_infoType == knownInfo)
        [ContactInfoUtil chooseEditDeleteActionByPersonId:_personId];
    else if ( _infoType == unknownInfo )
        [ContactInfoUtil chooseAddActionByNumber:_phoneNumber];
}

- (void)onIconButtonAction{
    [ContactInfoUtil chooseContactPhotoByPersonId:_personId];
}

- (void)onButtonPressed:(NSInteger)tag{
    switch (tag) {
        case knownCalllog:
            [self showCallHistoryByPersonId:_personId];
            break;
        case knownGesture:
            [ContactInfoUtil editGestureAction:_personId];
            break;
        case knownShare:
            [ContactInfoUtil shareByPersonId:_personId];
            break;
        case knownStore:
            [ContactInfoUtil favPersonByPeronId:_personId];
            [_con refreshButtonView];
            break;
        case unknownCallog:
            [self showCallHistoryByPhoneNumber:_phoneNumber];
            break;
        case unknownCopy:
            [ContactInfoUtil copyByPhoneNumber:_phoneNumber];
            [DialerUsageRecord recordpath:PATH_UNKONW_PERSON kvs:Pair(PERSON_DETAIL, @(1)), nil];
            break;
        case unknownShare:
            [ContactInfoUtil shareByPhoneNumber:_phoneNumber];
            break;
        default:
            break;
    }
}

- (void)deallocTheController{
    _conTime -= 1;
    if ( _conTime > 0 )
        return;
    _con = nil;
    _personId = -1;
    _phoneNumber = nil;
    _infoType = noInfo;
    _conTime = 0;
}

- (void)onSelectCell:(ContactInfoCellModel *)model{
    CellType cellType = model.cellType;
    switch (cellType) {
        case CellPhone:{
            if (_infoType == knownInfo) {
                [ContactInfoUtil makePhoneCallByPersonId:_personId andModel:model];
            }else if (_infoType == unknownInfo){
                [ContactInfoUtil makePhoneCallByPhoneNumber:_phoneNumber];
            }
            break;
        }
        case CellFaceTime:
            [ContactInfoUtil showFacetimeByPersonId:_personId];
            break;
        case CellInviting: {
            InviteLoginController *loginController = [InviteLoginController withOrigin:@"personal_center_redbag"];
            loginController.shareFrom = @"contact_detail";
            [LoginController checkLoginWithDelegate:loginController];
            
            // 数据记录，标识邀请来源
            // 5 - 来自个人详情页（达到网页邀请页）
            [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(5)), nil];
            break;
        }
        case CellEmail:{
            [ContactInfoUtil sendEmailByModel:model];
            break;
        }
        case CellData:
            break;
        case CellGroup:{
            [ContactInfoUtil selectGroupByPersonId:_personId];
            break;
        }
        case CellNote:{
            [ContactInfoUtil editNoteByPersonId:_personId];
            break;
        }
        case CellUrl:{
            [ContactInfoUtil openUrl:model];
            break;
        }
        case CellAddress:{
            [ContactInfoUtil openUrl:model];
            break;
        }
        case CellSNS:{
            [ContactInfoUtil openUrl:model];
            break;
        }
        case CellIM:
            break;
        default:
            break;
    }
}

- (void)onCellRightButtonPressed:(ContactInfoCellModel *)model{
    if ( model.cellType == CellPhone ) {
        [ContactInfoUtil shareMessageByModel:model];
    }
}

#pragma mark ContactHistoryViewControllerDelegate

- (void) headerLeftButtonAction:(ContactHeaderMode)model{
    if ( _hisCon == nil )
        return;
    if ( model == ContactHeaderNormal || model == ContactHeaderNo){
        [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
        [self deallocHistoryViewController];
    }else if ( model == ContactHeaderDelete ){
        if (_infoType == knownInfo) {
            [ContactInfoUtil clearCallLogByPersonId:_personId];
        }else if ( _infoType == unknownInfo ){
            [ContactInfoUtil clearCallLogByPhoneNumber:_phoneNumber];
        }
    }
}

- (void) headerRightButtonAction:(ContactHeaderMode)model{
    if ( _hisCon == nil )
        return;
    if ( model == ContactHeaderNormal ){
        [_hisCon refreshHeaderMode:ContactHeaderDelete];
        [_hisCon showEditingMode];
    }else if ( model == ContactHeaderDelete ) {
        [_hisCon refreshHeaderMode:ContactHeaderNormal];
        [_hisCon exitEditingMode];
    }
}

- (void) onSelectHistoryCell:(CallLogDataModel *)model{
    if ( _hisCon == nil )
        return;
    [ContactInfoUtil makeCall:model];
}

- (void) deallocHistoryViewController{
    _conHisTime -= 1;
    if ( _conHisTime > 0 )
        return;
    _hisCon = nil;
    _conHisTime = 0;
}

- (void) deleteCallLog:(CallLogDataModel *)model{
    [ContactInfoUtil deleteCallLog:model];
}

#pragma mark notification

- (void) refreshContactController{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(refreshContactController) withObject:nil waitUntilDone:YES];
        return;
    }
    if ( _con != nil ){
        if ( _infoType == knownInfo ){
            ContactInfoModel *info = [ContactInfoModelUtil getContactInfoModelByPersonId:_personId];
            _con.infoModel = info;
            _con.numberArray = [ContactInfoModelUtil getPhoneNumberArrayByPersonId:_personId];
            _con.subArray = [ContactInfoModelUtil getSubArrayByPersonId:_personId];
            _con.shareArray = [ContactInfoModelUtil getShareArrayByPersonId:_personId];
            
        }else if ( _infoType == unknownInfo ){
            ContactInfoModel *info = [ContactInfoModelUtil getContactInfoModelByPhoneNumber:_phoneNumber];
            _con.infoModel = info;
            _con.numberArray = [ContactInfoModelUtil getPhoneNumberArrayByPhoneNumber:_phoneNumber];
            _con.subArray = [NSArray array];
            _con.shareArray = [ContactInfoModelUtil getShareArrayByPhoneNumber:_phoneNumber];
        }
        [_con refreshView];
    }
    
}

- (void) refreshHistoryController{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(refreshHistoryController) withObject:nil waitUntilDone:YES];
        return;
    }
    if ( _hisCon != nil ){
        if ( _infoType == knownInfo ){
            ContactInfoModel *info = [ContactInfoModelUtil getContactInfoModelByPersonId:_personId];
            _hisCon.infoModel = info;
            _hisCon.callList = [ContactInfoModelUtil getCallListByPersonId:_personId];
        }else if ( _infoType == unknownInfo ){
            ContactInfoModel *info = [ContactInfoModelUtil getContactInfoModelByPhoneNumber:_phoneNumber];
            _hisCon.infoModel = info;
            _hisCon.callList = [ContactInfoModelUtil getCallListByPhoneNumber:_phoneNumber];
        }
        [_hisCon refreshView];
    }
}

- (void)refreshByPersonDataChanged:(id)personChange{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(refreshByPersonDataChanged:) withObject:personChange waitUntilDone:YES];
        return;
    }
    NotiPersonChangeData* changedData = [[personChange userInfo] objectForKey:KEY_PERSON_CHANGED];
    if(changedData.change_type == ContactChangeTypeDelete){
        [self popToRootView];
        return;
    }
    
    BOOL isCurrentModified = ((_personId == changedData.person_id) || _personId < 0)
    && (changedData.change_type == ContactChangeTypeModify);
    
    BOOL isAdded = (changedData.change_type == ContactChangeTypeAdd) && _personId < 0;
    
    if ( _infoType == knownInfo ){
        if (isCurrentModified || isAdded)
            [self refreshContactController];
    }else if ( _infoType == unknownInfo ){
        if (isCurrentModified || isAdded)
            [self showContactInfoByPersonId:changedData.person_id];
    }
    

}

- (void)popToRootView{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(popToRootView) withObject:nil waitUntilDone:YES];
        return;
    }
    if ( _hisCon != nil && _con != nil){
        [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
        [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:NO];
    }else if ( _hisCon == nil && _con != nil ){
        [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
    }
}

- (void)refreshGroupChanged:(id)notification {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(refreshGroupChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    if ( _con != nil ){
        NotiPersonGroupChangeData *data = [[notification userInfo] objectForKey:KEY_GROUP_PERSON_ID];
        if (data.personID == _personId) {
            _con.subArray = [ContactInfoModelUtil getSubArrayByPersonId:_personId];
            [_con refreshTableView];
        }
    }
}

- (void)refreshForShareSucceed {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(refreshForShareSucceed:) withObject:nil waitUntilDone:YES];
        return;
    }
    if ( _con != nil ){
        [_con refreshTableView];
    }
}

@end
