//
//  TPGroupSelectActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/20/12.
//
//

#import <Foundation/Foundation.h>
#import "GroupSelector.h"

@interface TPGroupSelectActionController : NSObject<GroupSelectorDelegate>

+(TPGroupSelectActionController *) controller;

-(void) selectGroupByPersonId:(NSInteger)personId pushedBy:(UINavigationController *)aNavigationController;

@end
