//
//  PresentAction.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/26.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentToast.h"

@class PresentToast;

@interface PresentAction : NSObject

@property (nonatomic, assign) int cleanAcknowledge;

- (BOOL)meetCondition;
- (void)onClick:(PresentToast *)pt and:(BOOL)afterConfirm;
- (BOOL)meetAction:(int)actionType and:(NSArray *)stringArray;
- (void)autoPerformNextAction:(int)actionType and:(NSArray *)stringArray;
@end
