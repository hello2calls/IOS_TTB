//
//  SendSMSCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//
#import "GroupSendSMSCommand.h"
#import "CommandDataHelper.h"
#import "Person.h"
#import "CooTekPopUpSheet.h"
#import "TPMFMessageActionController.h"
#import "TouchPalDialerAppDelegate.h"
#import "ContactCacheDataManager.h"
#import "GroupedContactsModel.h"
#import "CootekNotifications.h"
#import "PersonDBA.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"

static GroupSendSMSCommand *sGroupSendSMSCommand;
@implementation GroupSendSMSCommand
{
    NSMutableArray *sendSMSList;
    NSString *_message;
    ShareResultCallback _resultBack;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _message = nil;
        _resultBack = nil;
    }
    return self;
}

- (BOOL)canExecute:(OperationSheetType)sheetType
{
    NSArray *excludeTypes = @[@(OperationSheetTypeAddContacts)];
    if ([excludeTypes indexOfObject:@(sheetType)] == NSNotFound) {
        // not found in the excluding list
        return YES;
    }
    return NO;
}

- (void)onExecute:(NSArray *)personList
{
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    [aViewController dismissViewControllerAnimated:NO completion:^{
    [TPMFMessageActionController sendMessageToNumbers:personList
                                                       withMessage:@""
                                                       presentedBy:aViewController
                                                              sent:nil
                                                         cancelled:nil
                                                            failed:nil
     ];
    }];

}

- (void)sendSmsTo:(NSArray *)all_checked_member_phones{
    
    UINavigationController *navController = [TouchPalDialerAppDelegate naviController];
    UIViewController *selectVC = navController.topViewController;
    
    UIViewController *aViewController = [TouchPalDialerAppDelegate naviController];
    
    if (![selectVC isKindOfClass:[SelectViewController class]]) {
        if ([FunctionUtility systemVersionFloat] < 8.0) {
            [TPMFMessageActionController sendMessageToNumbers:all_checked_member_phones withMessage:nil presentedBy:selectVC];
        }else{
        [TPMFMessageActionController sendMessageToNumbers:all_checked_member_phones withMessage:nil presentedBy:aViewController];
        }
    }else{
        [TPMFMessageActionController sendMessagePopSelectVC:selectVC
                                              ToNumbers:all_checked_member_phones withMessage:_message
                                              presentedBy:aViewController
                                              sent:^{
                                                  if (_resultBack) {
                                                      _resultBack(ShareSuccess, nil, nil);
                                                  }
                                              } cancelled:^{
                                                  if (_resultBack) {
                                                      _resultBack(ShareCancel, nil, @"取消了分享");
                                                  }
                                              } failed:^{
                                                  if (_resultBack) {
                                                  _resultBack(ShareFail, nil, @"取消了分享");
                                              }
        }];
    }
    
}

- (void)doClickOnCancelButtonWithTag:(int)tag
{
    //[self notifyCommandExecuted];
}

- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info
{
    if([info count]<2) {
        [self sendSmsTo:[NSArray arrayWithObjects:nil]];
    } else {
        [self sendSmsTo:[NSArray arrayWithObjects:[info objectAtIndex:0], nil]];
    }
    //[self notifyCommandExecuted];
}

- (NSString *)getCommandName
{
    return NSLocalizedString(@"Send SMS", @"群发短信");
}

- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray
{

    NSMutableArray *personList = [NSMutableArray arrayWithCapacity:3];
    if(pageNode==nil){
        [personList addObjectsFromArray:[Person queryAllContactsHavePhones]];
    } else {
        if (pageNode.nodeDescription == NSLocalizedString(@"Ungrouped", @"Ungrouped")) {
            GroupedContactsModel *groupedContactsModel = [GroupedContactsModel pseudoSingletonInstance];
            [personList addObjectsFromArray:[groupedContactsModel innerGetMembersUngrouped]];
        } else {
            personList = personArray;
        }
    }
    sGroupSendSMSCommand = self;
    SelectViewController *select_temp = [[SelectViewController alloc] init];
    select_temp.autoDismiss = NO;
	select_temp.delegate = sGroupSendSMSCommand;
    select_temp.dataList = personList;
    if (pageNode == nil) {
        select_temp.viewType = SelectViewGroupCommandAll;
    } else {
        select_temp.viewType = SelectViewGroupCommandGroup;
    }
    select_temp.commandName = [self getCommandName];
    UINavigationController *navController =
    ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
    [navController pushViewController:select_temp animated:YES];
    self.targetData = pageNode;
}


