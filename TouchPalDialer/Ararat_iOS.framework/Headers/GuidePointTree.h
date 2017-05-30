//
//  GuidePointTree.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/3.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuidePointNode.h"

@interface GuidePointTree : NSObject

@property (nonatomic, strong) NSString *toastId;

- (void)generateGuidePointTreeWithDictionary:(NSDictionary *)dict;
- (BOOL)canShow:(GuidePointNode *)node;
- (int)childrenCountWithGuidePointId:(NSString *)guidePointId;
- (int)getTypeWithGuidePointId:(NSString *)guidePointId;
- (void)clickedWithGuidePointId:(NSString *)guidePointId;
- (void)shownWithGuidePointId:(NSString *)guidePointId;
@end
