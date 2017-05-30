//
//  NSData+Encryption.h
//  Usage_iOS
//
//  Created by SongchaoYuan on 16/2/1.
//  Copyright © 2016年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encryption)

- (NSData *)AES256EncryptWithKey:(NSData *)key;

@end
