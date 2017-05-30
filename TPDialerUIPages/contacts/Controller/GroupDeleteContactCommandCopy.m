//
//  GroupDeleteContactCommandCopy.m
//  TouchPalDialer
//
//  Created by H L on 2016/10/27.
//
//

#import "GroupDeleteContactCommandCopy.h"
#import "CommandDataHelper.h"
#import "DefaultUIAlertViewHandler.h"
#import "Person.h"
#import "TouchPalDialerAppDelegate.h"
#import "OrlandoEngine.h"
#import "CootekNotifications.h"
#import "GroupedContactsModel.h"
#import "TPSelectCopyViewController.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "TPAddressBookWrapper.h"
static GroupDeleteContactCommandCopy *sGroupDeleteContactCommand;

typedef void (^FinishBlock)(NSArray *);
typedef void (^CancelBlock)(void);


@interface GroupDeleteContactCommandCopy ()
@property (nonatomic, strong) UINavigationController *navigation;
@property (nonatomic, assign) BOOL isNeedDelete;
@property (nonatomic, copy  ) FinishBlock finishBlock;
@property (nonatomic, copy  ) CancelBlock cancelBlock;

@end
@implementation GroupDeleteContactCommandCopy

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
    //[self holdUntilNotified];
    //[engineInstance deleteContactByPersonID:personID];
    //__block GroupDeleteContactCommand *cmd = self;
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Confirm to delete?",@"")
                                              message:nil
                                  okButtonActionBlock:^{
                                      for (ContactCacheDataModel *person in personList) {
                                          [Person deletePersonByRecordID:person.personID];
                                      }
                                      //[cmd notifyCommandExecuted];
                                  }
                                    cancelActionBlock:^{
                                        //[cmd notifyCommandExecuted];
                                    }
     ];
}
- (NSString *)getCommandName
{
    return NSLocalizedString(@"Delete contacts", @"删除联系人");
}

- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray
{
    NSMutableArray *personList = [NSMutableArray arrayWithCapacity:3];
    if(pageNode==nil){
        [personList addObjectsFromArray:[Person queryAllContacts]];
    } else {
        if (pageNode.nodeDescription == NSLocalizedString(@"Ungrouped", @"Ungrouped")) {
            GroupedContactsModel *groupedContactsModel = [GroupedContactsModel pseudoSingletonInstance];
            [personList addObjectsFromArray:[groupedContactsModel innerGetMembersUngrouped]];
        } else {
            for (NSNumber *personID in pageNode.contactIds) {
                ContactCacheDataModel *tmpPerson = [[ContactCacheDataManager instance] contactCacheItem:[personID intValue]];
                if (tmpPerson) {
                    [personList addObject:tmpPerson];
                }
            }
        }
    }
    sGroupDeleteContactCommand = self;
    TPSelectCopyViewController *select_temp = [[TPSelectCopyViewController alloc] init];
    select_temp.autoDismiss = NO;
    select_temp.delegate = sGroupDeleteContactCommand;
    select_temp.dataList = personList;
    if (pageNode == nil) {
        select_temp.viewType = SelectViewGroupCommandAll;
    } else {
        select_temp.viewType = SelectViewGroupCommandGroup;
    }
    select_temp.commandName = [self getCommandName];
    if (pageNode == nil) {
        // 批量删除联系热和发短信 合二为一
        select_temp.commandName = NSLocalizedString(@"batch_delete_contacts_and_send_sms", @"联系人");
    }
    UINavigationController *navController =
    ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
    [navController pushViewController:select_temp animated:YES];
    self.targetData = pageNode;//*/
}


- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray Navigation:(UINavigationController *)navgation {
    self.isNeedDelete = YES;
    self.navigation = navgation;
    NSMutableArray *personList = [NSMutableArray arrayWithCapacity:3];
        [personList addObjectsFromArray:[Person queryAllContacts]];
   
    sGroupDeleteContactCommand = self;
    TPSelectCopyViewController *select_temp = [[TPSelectCopyViewController alloc] init];
    select_temp.autoDismiss = YES;
    select_temp.delegate = sGroupDeleteContactCommand;
    select_temp.dataList = personList;
//    if (pageNode == nil) {
        select_temp.viewType = SelectViewGroupCommandAll;
//    } else {
//        select_temp.viewType = SelectViewGroupCommandGroup;
//    }
    select_temp.commandName = [self getCommandName];
    select_temp.type = SelectViewContollerTypeNormal;
    if (pageNode == nil) {
        // 批量删除联系热和发短信 合二为一
        select_temp.commandName = NSLocalizedString(@"batch_delete_contacts_and_send_sms", @"联系人");
    }
    UINavigationController *navController =
    ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
    [navgation pushViewController:select_temp animated:YES];
    self.targetData = pageNode;//*/


}


