//
//  GroupDeleteContactCommandCopy.h
//  TouchPalDialer
//
//  Created by H L on 2016/10/27.
//
//

#import <Foundation/Foundation.h>
#import "GroupOperationCommandBase.h"

@interface GroupDeleteContactCommandCopy : GroupOperationCommandBase <SelectViewProtocalDelegate>

- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray Navigation:(UINavigationController *)navgation ;

- (void)CHooseContactOnNavigation:(UIViewController *)viewController Finish:(void(^)(NSArray *personList))finishBlock Cancel:(void (^)(void))cancelBlock;

@end
