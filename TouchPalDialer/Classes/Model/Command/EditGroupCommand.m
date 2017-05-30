//
//  EditGroupCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "EditGroupCommand.h"
#import "CommandDataHelper.h"

@implementation EditGroupCommand
- (BOOL)canExecute
{
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    return personId > 0;
}

- (void)onExecute
{
    [self holdUntilNotified];
    int personId = [CommandDataHelper personIdFromData:self.targetData];
    GroupSelector *group_controller = [[GroupSelector alloc] init];
    group_controller.delegate = self;
    group_controller.personId = personId;
    [self.navController pushViewController:group_controller animated:YES];
}

- (void)groupChanged {
    [self notifyCommandExecuted];
}

@end
