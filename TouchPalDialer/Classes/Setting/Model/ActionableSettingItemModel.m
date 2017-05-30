//
//  ActionableSettingItemModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "ActionableSettingItemModel.h"

@implementation ActionableSettingItemModel

@synthesize actionBlock;

+(ActionableSettingItemModel*) itemWithTitle:(NSString*) title actionBlock:(void(^)(UIViewController*))actionBlock {
    ActionableSettingItemModel* item = [[ActionableSettingItemModel alloc] init];
    item.title = title;
    item.actionBlock = actionBlock;
    return item;
}

-(void) executeAction:(UIViewController*) vc {
    if(actionBlock!= nil) {
        actionBlock(vc);
    }
}

@end
