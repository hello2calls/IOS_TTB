//
//  ContactInfoUtil.m
//  TouchPalDialer
//
//  Created by game3108 on 15/7/20.
//
//

#import "ContactInfoUtil.h"
#import "TPDialerResourceManager.h"
#import "ContactCacheDataManager.h"
#import "ImageUtility.h"
#import "GestureModel.h"
#import "DefaultUIAlertViewHandler.h"
#import "GestureActionPickerViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "CootekNotifications.h"
#import "TPShareController.h"
#import "NSMutableString+TPHandleEmpty.h"
#import "Person.h"
#import "Favorites.h"
#import "TPCallActionController.h"
#import "TPFacetimeActionController.h"
#import "TPMFMailActionController.h"
#import "TPGroupSelectActionController.h"
#import "ContactEditNoteView.h"
#import "TPMFMessageActionController.h"
#import "TPABPersonActionController.h"
#import "TPClearCallLogActionController.h"
#import "SmartDailerSettingModel.h"
#import "CallerIDModel.h"
#import "CallLog.h"
#import "TPContactPhotoActionController.h"
#import "UIView+Toast.h"
#import "DeviceSim.h"
#import "DefaultUIAlertViewHandler.h"
#import "FunctionUtility.h"
#import "HandlerWebViewController.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"
@implementation ContactInfoUtil

+ (UIImage *)getBgImageByPersonId:(NSInteger)personId{
    ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:personId];
    if ( person ){
        UIImage *personImage = [person image];
        if ( personImage != nil )
            return [ImageUtility blurryImage:personImage withBlurLevel:0.7];
    }
    return nil;
}


+ (UIImage *)getPhotoImageByPersonId:(NSInteger)personId{
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    UIImage *photo = [[TPDialerResourceManager sharedManager] getImageByName:isVersionSix ? @"common_photo_contact_detail@3x.png":@"common_photo_contact_big@2x.png"];

    if ( personId < 0 )
        return photo;
    
    ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:personId];
    if ( person ){
        UIImage *personImage = [person image];
        if ( personImage != nil )
            return personImage;
    }
    return photo;
}

+ (UIImage *)getPhotoImageByPhoneNumber:(NSString *)phoneNumber{
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    UIImage *photo = [[TPDialerResourceManager sharedManager] getImageByName: isVersionSix ?@"common_photo_contact_detail@3x.png":@"common_photo_contact_big@2x.png"];

    return photo;
}

+ (NSString *)getDateStr:(NSInteger)callTime{
    NSString *callStr = [self getDateTimeFormat:callTime];
    NSDateFormatter *dateFormat = [ [NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSDate *callDate = [dateFormat dateFromString:callStr];
    
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970];
    NSInteger callDateTime = [callDate timeIntervalSince1970];
    
    if ( nowTime - callDateTime < 24*60*60 ){
        return NSLocalizedString(@"Today", "");
    }
    
    if ( nowTime - callDateTime < 24*60*60*2 ){
        return NSLocalizedString(@"Yesterday", "");
    }
    
    return callStr;
}

+ (NSString *)getDateTimeFormat:(NSInteger)callTime{
    NSDate *callDate = [NSDate dateWithTimeIntervalSince1970:callTime];
    NSDateFormatter *dateFormat = [ [NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    return [dateFormat stringFromDate:callDate];
}

+ (NSString *)getTimeStr:(NSInteger)callTime{
    NSString *callStr = [self getTimeFormat:callTime];
    NSInteger hour = [[callStr substringToIndex:2] integerValue];
    
    if ( hour >= 12 ){
        return [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"contact_info_afternoon", ""),callStr];
    }
    return [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"contact_info_morning", ""),callStr];
    
}

+ (NSString *)getTimeFormat:(NSInteger)callTime{
    NSDate *callDate = [NSDate dateWithTimeIntervalSince1970:callTime];
    NSDateFormatter *dateFormat = [ [NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    return [dateFormat stringFromDate:callDate];
}

+ (void) chooseContactPhotoByPersonId:(NSInteger)personId{
    [[TPContactPhotoActionController controller] doContactPhotoActionByPersonId:personId
                                                                    presentedBy:[TouchPalDialerAppDelegate naviController]];
}

+ (void) chooseEditDeleteActionByPersonId:(NSInteger)personId{
    //edit/delete contact
    [[TPABPersonActionController controller] chooseEditDeleteActionById:personId
                                                            presentedBy:[TouchPalDialerAppDelegate naviController]];
}

+ (void) chooseAddActionByNumber:(NSString *)number{
    //add contact
    //luchenAdded
    [[TPABPersonActionController controller] chooseAddActionWithNewNumber:number
                                                              presentedBy:[TouchPalDialerAppDelegate naviController]];
}



+ (void) editGestureAction:(NSInteger)personId{
    if ( personId < 0 ){
        cootek_log(@"person id is smaller than 0 ");
        return;
    }
    if (![GestureModel getShareInstance].isOpenSwitchGesture) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Turn on gesture dialing?" , @"")
                                                  message:nil
                                      okButtonActionBlock:^(){
                                          [GestureModel getShareInstance].isOpenSwitchGesture = YES;
                                          [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_SETTING_OPEN object:nil];
                                          [self editGesture:personId];
                                      }];
    } else {
        [self editGesture:personId];
    }
 }

+ (void) editGesture:(NSInteger)personId {
    GestureActionPickerViewController *actionPicker = [[GestureActionPickerViewController alloc] initWithPersonID:personId];
    [[TouchPalDialerAppDelegate naviController] pushViewController:actionPicker animated:YES];
}

+ (void) shareByPersonId:(NSInteger)personId{
    if ( personId < 0 ){
        cootek_log(@"person id is smaller than 0 ");
        return;
    }
    NSString *title = [self shareNameByPersonID:personId];
    NSString *message = [self shareNumberEmailsByPersonID:personId];
    [[TPShareController controller] showShareActionSheet:title
                                                 message:message
                                          naviController:[TouchPalDialerAppDelegate naviController]];
    [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(3)), nil];
}

