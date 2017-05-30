//
//  TPDContactInfoUtil.m
//  TouchPalDialer
//
//  Created by ALEX on 16/9/21.
//
//

#import "TPDContactInfoUtil.h"
#import "TPABPersonActionController.h"

@implementation TPDContactInfoUtil

+ (void) chooseAddActionByNumber:(NSString *)number presentByNav:(UINavigationController *)nav {
    //add contact
    //luchenAdded
    [[TPABPersonActionController controller] chooseAddActionWithNewNumber:number
                                                              presentedBy:nav];
}

+ (void) chooseEditDeleteActionByPersonId:(NSInteger)personId presentByNav:(UINavigationController *)nav {
    //edit/delete contact
    [[TPABPersonActionController controller] chooseEditDeleteActionById:personId
                                                            presentedBy:nav];
}
@end
