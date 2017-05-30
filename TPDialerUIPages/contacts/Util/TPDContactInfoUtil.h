//
//  TPDContactInfoUtil.h
//  TouchPalDialer
//
//  Created by ALEX on 16/9/21.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactInfoCellModel.h"
#import "CallLogDataModel.h"

@interface TPDContactInfoUtil : NSObject

+ (void) chooseAddActionByNumber:(NSString *)number presentByNav:(UINavigationController *)nav;
+ (void) chooseEditDeleteActionByPersonId:(NSInteger)personId presentByNav:(UINavigationController *)nav;
@end
