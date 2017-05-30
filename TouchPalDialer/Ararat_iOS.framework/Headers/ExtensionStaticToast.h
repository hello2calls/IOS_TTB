//
//  ExtensionStaticToast.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import "PresentToast.h"

@interface ExtensionStaticToast : PresentToast

@property (nonatomic, strong) NSString *guidePointId;
@property (nonatomic, strong) NSString *extensionPoint;

- (id)initWithDictonary:(NSDictionary *) dict;

@end
