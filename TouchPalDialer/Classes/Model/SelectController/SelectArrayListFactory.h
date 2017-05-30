//
//  SelectArrayListFactory.h
//  TouchPalDialer
//
//  Created by game3108 on 16/4/12.
//
//

#import <Foundation/Foundation.h>
#import "SelectController.h"

@interface SelectArrayListFactory : NSObject
+ (NSArray *)getSelectArrayBySelectType:(SelectType) selectType;
@end
