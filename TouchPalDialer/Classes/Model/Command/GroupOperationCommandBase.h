//
//  OperationCommandBase.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//
typedef enum {
    OperationSheetTypeMyGroup,
    OperationSheetTypeSmartGroup,
    OperationSheetTypeAddContacts, // to add a contact or fav
    OperationSheetTypeAllContacts,
    OperationSheetTypeNoGroupContacts,
} OperationSheetType;

#import <Foundation/Foundation.h>
#import "CommonMultiSelectTableViewController.h"
#import "SelectViewController.h"
#import "LeafNode.h"

@protocol GroupOperationCommandDelegate <NSObject>

- (BOOL)willExecuteCommand;
- (void)didExecuteCommand;

@end

@interface GroupOperationCommandBase : NSObject

@property (nonatomic, retain) id targetData;
@property (nonatomic, assign) id<GroupOperationCommandDelegate> delegate;
@property (nonatomic, assign) UINavigationController* navController;

- (void)execute;
- (BOOL)canExecute:(OperationSheetType)sheetType;
- (NSString *)getCommandName;
// Don't call [delete didExecuteCommand], until the notifyCommandExecuted is called.
- (void)holdUntilNotified;
- (void)notifyCommandExecuted;

- (void)onExecute:(NSArray *)personList;
- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray;

@end
