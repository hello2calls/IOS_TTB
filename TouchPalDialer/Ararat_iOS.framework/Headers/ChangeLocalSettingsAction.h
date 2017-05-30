//
//  ChangeLocalSettingsAction.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import "PresentAction.h"

@interface ChangeLocalSettingsAction : PresentAction

@property (nonatomic, strong) NSMutableDictionary *boolSettings;
@property (nonatomic, strong) NSMutableDictionary *stringSettings;
@property (nonatomic, strong) NSMutableDictionary *integerSettings;
@property (nonatomic, strong) NSMutableDictionary *longSettings;
@property (nonatomic, strong) NSMutableDictionary *onlyDefault;

- (id)initWithDictonary:(NSDictionary *)dict;
- (BOOL)meetAction:(int)actionType and:(NSArray *)stringArray;
- (void)onClick:(PresentToast *)pt and:(BOOL)afterConfirm;
@end
