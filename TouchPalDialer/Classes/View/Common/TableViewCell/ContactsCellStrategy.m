//
//  ContactsCellStrategy.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-11-7.
//
//

#import "ContactsCellStrategy.h"
#import "TouchPalDialerAppDelegate.h"
#import "CallLogDataModel.h"
#import "ContactCacheDataManager.h"
#import "AppSettingsModel.h"
#import "TPMFMessageActionController.h"
#import "NSString+PhoneNumber.h"
#import "TPDialerResourceManager.h"
#import "PhonePadModel.h"  
#import "UserDefaultKeys.h"
#import "NotificationScheduler.h"
#import "UserDefaultsManager.h"
#import "TPCallActionController.h"
#import "FunctionUtility.h"
#import "CallLog.h"
#import "RemoveCallsCommand.h"
#import "PersonDBA.h"
#import "DialerUsageRecord.h"
#import "UsageConst.h"
#import "NotificationAlertManger.h"

@interface PanContactsCellStrategy()<CooTekPopUpSheetDelegate>{
    id<BaseContactsDataSource> currentData_;
    
    __strong void(^willAppearPopupSheet_)();
    __strong void(^willDisappearPopupSheet_)();
}
-(id<BaseContactsDataSource>)contactDataCastFromData:(id)data;
-(void)sendSms:(id<BaseContactsDataSource>)data;
-(void)showAllNumbers:(id<BaseContactsDataSource>)data;
-(void)callNumber:(id<BaseContactsDataSource>)data;
-(void)clearAllLogs:(id<BaseContactsDataSource>)data;
-(void)doClearLogsAfterClick:(NSInteger)index;
-(void)showAlertWhenContactNoNumber:(id<BaseContactsDataSource>)data;
-(void)excuteAction:(CellListFunctionType)type withData:(id)data;
-(UIImage *)imageActionHg:(CellListFunctionType)type;
-(UIImage *)imageForMove:(MoveOrientationType)type isNormalImage:(BOOL)isNormal;
@end

@implementation PanContactsCellStrategy
-(void)showAlertWhenContactNoNumber:(id<BaseContactsDataSource>)data{
    if ([data.number length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"There is no phone number saved with this contact.", @"")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok",@"" )
                                              otherButtonTitles:nil];
        [alert show];
    }
}
-(id<BaseContactsDataSource>)contactDataCastFromData:(id)data{
    return (id<BaseContactsDataSource>) data;
}
-(UIImage *)imageActionNormal:(CellListFunctionType)type{
    UIImage *image = nil;
    switch (type) {
        case CellListFunctionTypeOnCall:
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_swipe_call_normal@2x.png"];
            break;
        case CellListFunctionTypeSendSms:
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_swipe_sms_normal@2x.png"];
            break;
        case CellListFunctionTypeShowAllnumbers:
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_swipe_showall_normal@2x.png"];
            break;
        case CellListFunctionTypeClearLogs:
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_swipe_clear_normal@2x.png"];
            break;
        default:
            break;
    }
    return image;
}
-(UIImage *)imageActionHg:(CellListFunctionType)type{
    UIImage *image = nil;
    switch (type) {
        case CellListFunctionTypeOnCall:
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_swipe_call_hg@2x.png"];
            break;
        case CellListFunctionTypeSendSms:
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_swipe_sms_hg@2x.png"];
            break;
        case CellListFunctionTypeShowAllnumbers:
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_swipe_showall_hg@2x.png"];
            break;
        case CellListFunctionTypeClearLogs:
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_swipe_clear_hg@2x.png"];
            break;
        default:
            break;
    }
    return image;
}
-(UIImage *)imageForMove:(MoveOrientationType)type isNormalImage:(BOOL)isNormal{
    CellListFunctionType typeAction= [AppSettingsModel appSettings].listClick;
    switch (type) {
        case MoveOrientationTypeRight:
            typeAction = [AppSettingsModel appSettings].listSwipeRight;
            break;
        case MoveOrientationTypeLeft:
            typeAction = [AppSettingsModel appSettings].listSwipeLeft;
            break;
        default:
            break;
    }
    if (isNormal) {
        return [self imageActionNormal:typeAction];
    }else{
        return [self imageActionHg:typeAction];
    }
}
-(void)excuteAction:(CellListFunctionType)type withData:(id)data{
    id<BaseContactsDataSource> currentData = [self contactDataCastFromData:data];
    switch (type) {
        case CellListFunctionTypeOnCall:
            [self callNumber:currentData];
            break;
        case CellListFunctionTypeSendSms:
            [self sendSms:currentData];
            break;
        case CellListFunctionTypeShowAllnumbers:
            [self showAllNumbers:currentData];
            break;
        case CellListFunctionTypeClearLogs:
            [self clearAllLogs:currentData];
            break;
        default:
            break;
    }
}

