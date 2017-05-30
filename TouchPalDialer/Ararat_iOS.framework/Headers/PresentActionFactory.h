//
//  PresentActionFactory.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/3.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentAction.h"

@interface PresentActionFactory : NSObject

+ (PresentAction *)generateWithName:(NSString *)name AndDictionary:(NSDictionary *)dict;

@end
