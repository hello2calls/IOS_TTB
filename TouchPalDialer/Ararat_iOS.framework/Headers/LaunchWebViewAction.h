//
//  LaunchWebViewAction.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import "PresentAction.h"

@interface LaunchWebViewAction : PresentAction

@property (nonatomic, strong) NSString *webTitle;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL requestToken;

- (id)initWithDictonary:(NSDictionary *)dict;
- (BOOL)meetAction:(int)actionType and:(NSArray *)stringArray;
- (void)onClick:(PresentToast *)pt and:(BOOL)afterConfirm;
@end
