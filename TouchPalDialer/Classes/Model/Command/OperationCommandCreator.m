//
//  OperationCommandCreator.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-13.
//
//

#import "OperationCommandCreator.h"

#import "EditContactCommand.h"
#import "RemoveCallsCommand.h"
#import "EditToCallCommand.h"
#import "SendSMSCommand.h"
#import "ShareContactCommand.h"
#import "CopyPhoneNumberCommand.h"
#import "DeleteContactCommand.h"
#import "AlipayTACommand.h"
#import "AddToContactCommand.h"
#import "EditGroupCommand.h"
#import "MakeCallCommand.h"
#import "MoreCommand.h"
#import "AddToFavoriteCommand.h"

@implementation OperationCommandCreator
+ (OperationCommandBase *)commandForType:(CommandType)commandType withData:(id)data
{
    OperationCommandBase *command = nil;
    switch (commandType) {
        case CommandTypeEditContact:
            command = [[EditContactCommand alloc] init];
            break;
        case CommandTypeRemoveCalls:
            command = [[RemoveCallsCommand alloc] init];
            break;
        case CommandTypeEditToCall:
            command = [[EditToCallCommand alloc] init];
            break;
        case CommandTypeSendSMS:
            command = [[SendSMSCommand alloc] init];
            break;
        case CommandTypeShareContact:
            command = [[ShareContactCommand alloc] init];
            break;
        case CommandTypeCopyPhoneNumber:
            command = [[CopyPhoneNumberCommand alloc] init];
            break;
        case CommandTypeDeleteContact:
            command = [[DeleteContactCommand alloc] init];
            break;
        case CommandTypeAlipayTA:
            command = [[AlipayTACommand alloc] init];
            break;
        case CommandTypeAddToContact:
            command = [[AddToContactCommand alloc] init];
            break;
        case CommandTypeEditGroup:
            command = [[EditGroupCommand alloc] init];
            break;
        case CommandTypeMakeCall:
            command = [[MakeCallCommand alloc] init];
            break;
        case CommandTypeMore:
            command = [[MoreCommand alloc] init];
            break;
        case CommandTypeAddToFavorite:
            command = [[AddToFavoriteCommand alloc] init];
        default:
            break;
    }
    
    command.targetData = data;
    return command;
}
@end