-(void)showAllNumbers:(id<BaseContactsDataSource>)data{
    currentData_ = data;
    NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:1];
    NSString *title;
    if (data.personID > 0) {
        NSArray *phones = [[[ContactCacheDataManager instance] contactCacheItem:data.personID] phones];
        for (PhoneDataModel *phone in phones) {
            [numbers addObject:phone.number];
        }
        if ([data.name length] > 0) {
            title = data.name;
        } else {
            title = data.number;
        }
    }else{
        [numbers addObject:data.number];
        title = data.number;
    }
    UINavigationController *myNav = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    
    CooTekPopUpSheet *numberChoosePopUp = [[CooTekPopUpSheet alloc] initWithTitle:title                                                                       content:numbers
                                                                             type:PopUpSheetTypeShowAllNumbers
                                                                           appear:willAppearPopupSheet_
                                                                        disappear:willDisappearPopupSheet_];
    numberChoosePopUp.delegate = self;
    [myNav.topViewController.view addSubview:numberChoosePopUp];
}
-(void)callNumber:(id<BaseContactsDataSource>)data{
    [self showAlertWhenContactNoNumber:data];
    CallLogDataModel *callog = [[CallLogDataModel alloc] initWithPersonId:data.personID phoneNumber:data.number loadExtraInfo:NO];
    [TPCallActionController logCallFromSource:@"CustomizeAction"];
    [[TPCallActionController controller] makeCall:callog appear:willAppearPopupSheet_ disappear:willDisappearPopupSheet_];
}
-(void)clearAllLogs:(id<BaseContactsDataSource>)data{
    currentData_ = data;
    NSArray *times= [RemoveCallsCommand getTheFirstANDLastCallTimeWithPersonID:data.personID orPhoneNumber:data.number];
    if(times!=nil){
        UINavigationController *myNav = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
        int firstCallTime = [[times objectAtIndex:0] integerValue];
        int lastCallTime = [[times objectAtIndex:1] integerValue];
        int callCount = [[times objectAtIndex:2] integerValue];
        NSString * firstCallTimeString = [FunctionUtility getSystemFormatDateString:firstCallTime];
        NSString * lastCallTimeString = [FunctionUtility getSystemFormatDateString:lastCallTime];
        NSMutableArray *contentArray = [[NSMutableArray alloc] initWithCapacity:4];
        [contentArray addObject:NSLocalizedString(@"Remove last call", @"")];
        [contentArray addObject:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"on", @""),lastCallTimeString]];
        [contentArray addObject:NSLocalizedString(@"Clear all calls", @"")];
        [contentArray addObject:[NSString stringWithFormat:@"%d %@ %@ %@",callCount,NSLocalizedString(@"calls", @""),NSLocalizedString(@"since", @""),firstCallTimeString]];
        CooTekPopUpSheet *popUpSheet = [[CooTekPopUpSheet alloc] initWithTitle:NSLocalizedString(@"Clear call logs", @"") content:contentArray type:PopUpSheetTypeDeleteLogs appear:willAppearPopupSheet_ disappear:willDisappearPopupSheet_];
        popUpSheet.delegate = self;
        [myNav.topViewController.view addSubview:popUpSheet];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"联系人没有通话记录", @"")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok",@"" )
                                              otherButtonTitles:nil];
        [alert show];
    }
}
-(void)setPopupSheetBlock:(void(^)())willAppearPopupSheet disappear:(void(^)())willDisappearPopupSheet{
    willAppearPopupSheet_ = [willAppearPopupSheet copy];
    willDisappearPopupSheet_ = [willDisappearPopupSheet copy];
}
-(void)sendSms:(id<BaseContactsDataSource>)data{
    [self showAlertWhenContactNoNumber:data];
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    if (data.personID != -1) {
        NSArray *numberArray = [PersonDBA getPhonesByRecordID:data.personID];
        LabelDataModel* data = [numberArray objectAtIndex:0];
        [TPMFMessageActionController sendMessageToNumber:(NSString *)data.labelValue
                                                          withMessage:@""
                                                          presentedBy:aViewController];
    }else{
        [TPMFMessageActionController sendMessageToNumber:data.number
                                                      withMessage:@""
                                                      presentedBy:aViewController];
    }
}
-(void)doClearLogsAfterClick:(NSInteger)index{
    NSMutableArray *condition_arr = [NSMutableArray arrayWithCapacity:3];
    int personId = currentData_.personID;
    NSString * phoneNumber = currentData_.number;
    if(personId > 0){
        WhereDataModel *condition_pid = [[WhereDataModel alloc] init];
        condition_pid.fieldKey = [DataBaseModel getKWhereKeyPersonID];
        condition_pid.oper = [DataBaseModel getKWhereOperationEqual];
        condition_pid.fieldValue = [NSString stringWithFormat:@"%d", personId];
        [condition_arr addObject:condition_pid];
    }else{
        WhereDataModel *condition_num = [[WhereDataModel alloc] init];
        condition_num.fieldKey = [DataBaseModel getKWhereKeyPhoneNumber];
        if ([[[PhoneNumber sharedInstance] getOriginalNumber:phoneNumber] length] >= 7) {
            condition_num.oper = [DataBaseModel getKWhereOperationLike];
            condition_num.fieldValue = [[PhoneNumber sharedInstance] getOriginalNumber:phoneNumber];
        } else {
            condition_num.oper = [DataBaseModel getKWhereOperationEqual];
            condition_num.fieldValue = [NSString stringWithFormat:@"%@", [phoneNumber digitNumber]];
        }
        [condition_arr addObject:condition_num];
    }
    
    if(index == 1){
        //clear all call logs
        [CallLog deleteCalllogByConditional:condition_arr];
    }else if(index == 0){
        //clear the last record
        // delete one call log item from data base.
        WhereDataModel *condition_date = [[WhereDataModel alloc] init];
        condition_date.fieldKey = [DataBaseModel getKWhereKeyCallTime];
        condition_date.oper = [DataBaseModel getKWhereOperationEqual];
        NSArray *times = [RemoveCallsCommand getTheFirstANDLastCallTimeWithPersonID:personId orPhoneNumber:phoneNumber];
        if(times != nil){
            condition_date.fieldValue = [NSString stringWithFormat:@"%d", [[times objectAtIndex:0] integerValue]];
            [condition_arr addObject:condition_date];
            [CallLog deleteCalllogByConditionalWithoutNotification:condition_arr];
            times =[RemoveCallsCommand getTheFirstANDLastCallTimeWithPersonID:personId orPhoneNumber:phoneNumber];
        }
        //if no call logs, delete from UI
        if(times==nil){
            [[PhonePadModel getSharedPhonePadModel] setInputNumber:@""];
        }
    }
}
#pragma CooTekPopUpSheetDelegate
- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info{
    switch (tag) {
        case PopUpSheetTypeDeleteLogs:{
            [self doClearLogsAfterClick:index];
            break;
        }
        case PopUpSheetTypeShowAllNumbers:{
            CallLogDataModel *callog = [[CallLogDataModel alloc] initWithPersonId:currentData_.personID phoneNumber:[info objectAtIndex:0]loadExtraInfo:NO];
            [TPCallActionController logCallFromSource:@"CustomizeAction"];
            [[TPCallActionController controller] makeCall:callog appear:willAppearPopupSheet_ disappear:willDisappearPopupSheet_];
            break;
        }
        default:
            break;
    }
}

