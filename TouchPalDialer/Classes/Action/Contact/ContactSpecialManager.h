//
//  ContactSpecialManager.h
//  TouchPalDialer
//
//  Created by game3108 on 15/4/21.
//
//

#import <Foundation/Foundation.h>
#import "ContactSpecialInfo.h"

@interface ContactSpecialManager : NSObject
@property (nonatomic,strong) NSMutableArray *specialArray;
+ (instancetype) instance;
- (void) generateSpecial:(SpecialNodeType)type;
- (NSArray *)getSpecialArray;
@end
