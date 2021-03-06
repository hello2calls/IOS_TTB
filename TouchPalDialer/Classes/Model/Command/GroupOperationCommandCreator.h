//
//  OperationCommandCreator.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-13.
//
//

#import <Foundation/Foundation.h>
#import "TPWebShareController.h"
#import "GroupOperationCommandBase.h"

// equal to or greater than CommandTypeSentinel will not be shown
typedef enum {
    CommandTypeAddToContact,
    CommandTypeAddToFavorite,
    CommandTypeSendSMS,
    CommandTypeInviting,
    CommandTypeGroupInclude,
    CommandTypeGroupRemove,
    CommandTypeDeleteContact,
} CommandType;


@interface GroupOperationCommandCreator : NSObject

+ (GroupOperationCommandBase *)commandForType:(CommandType)commandType withData:(id)data;
+ (NSArray *)getCommandList:(OperationSheetType)sheetType withContacts:(BOOL)haveContacts withPhones:(BOOL)havePhones;
+ (void)executeCommandWithPerson:(NSArray *)selectedPerson AndCommandTitle:(NSString *)commandTitle;
+ (void)executeCommandWithTitle:(NSString *)commandTitle AndCurrentNode:(LeafNodeWithContactIds *)currentNode withPersonArray:(NSMutableArray *)personArray;
+ (void)executeCommandWithTitle:(NSString *)commandTitle message:(NSString *)message resultCallback:(ShareResultCallback)resultBack;
@end
