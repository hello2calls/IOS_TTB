//
//  Presentations.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PresentToast;

@interface Presentations : NSObject

@property (nonatomic, strong) NSMutableArray *toasts;
@property (nonatomic, strong) NSMutableArray *dynamicToasts;

- (PresentToast *)findToastByFeatureId:(NSString *)featureId;
- (PresentToast *)findToastByFeatureId:(NSString *)featureId andToasts:(NSArray *)toasts;
- (PresentToast *)findToastByClassName:(Class)className andKey:(NSString *)key;
- (NSArray *)findToastsByClassName:(Class)className andKey:(NSString *)key;
- (NSArray *)getMeetActionToasts:(int)actionType and:(NSArray *)stringArray;
- (void)sort;
@end
