//
//  GroupIncludeCommand.m
//  TouchPalDialer
//
//  Created by 史玮 阮 on 13-7-12.
//
//

#import "GroupIncludeCommand.h"
#import "TouchPalDialerAppDelegate.h"
#import "CommandDataHelper.h"
#import "TPABPersonActionController.h"
#import "GroupedContactsModel.h"
#import "SmartGroupNode.h"
#import "CootekNotifications.h"
#import "Group.h"

static GroupIncludeCommand *sGroupIncludeCommand;
@implementation GroupIncludeCommand

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
    return NSLocalizedString(@"Add members", @"添加组成员");
}

- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray
{
    sGroupIncludeCommand = self;
    SelectViewController *select_temp = [[SelectViewController alloc] init];
    select_temp.dataList = [self getPersonWithoutGroup:((GroupNode *)pageNode).groupID];
    select_temp.delegate = sGroupIncludeCommand;
    select_temp.viewType = SelectViewGroupCommandAll;
    select_temp.commandName = [self getCommandName];
    select_temp.groupID = ((GroupNode *)pageNode).groupID;
    UINavigationController *navController =
    ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
    [navController pushViewController:select_temp animated:YES];
    self.targetData = pageNode;
}


- (NSArray *)getPersonWithoutGroup:(NSInteger)groupID
{
    NSArray *allCachePersons = [ContactCacheDataManager instance].getAllCacheContact;
    NSMutableArray *personList = [NSMutableArray arrayWithArray:allCachePersons];
    NSArray* groupMemberIds = [Group getMemberIDListByGroupID:groupID];
    for(id Id in groupMemberIds){
        ContactCacheDataModel *cachePerson =  [[ContactCacheDataManager instance] contactCacheItem:[((NSNumber *)Id) intValue]];
        [personList removeObject:cachePerson];
    }
    return personList;
}

- (void)selectViewFinish:(NSArray *)select_list
{
    if (select_list.count > 0) {
        [GroupedContactsModel addMembers:select_list toGroup:((GroupNode *)self.targetData).groupID];
    }
}

- (void)selectViewCancel
{
    if (!sGroupIncludeCommand) {
        sGroupIncludeCommand = nil;
    }
}

@end