- (void)CHooseContactOnNavigation:(UIViewController *)viewController Finish:(void(^)(NSArray *personList))finishBlock Cancel:(void (^)(void))cancelBlock{
    
  //  + (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations NS_AVAILABLE_IOS(4_0); // delay = 0.0, options = 0, completion = NULL
    self.finishBlock = finishBlock;
    self.cancelBlock = cancelBlock;
    self.isNeedDelete = NO;
    _navigation = viewController.navigationController;
    NSMutableArray *personList = [NSMutableArray arrayWithCapacity:3];
    [personList addObjectsFromArray:[Person queryAllContacts]];
    
    sGroupDeleteContactCommand = self;
    TPSelectCopyViewController *select_temp = [[TPSelectCopyViewController alloc] init];
    select_temp.autoDismiss = NO;
    select_temp.delegate = sGroupDeleteContactCommand;
    select_temp.dataList = personList;
    //    if (pageNode == nil) {
    select_temp.viewType = SelectViewGroupCommandAll;
    //    } else {
    //        select_temp.viewType = SelectViewGroupCommandGroup;
    //    }
    select_temp.commandName = @"选择联系人";
//    if (navgation == nil) {
//        navgation =  ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;;
//    }
    select_temp.type = SelectViewContollerTypeSimple;
    [ viewController.navigationController pushViewController:select_temp animated:YES];
    
}


- (void)selectViewFinish:(NSArray *)select_list
{
    
    
    if (_isNeedDelete) {
        if (select_list.count > 0) {
            [DefaultUIAlertViewHandler showAlertViewWithTitle:(select_list.count == 1) ? NSLocalizedString(@"Confirm to delete?",@"")
                                                             : [NSString stringWithFormat:NSLocalizedString(@"Confirm to detele %d contacts?",@""), select_list.count]
                                                      message:nil
                                          okButtonActionBlock:^{
                                              BOOL needPopupWaitView = NO;
                                              if (select_list.count > 4) {
                                                  needPopupWaitView = YES;
                                                  [[NSNotificationCenter defaultCenter]postNotificationName:N_SHOW_INDICATOR object:nil];
                                              }
                                              if ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0f) {
                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (NSInteger)(0.01*NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                                                      [self deletePersons:select_list hasWaitView:needPopupWaitView];
                                                  });
                                              } else {
                                                  dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                                      [self deletePersons:select_list hasWaitView:needPopupWaitView];
                                                  });
                                              }
                                              
                                              //[cmd notifyCommandExecuted];
                                              [_navigation popViewControllerAnimated:YES];
                                          }
                                            cancelActionBlock:^{
                                                //[cmd notifyCommandExecuted];
                                            }
             ];
        }

    }else {
        NSMutableArray *dataNumber = [NSMutableArray new];
        if (select_list.count > 0 ) {
            for(int i = 0 ; i < select_list.count; i ++){
            
                ContactCacheDataModel * contact;
                
               contact = [ContactCacheDataManager instance].contactsCacheDict[@([select_list[i] integerValue])];
                NSString *number = [PhoneNumber getCNnormalNumber:((PhoneDataModel *)contact.phones[0]).number ];

                NSLog(@"%@ %d %@",contact.fullName, @([select_list[i] integerValue]),number);
                if (number.length > 0) {
                    
                    [dataNumber addObject:number];
                }
            }
        }
        self.finishBlock(dataNumber);
//        if ([_navigation respondsToSelector:@selector(popViewControllerAnimated:)]) {
////            [_navigation popViewControllerAnimated:YES];
//        }
    }
    
}

- (void)getNumberArray:(NSArray *)record_idsArray {

    ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    CFErrorRef err = nil;
    for (NSNumber *record_ids in record_idsArray) {
        NSInteger record_id =record_ids.integerValue;
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab,record_id);
        if (record_ids>0) {
            if (personRef) {
                if(ABAddressBookRemoveRecord(ab, personRef, &err)){
                    ContactCacheDataModel *contact = [ContactCacheDataManager instance].contactsCacheDict[@(record_id)];
                 }
            }
        }
    }


}

- (void) deletePersons:(NSArray *)select_list hasWaitView:(BOOL)needPopupWaitView{
    
    
    
    cootek_log(@"start delete contact");
    [Person deletePersonByRecordIDsArray:select_list];
    cootek_log(@"end delete contact");
    [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                        object:nil
                                                      userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_DATA_CHANGED object:nil];
    
    if (needPopupWaitView) {
        [[NSNotificationCenter defaultCenter]postNotificationName:N_DISMISS_INDICATOR object:nil];
    }
    [_navigation popViewControllerAnimated:YES];
}

- (void)selectViewCancel
{
    if(self.isNeedDelete) {
    if (!sGroupDeleteContactCommand) {
        sGroupDeleteContactCommand = nil;
    }
    }else {
        self.cancelBlock();
    }
}

@end
