//
//  OperationCommandBase.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import <Foundation/Foundation.h>

@protocol OperationCommandDelegate <NSObject>

- (BOOL)willExecuteCommand;
- (void)didExecuteCommand;

@end

@interface OperationCommandBase : NSObject

@property (nonatomic, retain) id targetData;
@property (nonatomic, assign) id<OperationCommandDelegate> delegate;
@property (nonatomic, assign) UINavigationController* navController;

- (void)execute;
- (BOOL)canExecute;

// Don't call [delete didExecuteCommand], until the notifyCommandExecuted is called.
- (void)holdUntilNotified;
- (void)notifyCommandExecuted;

- (void)onExecute;
@end
