//
//  DummyAction.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import "PresentAction.h"

@interface DummyAction : PresentAction

- (BOOL)meetAction:(int)actionType and:(NSArray *)stringArray;
- (void)onClick:(PresentToast *)pt and:(BOOL)afterConfirm;
@end
