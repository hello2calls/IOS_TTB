//
//  CTKCryptUtil.h
//  TouchPalDialer
//
//  Created by Almark M on 15/9/8.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "CTKRSACryptor.h"


extern NSString * const CTKCryptErrorDomain;


@interface CTKAESCryptor : NSObject

/* AES encryption with ECB mode using generated key from password and salt */
+ (NSData *)encryptAES128ECBWithData:(NSData *)data
                            password:(NSString *)password
                                salt:(NSData **)salt
                               error:(NSError **)error;

+ (NSData *)decryptAES128ECBWithData:(NSData *)data
                            password:(NSString *)password
                                salt:(NSData *)salt
                               error:(NSError **)error;

/* AES encryption with ECB mode using random generated key */
+ (NSData *)encryptAES128ECBWithData:(NSData *)data
                           randomKey:(NSData **)randomKey
                               error:(NSError **)error;

+ (NSData *)decryptAES128ECBWithData:(NSData *)data
                                 key:(NSData *)key
                               error:(NSError **)error;

@end


@interface CTKAESCryptBot : NSObject
- (id)initWithRandomKey;
- (id)initWithPassword:(NSString *)password;

- (NSData *)aes128ECBEncryptWithData:(NSData *)data;
- (NSData *)aes128ECBDecryptWithData:(NSData *)data;
- (NSString *)aes128ECBEncryptGTMBase64String:(NSString *)data;
- (NSString *)aes128ECBDecryptGTMBase64String:(NSString *)data;

- (NSData *)rsaPublicKeyNonePaddingEncryptWithData:(NSData *)data;
- (NSString *)rsaPublicKeyNonePaddingEncryptGTMBase64String:(NSString *)data;

- (NSString *)getEncryptedAESKey;
@end