- (void)onClickedWithMessage:(NSString *)message resultCallback:(ShareResultCallback)resultBack
{
    _message = message;
    _resultBack = resultBack;
    NSMutableArray *personList = [NSMutableArray arrayWithCapacity:3];
    
    [personList addObjectsFromArray:[PersonDBA queryAllContactsNotRegisterHaveHavePhones]];
    
    if (personList.count==0) {
        [self sendSmsTo:nil];
        return;
    }
    
    sGroupSendSMSCommand = self;
    SelectViewController *select_temp = [[SelectViewController alloc] init];
    select_temp.autoDismiss = NO;
    select_temp.delegate = sGroupSendSMSCommand;
    select_temp.dataList = personList;
    select_temp.viewType = SelectViewGroupCommandAll;
    select_temp.commandName = [self getCommandName];
    UINavigationController *navController = [TouchPalDialerAppDelegate naviController];

    [navController pushViewController:select_temp animated:YES];
    //[operationView release];
}

- (void)checkFinish:(NSArray *)dataList
{
    for (MultiSelectSectionData *sectionData in dataList) {
        for (MultiSelectItemData *itemData in sectionData.items){
            if (itemData.is_checked){
                [sendSMSList addObject:itemData.text];
            }
        }
    }
    if (sendSMSList.count > 0) {
        [self sendSmsTo:sendSMSList];
    }
}

- (void)selectViewFinish:(NSArray *)select_list
{
    if (!_message) {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_PREPARE_TO_SEND_SMS object:nil];
    }
    if (select_list.count > 0) {
        sendSMSList = [[NSMutableArray alloc]initWithCapacity:3];
        NSMutableArray* multiSelectDataList = [NSMutableArray arrayWithCapacity:3];
        int checkedMembersCount = select_list.count;
        int i = 0;
        for (; i<checkedMembersCount; i++) {
            int personId = [select_list[i] intValue];
            NSInteger mainIndex = 0;
            NSArray* phones = [Person getPhonesByRecordID:personId mainIndex:&mainIndex];
            int phonesCount = [phones count];
            if (phonesCount > 1) {
                NSMutableArray* multiSelectItems = [[NSMutableArray alloc] init];
                int j = 0;
                for (; j<phonesCount; j++) {
                    LabelDataModel* data = [phones objectAtIndex:j];
                    BOOL isChecked = NO;
                    if (mainIndex == j) {
                        isChecked = YES;
                    }
                    MultiSelectItemData* itemDataPhone = [[MultiSelectItemData alloc] initWithData:j
                                                                                          withText:data.labelValue
                                                                                         isChecked:isChecked];
                    [multiSelectItems addObject:itemDataPhone];
                }
                MultiSelectSectionData *multiSelectSectionData =
                [[MultiSelectSectionData alloc] initWithData:personId
                                                    withText:[[ContactCacheDataManager instance] contactCacheItem:personId].    fullName
                                                   withItems:multiSelectItems];
                [multiSelectDataList addObject:multiSelectSectionData];
            } else if (phonesCount == 1) {
                LabelDataModel* phoneData = [phones objectAtIndex:0];
                [sendSMSList addObject:phoneData.labelValue];
            }
        } // end for
    
    // deal with
        if ([multiSelectDataList count] > 0) { // some person have more than 1 phones, let user check them
            CommonMultiSelectTableViewController* multiSelectVC = [[CommonMultiSelectTableViewController alloc]
                                                                   initWithStyle:UITableViewStylePlain
                                                                   data:multiSelectDataList
                                                                   delegate:self title:NSLocalizedString(@"Choose the number", @"") needAnimateOut:NO];
            UINavigationController *m_navigationController = [TouchPalDialerAppDelegate naviController];
            [m_navigationController presentViewController:multiSelectVC animated:YES completion:^(){}];
        //self.multi_select_view_controller = multiSelectVC;
        } else { // no person have more than 1 phones, send sms directly
            if (sendSMSList.count > 0) {
                [self sendSmsTo:sendSMSList];
            }
        }
    }
}

- (void)selectViewCancel
{
    if (!sGroupSendSMSCommand) {
        sGroupSendSMSCommand = nil;
    }
}


@end
