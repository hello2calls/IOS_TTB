//
//  DeleteContactCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "GroupDeleteContactCommand.h"
#import "CommandDataHelper.h"
#import "DefaultUIAlertViewHandler.h"
#import "Person.h"
#import "TouchPalDialerAppDelegate.h"
#import "OrlandoEngine.h"
#import "CootekNotifications.h"
#import "GroupedContactsModel.h"

static GroupDeleteContactCommand *sGroupDeleteContactCommand;

@implementation GroupDeleteContactCommand

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
    SelectViewController *select_temp = [[SelectViewController alloc] init];
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

- (void)selectViewFinish:(NSArray *)select_list
{
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
                                  }
                                    cancelActionBlock:^{
                                        //[cmd notifyCommandExecuted];
                                    }
     ];
    }

    //[self release];
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
}

- (void)selectViewCancel
{
    if (!sGroupDeleteContactCommand) {
        sGroupDeleteContactCommand = nil;
    }
}

@end
