//
//  GroupOperationCommandCreatorCopy.m
//  TouchPalDialer
//
//  Created by H L on 2016/10/27.
//
//

#import "GroupOperationCommandCreatorCopy.h"
#import "GroupAddToContactCommand.h"
#import "GroupDeleteContactCommandCopy.h"
#import "GroupSendSMSCommand.h"
#import "GroupIncludeCommand.h"
#import "GroupRemoveCommand.h"
#import "GroupAddToFavoriteCommand.h"
#import "InvitingCommand.h"


@implementation GroupOperationCommandCreatorCopy
+ (GroupOperationCommandBase *)commandForType:(CommandType)commandType withData:(id)data
{
    GroupOperationCommandBase *command = nil;
    switch (commandType) {
        case CommandTypeAddToContact:
            command = [[GroupAddToContactCommand alloc] init];
            break;
        case CommandTypeDeleteContact:
            command = [[GroupDeleteContactCommandCopy alloc] init];
            break;
        case CommandTypeSendSMS:
            command = [[GroupSendSMSCommand alloc] init];
            break;
        case CommandTypeGroupInclude:
            command = [[GroupIncludeCommand alloc] init];
            break;
        case CommandTypeGroupRemove:
            command = [[GroupRemoveCommand alloc] init];
            break;
        case CommandTypeAddToFavorite:
            command = [[GroupAddToFavoriteCommand alloc] init];
            break;
        case CommandTypeInviting: {
            command = [[InvitingCommand alloc] init];
            break;
        }
        default:
            break;
    }
    
    command.targetData = data;
    return command;
}


+ (NSArray *)getCommandList:(OperationSheetType)sheetType withContacts:(BOOL)haveContacts withPhones:(BOOL)havePhones
{
    NSMutableArray *commandNameList = [[NSMutableArray alloc] initWithCapacity:0];
    for (CommandType type = CommandTypeAddToContact; type <= CommandTypeDeleteContact; type++) {
        //
        BOOL isDeleteAction =
        (type == CommandTypeDeleteContact)
        || (type == CommandTypeGroupRemove)
        || (type == CommandTypeSendSMS);
        
        if ((!haveContacts) && isDeleteAction) {
            continue;
        }
        if ((!havePhones) && (type == CommandTypeSendSMS)) {
            continue;
        }
        
        GroupOperationCommandBase *command = [GroupOperationCommandCreatorCopy commandForType:type withData:nil];
        if ([command canExecute:sheetType]){
            [commandNameList addObject:[command getCommandName]];
        }
    }
    return [commandNameList copy];
}

+ (void)executeCommandWithTitle:(NSString *)commandTitle AndCurrentNode:(LeafNodeWithContactIds *)currentNode withPersonArray:(NSMutableArray *)personArray
{
    GroupOperationCommandBase *command;
    for (CommandType type = CommandTypeAddToContact; type <= CommandTypeDeleteContact; type++){
        command = [GroupOperationCommandCreatorCopy commandForType:type withData:nil];
        if([[command getCommandName] isEqualToString:commandTitle]){
            [command onClickedWithPageNode:currentNode withPersonArray:personArray];
            break;
        }
    }
}
+ (void)executeCommandWithTitle:(NSString *)commandTitle message:(NSString *)message resultCallback:(ShareResultCallback)resultBack{
    GroupSendSMSCommand *command = [[GroupSendSMSCommand alloc] init];
    if ([commandTitle isEqualToString:@"群发短信"]) {
        [command onClickedWithMessage:message resultCallback:resultBack];
    }
    
}


+ (void)executeCommandWithPerson:(NSArray *)selectedPerson AndCommandTitle:(NSString *)commandTitle
{
    GroupOperationCommandBase *command;
    for (CommandType type = CommandTypeAddToContact; type <= CommandTypeDeleteContact; type++){
        command = [GroupOperationCommandCreatorCopy commandForType:type withData:nil];
        if([[command getCommandName] isEqualToString:commandTitle]){
            [command onExecute:selectedPerson];
        }
    }
}
@end
