//
//  PresentToastFactory.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentToast.h"

@interface PresentToastFactory : NSObject

+ (PresentToast *)generateWithName:(NSString *)name AndDictionary:(NSDictionary *)dict;
+ (BOOL)needQuiet:(Class)className;
@end
