//
//  GroupAddToFavoriteCommand.m
//  TouchPalDialer
//
//  Created by Simeng on 14-7-2.
//
//

#import "GroupAddToFavoriteCommand.h"
#import "TouchPalDialerAppDelegate.h"
#import "GroupedContactsModel.h"
#import "Group.h"
#import "SmartGroupNode.h"
#import "Favorites.h"
#import "CootekNotifications.h"

static GroupAddToFavoriteCommand *sGroupAddToFavoriteCommand;
@implementation GroupAddToFavoriteCommand

- (BOOL)canExecute:(OperationSheetType)sheetType
{
    NSArray *executeList = [[NSArray alloc] initWithObjects:@(OperationSheetTypeAllContacts), @(OperationSheetTypeAddContacts), nil];
    if([executeList indexOfObject:@(sheetType)] == NSNotFound){
        return FALSE;
    }
    return TRUE;
}

- (void)onExecute:(NSArray *)personList
{
    [self holdUntilNotified];
}

- (NSString *)getCommandName
{
    return NSLocalizedString(@"detail_shortcut_favor", @"");
}

- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray
{
    sGroupAddToFavoriteCommand = self;
    self.targetData = pageNode;
    SelectViewController *select_temp = [[SelectViewController alloc] init];
    select_temp.dataList = [self getPersonWithoutFavorite];
    select_temp.delegate = sGroupAddToFavoriteCommand;
    select_temp.viewType = SelectViewGroupCommandAll;
    select_temp.commandName = [self getCommandName];
    UINavigationController *navController =
    ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
    [navController pushViewController:select_temp animated:YES];
}

- (NSArray *)getPersonWithoutFavorite
{
    NSArray *allCachePersons = [ContactCacheDataManager instance].getAllCacheContact;
    NSMutableArray *personList = [[NSMutableArray alloc] initWithCapacity:allCachePersons.count];
    for (ContactCacheDataModel *person in allCachePersons) {
        if (![Favorites isExistFavorite:person.personID]) {
            [personList addObject:person];
        }
    }
    return personList;
}

- (void)selectViewFinish:(NSArray *)select_list
{
    if (select_list.count > 0) {
        [Favorites addFavoriteByRecordIdArray:select_list];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE object:nil];
}

- (void)selectViewCancel
{
    if (!sGroupAddToFavoriteCommand) {
        sGroupAddToFavoriteCommand = nil;
    }
}

@end
