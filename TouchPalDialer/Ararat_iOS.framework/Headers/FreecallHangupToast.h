//
//  FreecallHangupToast.h
//  Presentation_iOS
//
//  Created by ThomasYe on 2015/1/21.
//  Copyright (c) 2015年 SongchaoYuan. All rights reserved.
//

#import "PresentToast.h"

typedef enum : NSInteger{
    ITWeak = 0,
    ITStrong,
} FreecallHangupToastType;

@interface FreecallHangupToast : PresentToast

@property (nonatomic, assign) FreecallHangupToastType toastType;

- (id)initWithDictonary:(NSDictionary *) dict;

@end

