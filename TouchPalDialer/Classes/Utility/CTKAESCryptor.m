//
//  CTKCryptUtil.m
//  TouchPalDialer
//
//  Created by Almark M on 15/9/8.
//
//

#import "CTKAESCryptor.h"
#import <Usage_iOS/GTMBase64.h>


const NSUInteger kPBKDFRound    = 10000;  // hash rounds
const NSUInteger kPBKDFSaltSize = 8;      // the recommended least size

NSString * const CTKCryptErrorDomain = @"com.cootek.smartdialer.ctkcryptutil";


@implementation CTKAESCryptor

/* AES encryption & decryption */
+ (NSData *)randomDataWithLength:(size_t)length
{
    NSMutableData *data = [NSMutableData dataWithLength:length];
    int result = SecRandomCopyBytes(kSecRandomDefault, length, data.mutableBytes);
    NSAssert(result == 0, @"failed to generate random data: %d", errno);  // this should never be happened
    return data;
}

+ (NSData *)AESKeyForPassword:(NSString *)password
                         salt:(NSData *)salt
                       length:(size_t)length
{
    NSMutableData *key = [NSMutableData dataWithLength:length];
    int result = CCKeyDerivationPBKDF(kCCPBKDF2,
                                      password.UTF8String,
                                      password.length,
                                      salt.bytes,
                                      salt.length,
                                      kCCPRFHmacAlgSHA1,
                                      kPBKDFRound,
                                      key.mutableBytes,
                                      key.length);
    NSAssert(result == kCCSuccess,
             @"failed to create AES key: %d", result);
    return key;
}

+ (NSData *)doEncryptAES128ECBWithData:(NSData *)data
                                   key:(NSData *)key
                                 error:(NSError **)error
{
    size_t length;
    NSMutableData * encryptedData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    CCCryptorStatus result = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                                     key.bytes,
                                     key.length,
                                     nil,  // no iv for ECB
                                     data.bytes,
                                     data.length,
                                     encryptedData.mutableBytes,
                                     encryptedData.length,
                                     &length);
    
    if (result == kCCSuccess) {
        encryptedData.length = length;
    } else {
        if (error) {
            *error = [NSError errorWithDomain:CTKCryptErrorDomain
                                         code:result
                                     userInfo:nil];
        }
        return nil;
    }
    
    return encryptedData;
}

+ (NSData *)doDecryptAES128ECBWithData:(NSData *)data
                                   key:(NSData *)key
                                 error:(NSError **)error
{
    size_t length;
    NSMutableData *decryptedData = [NSMutableData dataWithLength:data.length];
    CCCryptorStatus result = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                                     key.bytes,
                                     key.length,
                                     nil,  // no iv for ECB
                                     data.bytes,
                                     data.length,
                                     decryptedData.mutableBytes,
                                     decryptedData.length,
                                     &length);
    
    if (result == kCCSuccess) {
        decryptedData.length = length;
    } else {
        if (error) {
            *error = [NSError errorWithDomain:CTKCryptErrorDomain
                                         code:result
                                     userInfo:nil];
        }
        return nil;
    }
    
    return decryptedData;
}

+ (NSData *)encryptAES128ECBWithData:(NSData *)data
                            password:(NSString *)password
                                salt:(NSData **)salt
                               error:(NSError **)error
{
    NSAssert(salt, @"salt must not be null");
    *salt = [self randomDataWithLength:kPBKDFSaltSize];
    NSData *key = [self AESKeyForPassword:password salt:*salt length:kCCKeySizeAES128];
    
    return [self doEncryptAES128ECBWithData:data key:key error:error];
}

+ (NSData *)decryptAES128ECBWithData:(NSData *)data
                            password:(NSString *)password
                                salt:(NSData *)salt
                               error:(NSError **)error
{
    NSData *key = [self AESKeyForPassword:password salt:salt length:kCCKeySizeAES128];
    return [self doDecryptAES128ECBWithData:data key:key error:error];
}

+ (NSData *)encryptAES128ECBWithData:(NSData *)data
                           randomKey:(NSData **)randomKey
                               error:(NSError **)error
{
    NSAssert(randomKey, @"key must not be null");
    *randomKey = [self randomDataWithLength:kCCKeySizeAES128];
    return [self doEncryptAES128ECBWithData:data key:*randomKey error:error];
}

+ (NSData *)decryptAES128ECBWithData:(NSData *)data
                                 key:(NSData *)key
                               error:(NSError **)error
{
    return [self doDecryptAES128ECBWithData:data key:key error:error];
}


@end


@implementation CTKAESCryptBot
{
    NSData *key;
    CTKRSACryptor *rsa;
}

- (id)initWithRandomKey
{
    self = [super init];
    if (self) {
        key = [CTKAESCryptor randomDataWithLength:kCCKeySizeAES128];
        rsa = [CTKRSACryptor sharedInstance];
    }
    return self;
}

- (id)initWithPassword:(NSString *)password
{
    self = [super init];
    if (self) {
        NSData *salt = [CTKAESCryptor randomDataWithLength:kPBKDFSaltSize];
        key = [CTKAESCryptor AESKeyForPassword:password salt:salt length:kCCKeySizeAES128];
        rsa = [CTKRSACryptor sharedInstance];
    }
    return self;
}

- (NSData *)aes128ECBEncryptWithData:(NSData *)data
{
    return [CTKAESCryptor doEncryptAES128ECBWithData:data key:data error:nil];
}

- (NSData *)aes128ECBDecryptWithData:(NSData *)data
{
    return [CTKAESCryptor doDecryptAES128ECBWithData:data key:key error:nil];
}

- (NSString *)aes128ECBEncryptGTMBase64String:(NSString *)data
{
    NSData *result = [CTKAESCryptor doEncryptAES128ECBWithData:[data dataUsingEncoding:NSUTF8StringEncoding]
                                                           key:key
                                                         error:nil];
    if (result) {
        return [GTMBase64 stringByWebSafeEncodingData:result padded:YES];
    }
    return nil;
}

- (NSString *)aes128ECBDecryptGTMBase64String:(NSString *)data
{
    NSData *result = [CTKAESCryptor doDecryptAES128ECBWithData:[GTMBase64 webSafeDecodeString:data]
                                                           key:key
                                                         error:nil];
    if (result) {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSData *)rsaPublicKeyNonePaddingEncryptWithData:(NSData *)data
{
    return [rsa rsaPublicKeyEncryptData:data padding:kSecPaddingNone];
}

- (NSString *)rsaPublicKeyNonePaddingEncryptGTMBase64String:(NSString *)data
{
    NSData *result = [rsa rsaPublicKeyEncryptData:[data dataUsingEncoding:NSUTF8StringEncoding] padding:kSecPaddingNone];
    return [GTMBase64 stringByWebSafeEncodingData:result padded:YES];
}

- (NSString *)getEncryptedAESKey
{
    NSData *result = [self rsaPublicKeyNonePaddingEncryptWithData:key];
    if (result) {
        return [GTMBase64 stringByWebSafeEncodingData:result padded:YES];
    }
    return nil;
}
@end

