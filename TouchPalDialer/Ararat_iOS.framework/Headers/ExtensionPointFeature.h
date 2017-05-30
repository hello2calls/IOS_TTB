//
//  ExtensionPointFeature.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/27.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import "PresentFeature.h"

@interface ExtensionPointFeature : PresentFeature

@property (nonatomic, strong) NSString *packageName;
@property (nonatomic, assign) int packageOldVersion;
@property (nonatomic, strong) NSString *extensionPoint;
@property (nonatomic, strong) NSString *extensionConditions;

- (id)initWithDictonary:(NSDictionary *) dict;

@end
