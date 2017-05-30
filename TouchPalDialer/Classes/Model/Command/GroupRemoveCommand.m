//
//  GroupRemoveCommand.m
//  TouchPalDialer
//
//  Created by 史玮 阮 on 13-7-12.
//
//

#import "GroupRemoveCommand.h"
#import "TouchPalDialerAppDelegate.h"
#import "CommandDataHelper.h"
#import "TPABPersonActionController.h"
#import "GroupedContactsModel.h"
#import "SmartGroupNode.h"
#import "CootekNotifications.h"
#import "Person.h"

static GroupRemoveCommand *sGroupRemoveCommand;
@implementation GroupRemoveCommand
- (BOOL)canExecute:(OperationSheetType)sheetType
{
    if (sheetType == OperationSheetTypeMyGroup) {
        return TRUE;
    }
    return FALSE;
}

- (void)onExecute:(NSArray *)personList
{
    [self holdUntilNotified];
}

- (NSString *)getCommandName
{
    return NSLocalizedString(@"Remove members", @"移除组成员");
}

- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray
{
    NSMutableArray *personList = [NSMutableArray arrayWithCapacity:3];
//    for (NSNumber *personID in pageNode.contactIds) {
//        [personList addObject:[Person getConatctInfoByRecordID:[personID intValue]]];
//    }
    personList = personArray;
    sGroupRemoveCommand = self;
    SelectViewController *select_temp = [[SelectViewController alloc] init];
	select_temp.delegate = sGroupRemoveCommand;
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

- (void)selectViewFinish:(NSArray *)select_list
{
    if (select_list.count > 0) {
        for (NSNumber *item in select_list) {
            NSInteger personId = [item intValue];
            [GroupedContactsModel deleteMemberById:personId fromGroup:((GroupNode *)self.targetData).groupID];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE object:nil];
    }
}

- (void)selectViewCancel
{
    sGroupRemoveCommand = nil;
}

@end
