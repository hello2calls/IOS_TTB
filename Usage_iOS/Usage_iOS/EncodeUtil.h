//
//  EncodeUtil.h
//  Usage_iOS
//
//  Created by SongchaoYuan on 16/1/26.
//  Copyright © 2016年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodeUtil : NSObject

+ (NSString *)encryptRSA:(NSData *)key;
+ (NSString *)encryptAESWithData:(NSData *)data andKey:(NSData *)key;
+ (NSData *)generateKey;

@end