+ (NSString *)shareNameByPersonID:(NSInteger)personID
{
    ContactCacheDataModel *person = [[ContactCacheDataManager instance] contactCacheItem:personID];
    if (person == nil) {
        return @"";
    }
    return [person fullName];
}

+ (NSString *)shareNumberEmailsByPersonID:(NSInteger)personID
{
    
    NSMutableString *shareString = [NSMutableString stringWithCapacity:40];
    //phones
    NSArray *abAddressBookPhones = [Person getPhonesByRecordID:personID];
    for (LabelDataModel *item in abAddressBookPhones) {
        [shareString appendWithReturnIfNonEmptyString:(NSString*)item.labelValue];
    }
    //emails
    NSArray *emails = [Person getEmailsByRecordID:personID];
    //emails in AddressBook
    for (LabelDataModel *item in emails) {
        [shareString appendWithReturnIfNonEmptyString:(NSString *)item.labelValue];
    }
    return shareString;
}

+ (void) favPersonByPeronId:(NSInteger)personId{
    if ( personId < 0 ){
        cootek_log(@"person id is smaller than 0 ");
        return;
    }
    BOOL isFavorite = [Favorites isExistFavorite:personId];
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    if (isFavorite) {
        [Favorites removeFavoriteByRecordId:personId];
        [uiWindow makeToast:NSLocalizedString(@"Removed from favorites", @"") duration:1.0f position:CSToastPositionBottom];
    } else {
        [Favorites addFavoriteByRecordId:personId];
        [uiWindow makeToast:NSLocalizedString(@"Added to favorites", @"") duration:1.0f position:CSToastPositionBottom];
    }
}

+ (void) copyByPhoneNumber:(NSString *)phoneNumber{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
    pasteboard.persistent = YES;
    pasteboard.string = phoneNumber;
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow makeToast:NSLocalizedString(@"contact_info_copy_success", "") duration:1.0f position:CSToastPositionBottom];
}
+ (void) shareByPhoneNumber:(NSString *)phoneNumber{
    NSString *message = phoneNumber;
    CallerIDInfoModel *model = [CallerIDModel queryCallerIDByNumber:phoneNumber];
    if(model.isCallerIdUseful){
        NSString *title = @"";
        title = [model.name length] > 0 ? model.name : [model localizedTag];
        NSString *tag = [model.name length] > 0 ? [model localizedTag] : @"" ;
        if ([tag length] > 0) {
            message = [NSString stringWithFormat:@"%@\n%@",tag,message];
        }
        [[TPShareController controller] showShareActionSheet:title
                                                     message:message
                                              naviController:[TouchPalDialerAppDelegate naviController]];
    }else{
        [TPMFMessageActionController sendMessageToNumber:nil
                                             withMessage:message
                                             presentedBy:[TouchPalDialerAppDelegate naviController]];
    }
    [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(3)), nil];
}

+ (void) shareMessageByModel:(ContactInfoCellModel *)model{
    [TPMFMessageActionController sendMessageToNumber:model.mainStr
                                         withMessage:@""
                                         presentedBy:[TouchPalDialerAppDelegate naviController]];
}