- (void)doClickIconButton:(int)index withTag:(int)tag info:(NSArray *)info{
    NSString *number = [info objectAtIndex:0];
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    [TPMFMessageActionController sendMessageToNumber:number
                                                      withMessage:@""
                                                      presentedBy:aViewController];
}
-(void)createPanGestureFor:(id)target actionMethod:(SEL)method{
    UIPanGestureRecognizer *swipeRightGesture=[[UIPanGestureRecognizer alloc] initWithTarget:target action:method];
    swipeRightGesture.delegate = target;
    [target addGestureRecognizer:swipeRightGesture];
}

-(void)removePanGestureFor:(id)target
{
    for (UIPanGestureRecognizer *recognizer in [target gestureRecognizers]) {
        [target removeGestureRecognizer:recognizer];
    }
}

//user's action on cell  
-(void)onClick:(id)data{
    [self excuteAction:[AppSettingsModel appSettings].listClick withData:data];
}
-(void)onPanClick:(id)data type:(MoveOrientationType)type{
    switch (type) {
        case MoveOrientationTypeLeft:
            [DialerUsageRecord recordpath:PATH_DIAL_SETTING kvs:Pair(KEY_ACTION,@(0)), nil];
            [self excuteAction:[AppSettingsModel appSettings].listSwipeLeft withData:data];
            break;
        case MoveOrientationTypeRight:
            [DialerUsageRecord recordpath:PATH_DIAL_SETTING kvs:Pair(KEY_ACTION,@(1)), nil];
            [self excuteAction:[AppSettingsModel appSettings].listSwipeRight withData:data];
            break;
        default:
            break;
    }
}
@end