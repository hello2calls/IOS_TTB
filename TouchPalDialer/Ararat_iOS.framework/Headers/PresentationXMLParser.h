//
//  PresentationXMLParser.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/25.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresentationXMLParser : NSObject

- (void)parserXMLData:(NSData *)data ToPresentToasts:(void (^)(NSArray *toasts))block;

@end


