//
//  GuidePointsToast.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import "PresentToast.h"

@interface GuidePointsToast : PresentToast

- (id)initWithDictonary:(NSDictionary *) dict;

- (int)getChildrenCount:(NSString *)guidePointId;
- (int)getGuideType:(NSString *)guidePointId;
- (void)clicked:(NSString *)guidePointId;
- (void)shown:(NSString *)guidePointId;
- (void)setFeatureAndId:(PresentFeature *)feature;

@end
