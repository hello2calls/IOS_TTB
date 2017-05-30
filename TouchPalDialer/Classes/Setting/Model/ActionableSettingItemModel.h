//
//  ActionableSettingItemModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SettingItemModel.h"

@interface ActionableSettingItemModel : SettingItemModel

@property (nonatomic, copy) void(^actionBlock)(UIViewController* vc) ;

+(ActionableSettingItemModel*) itemWithTitle:(NSString*) title actionBlock:(void(^)(UIViewController*))actionBlock;

-(void) executeAction:(UIViewController*) vc;
@end
