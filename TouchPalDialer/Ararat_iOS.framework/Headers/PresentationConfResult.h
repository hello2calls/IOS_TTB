//
//  PresentationConfResult.h
//  Ararat_iOS
//
//  Created by Cootek on 15/8/20.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#import "DataResult.h"

@interface PresentationConfResult : DataResult

- (id)initWithDataName:(NSString *)dataName;
- (BOOL)checkData;
- (BOOL)checkFormat;

@end
