//
//  AddToContactCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "GroupAddToContactCommand.h"
#import "TouchPalDialerAppDelegate.h"
#import "CommandDataHelper.h"
#import <Foundation/Foundation.h>
#import "SmartGroupNode.h"
#import "GroupedContactsModel.h"
#import <AddressBook/AddressBook.h>
#import "CootekNotifications.h"

static GroupAddToContactCommand *sGroupAddToContactCommand;
@implementation GroupAddToContactCommand

- (BOOL)canExecute:(OperationSheetType)sheetType
{
    NSArray *executeList = [[NSArray alloc] initWithObjects:@(OperationSheetTypeAllContacts), @(OperationSheetTypeAddContacts), nil];
    if([executeList indexOfObject:@(sheetType)] == NSNotFound){
        return NO;
    }
    return YES;
}

- (void)onExecute:(NSArray *)personList
{
    [self holdUntilNotified];
//    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    UIViewController* aViewController = [TouchPalDialerAppDelegate naviController];
    [[TPABPersonActionController controller] addNewPersonPresentedBy:aViewController];
}

- (NSString *)getCommandName
{
    return NSLocalizedString(@"New contact", @"新建联系人");
}

- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray
{
    [self executeAddContactToGroup:pageNode];
}

- (void)executeAddContactToGroup:(LeafNodeWithContactIds *)pageNode
{
    sGroupAddToContactCommand = self;
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    [[TPABPersonActionController controller]setTarget:sGroupAddToContactCommand];
    if ([pageNode isKindOfClass:[GroupNode class]]) {
        if (((GroupNode *)pageNode).groupID != UNGROUPED_GROUP_ID) {
            self.targetData = pageNode;
        }
    }
    [[TPABPersonActionController controller] addNewPersonPresentedBy:aViewController];
}

- (void)doAfterAction:(ABRecordRef)person
{
    if (self.targetData != nil) {
        NSInteger personID = ABRecordGetRecordID(person);
        [GroupedContactsModel addMemberById:personID toGroup:((GroupNode *)self.targetData).groupID];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                            object:nil
                                                          userInfo:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_DATA_CHANGED object:nil];
}

- (void)doAfterCancel
{
    if (!sGroupAddToContactCommand) {
        sGroupAddToContactCommand = nil;
    }
}

@end
