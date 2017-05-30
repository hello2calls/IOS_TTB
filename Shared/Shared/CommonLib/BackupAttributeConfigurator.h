//
//  SkipBackupAttributeConfigurator.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-3-7.
//
//

#import <Foundation/Foundation.h>

@interface BackupAttributeConfigurator : NSObject

+ (void)skipBackupAttributeAtPath:(NSString *)path
                     skipOrBackup:(BOOL)skipOrBackup;

@end
