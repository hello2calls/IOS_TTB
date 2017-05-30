//
//  EditContactCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "EditContactCommand.h"
#import "CommandDataHelper.h"
#import "TPABPersonActionController.h"
#import "TouchPalDialerAppDelegate.h"
#import "DialerUsageRecord.h"
#import "ContactCacheDataModel.h"

@implementation EditContactCommand

- (BOOL)canExecute
{
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    return personId > 0;
}

- (void)onExecute
{
    
    if ([self.targetData isKindOfClass:[ContactCacheDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CONTACT_ACTION, @"edit"), nil];
    }
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
//    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    UIViewController* aViewController = [TouchPalDialerAppDelegate naviController];
    [[TPABPersonActionController controller] editPersonById:personId
                                                presentedBy:aViewController];
}

@end