+ (void) makePhoneCallByPersonId:(NSInteger)personId andModel:(ContactInfoCellModel *)model{
    CallLogDataModel *call_log_model = [[CallLogDataModel alloc] initWithPersonId:personId
                                                                      phoneNumber:model.mainStr
                                                                    loadExtraInfo:YES];
    [TPCallActionController logCallFromSource:@"KnowContactInfo"];
    [[TPCallActionController controller] makeCall:call_log_model];
}

+ (void) makePhoneCallByPhoneNumber:(NSString *)phoneNumber{
    CallLogDataModel *call_model = [[CallLogDataModel alloc] init];
    call_model.number = phoneNumber;
    [TPCallActionController logCallFromSource:@"UnknownContact"];
    [[TPCallActionController controller] makeCall:call_model];
    
}

+ (void) showFacetimeByPersonId:(NSInteger)personId{
    [[TPFacetimeActionController controller] chooseFacetimeActionByPersonId:personId
                                                                presentedBy:[TouchPalDialerAppDelegate naviController]];
}

+ (void) sendEmailByModel:(ContactInfoCellModel *)model{
    [[TPMFMailActionController controller] sendEmailToAddress:model.mainStr
                                                  withSubject:@"" withMessage:@""
                                                  presentedBy:[TouchPalDialerAppDelegate naviController]
                                                         sent:nil
                                                    cancelled:nil
                                                        saved:nil
                                                       failed:nil];
}

+ (void) selectGroupByPersonId:(NSInteger)personId{
    [[TPGroupSelectActionController controller] selectGroupByPersonId:personId
                                                             pushedBy:[TouchPalDialerAppDelegate naviController]];
}

+ (void) editNoteByPersonId:(NSInteger)personId{
    ContactEditNoteView *edit = [[ContactEditNoteView alloc] initWithPersonId:personId
                                                                         note:[self getNoteByPersonId:personId]];
    [[TouchPalDialerAppDelegate naviController].topViewController.view.superview addSubview:edit];
}

+ (NSString *) getNoteByPersonId:(NSInteger)personId{
    if (personId <= 0)
        return nil;
    ContactCacheDataModel *model = [Person getConatctInfoByRecordID:personId];
    return [model note];
}

+ (void) openUrl:(ContactInfoCellModel *)model{
    if ( model.url != nil )
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.url]];
}

+ (void) smsInviteByPersonId:(NSInteger)personId{
    // at present, send the main phone number to the sms sender, only one number.
    NSMutableArray *numbers = [Person getConatctInfoByRecordID:personId].phones;
    NSString __block *mainNumber = nil;
    NSString __block *firstNumber = nil;
    
    [numbers enumerateObjectsUsingBlock:^(PhoneDataModel *phone, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( !idx )
            firstNumber = phone.digitNumber;
        if ([phone.digitNumber length] >= 11) {
            mainNumber = phone.digitNumber;
            *stop = YES;
        }
    }];

    if ( !mainNumber )
        mainNumber = firstNumber;
    [FunctionUtility shareSMS:[FunctionUtility generateWechatMessage:@"sms020" andFrom:@"sms"] andNeedDefault:true andMessage:@"我一直都用“触宝电话”免费打给你，现在注册还能获得700分钟的免费通话时长，快来体验吧！" andNumber:mainNumber andFromWhere:@"contact_info_sms"];
}


+ (void) smsInviteByPhone:(NSString *)phone{
    // at present, send the main phone number to the sms sender, only one number.


    [FunctionUtility shareSMS:[FunctionUtility generateWechatMessage:@"sms020" andFrom:@"sms"] andNeedDefault:true andMessage:@"我一直都用“触宝电话”免费打给你，现在注册还能获得700分钟的免费通话时长，快来体验吧！" andNumber:phone andFromWhere:@"contact_info_sms"];
}

+ (void) deleteCallLog:(CallLogDataModel *)model{
    [CallLog deleteCalllogByRowId:model.rowID];
}

+ (void) clearCallLogByPersonId:(NSInteger)personId{
    [[TPClearCallLogActionController controller] clearCallLogOfKnownContactByPersonId:personId];
}

+ (void) clearCallLogByPhoneNumber:(NSString *)number{
    [[TPClearCallLogActionController controller] clearCallLogOfUnknownContactByPhoneNumber:number];
}

+ (void) makeCall:(CallLogDataModel *)model{
    [TPCallActionController logCallFromSource:@"CallHistory"];
    [[TPCallActionController controller] makeCall:model];
}

@end
