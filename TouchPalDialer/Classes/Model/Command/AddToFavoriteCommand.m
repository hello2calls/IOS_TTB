//
//  AddToFavoriteCommand.m
//  TouchPalDialer
//
//  Created by Puyo on 14-7-7.
//
//

#import "AddToFavoriteCommand.h"
#import "CommandDataHelper.h"
#import "Favorites.h"
#import "DefaultUIAlertViewHandler.h"
#import "ContactCacheDataModel.h"
#import "DialerUsageRecord.h"

@implementation AddToFavoriteCommand

- (BOOL)canExecute
{
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    return personId > 0;
    
}

- (void)onExecute
{
    if ([self.targetData isKindOfClass:[ContactCacheDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CONTACT_ACTION, @"collect"), nil];
    }
    [self holdUntilNotified];
    int personId = [CommandDataHelper personIdFromData:self.targetData];
    BOOL isFavorite = [Favorites isExistFavorite:personId];
    if (isFavorite) {
        [Favorites removeFavoriteByRecordId:personId];
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Removed from favorites", @"") message:nil dismissIn:1];
    } else {
        [Favorites addFavoriteByRecordId:personId];
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Added to favorites", @"") message:nil dismissIn:1];
    }
}
@end
