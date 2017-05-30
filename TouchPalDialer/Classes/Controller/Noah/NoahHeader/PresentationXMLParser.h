//
//  PresentationXMLParser.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/25.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalStrategy.h"

@interface PresentationXMLParser : NSObject
- (void)parserFileToDictionary:(void(^)(GlobalStrategy *strategy, NSArray *toasts))block;
@end


