//
//  DataVersionManager.h
//  Ararat_iOS
//
//  Created by Cootek on 15/8/12.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataVersionManager : NSObject

- (id)initWithDataName:(NSString *)dataName andBackNum:(int)backupNum;
- (BOOL)rollBack;
- (BOOL)clearBackup;
- (void)clearAllData;

@end
