//
//  EncodeUtil.m
//  Usage_iOS
//
//  Created by SongchaoYuan on 16/1/26.
//  Copyright © 2016年 Cootek. All rights reserved.
//

#import "EncodeUtil.h"
#import "GTMBase64.h"
#import <openssl/pem.h>
#import <openssl/rsa.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "NSData+Encryption.h"
#import <UIKit/UIKit.h>
#import <AFNetworkOperation/AFGZipUtils.h>

//公钥不能修改
#define kUsagePublicKey "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA20+Yife/IVl+wfWptGEK\nOzAekD1OWM5rbF8WdDohHznBZPgrXS0mCnSA7Lg1Qs/R470y8IYeFtql6gU2HPi1\naBDxDdbYGeJj8qA5VQD9KIsLijY1qmAXnhJKna88Eqoy9AJF8cC7qocTcZ5pyz64\nx3QFl8QNGbrjEKrjJR05i4lm5eECzGgqaQ/z2hEbGEChFR/dJtOXV2sSue8x+ZFi\n+UHCuCoHd2/4SOytSBipavSyB1Pt9a0RBOaz2627uuKSQrSpUXa8DFZDNUKIeiXo\nKYoGwaICVSRcexKoBLPUjcXRQHVKjTYo7GSmQsSNORq2taoLiN4o3ee9MkPpnLUW\nuwIDAQAB\n-----END PUBLIC KEY-----\n"

@implementation EncodeUtil

+ (NSString *)encryptRSA:(NSData *)key {

    //密文
    unsigned char encrypted[256];
    bzero(encrypted, sizeof(encrypted));
    
    BIO *bio = NULL;
    RSA *rsa = NULL;
    
    bio = BIO_new_mem_buf(kUsagePublicKey, -1);
    if (bio == NULL){
        //从字符串读取RSA公钥
        #ifdef DEBUG
        printf("Pub_Key Read Failure!!\n");
        #endif
    }
    rsa = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
    if (!rsa){
        //从bio结构中得到Rsa结构
        #ifdef DEBUG
        printf("Pub_Key Read Failure!!\n");
        #endif
    }
    
    
    int contentLen = [key length];
    unsigned char from[contentLen];
    bzero(from, sizeof(from));
    memcpy(from, [key bytes], contentLen);
    
    // 用公钥加密
    int state = RSA_public_encrypt (contentLen, from, encrypted, rsa, RSA_PKCS1_PADDING);
    if( state == -1 ){
        #ifdef DEBUG
        printf("Encrypt Failed!!\n");
        #endif
    }
    
    NSData *returnData = [NSData dataWithBytes:encrypted length:state];
    NSString *base64String = [[NSString alloc] initWithData:[GTMBase64 webSafeEncodeData:returnData padded:YES] encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSString *)encryptAESWithData:(NSData *)data andKey:(NSData *)key {
    NSData *compressedData = [data gzipDeflate];
    NSString *base64String = [[NSString alloc] initWithData:[GTMBase64 webSafeEncodeData:[compressedData AES256EncryptWithKey:key] padded:YES] encoding:NSUTF8StringEncoding];
    return base64String;
}

+ (NSData *)generateKey {
    return [self getSHA256String:[self getUUID]];
}

+ (NSData *)getSHA256String:(NSString *)srcString {
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, data.length, digest);
    NSData *contentData = [[NSData alloc] initWithBytes:(const void *)digest length:sizeof(digest)];
    return contentData;
}

+ (NSString *)getUUID {
    UIDevice *device = [UIDevice currentDevice];
    NSUUID *uuid = [device identifierForVendor];
    return [uuid UUIDString];
}

@end
