//
//  YPAdTaskDavinci.h
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPTaskBase.h"

@interface YPAdTaskDavinci : YPTaskBase
@property(assign, setter=setRefresh:)BOOL isRefresh;
@property(strong, setter=setFtu:)NSString* ftu;
@end
