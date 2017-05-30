//
//  MyTaskItem.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/26.
//
//

#import "BaseItem.h"

@interface MyTaskItem : BaseItem

@property(nonatomic, strong)NSMutableDictionary* rewards;
@property(nonatomic, assign)BOOL isShowing;

@end
