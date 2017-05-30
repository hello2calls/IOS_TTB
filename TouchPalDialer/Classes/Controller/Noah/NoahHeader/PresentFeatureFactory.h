//
//  PresentFeatureFactory.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentFeature.h"

@interface PresentFeatureFactory : NSObject

+ (PresentFeature *)generateWithName:(NSString *)name AndDictionary:(NSDictionary *)dict;

@end
