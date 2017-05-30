//
//  BackgroundImageToast.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import "PresentToast.h"

typedef enum : NSInteger{
    ITDefault = 0,
    ITEvent,
}ImageType;

@interface BackgroundImageToast : PresentToast

@property (nonatomic, assign) ImageType imageType;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;

- (id)initWithDictonary:(NSDictionary *) dict;

@end
