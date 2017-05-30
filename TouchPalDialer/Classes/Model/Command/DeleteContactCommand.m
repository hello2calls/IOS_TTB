//
//  DeleteContactCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "DeleteContactCommand.h"
#import "CommandDataHelper.h"
#import "DefaultUIAlertViewHandler.h"
#import "Person.h"
#import "ContactCacheDataModel.h"
#import "DialerUsageRecord.h"
@implementation DeleteContactCommand

- (BOOL)canExecute
{
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    return personId > 0;
}

- (void)onExecute
{
  
    if ([self.targetData isKindOfClass:[ContactCacheDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CONTACT_ACTION, @"delete"), nil];
    }
    [self holdUntilNotified];
    __weak DeleteContactCommand *cmd = self;
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Confirm to delete?",@"")
                                              message:nil
                                  okButtonActionBlock:^{
                                        int personId = [CommandDataHelper personIdFromData:self.targetData];
                                        if(personId > 0) {
                                            [Person deletePersonByRecordID:personId];
                                        }
                                        [cmd notifyCommandExecuted];
                                    }
                                    cancelActionBlock:^{
                                        [cmd notifyCommandExecuted];
                                    }
     ];
}

@end
