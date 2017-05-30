//
//  PresentConfigUpdater.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/11.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentationXMLParser.h"

@interface PresentConfigUpdater : NSObject
@property(nonatomic, strong) PresentationXMLParser *parser;

- (void)loadLocalConfigAndUpdate;
- (void)fetchRemoteConfig;
- (void)checkRemoteConfig;
- (BOOL)canUpdate;
- (void)downloadConfigFileWithToken:(NSString *)authToken WithBlock:(void(^)(BOOL result))block;
- (void)onlyDownloadConfigFileWithBlock:(void(^)(BOOL result))block;
@end
