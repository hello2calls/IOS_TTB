//
//  CryptTest.m
//  TouchPalDialer
//
//  Created by Almark M on 15/9/15.
//
//

#import "CryptTest.h"
#import "CTKAESCryptor.h"
#import "CTKRSACryptor.h"
#import <Usage_iOS/GTMBase64.h>


@implementation CryptTest

- (void)testAESCryption
{
    NSString *shortString = @"Wenny is lovely";
    NSString *longString = @"Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely";
    
    
    NSString *password = @"WennyIsLovely";
    NSData *salt;
    NSError *error;
    NSData *key;
    
    
    // aes testing for short string
    NSData *aesEncrypted = [CTKAESCryptor encryptAES128ECBWithData:[shortString dataUsingEncoding:NSUTF8StringEncoding]
                                                          password:password
                                                              salt:&salt
                                                             error:&error];
    XCTAssertNotNil(aesEncrypted, @"aes encryption with password failed");
    
    NSData *aesDecrypted = [CTKAESCryptor decryptAES128ECBWithData:aesEncrypted
                                                          password:password
                                                              salt:salt
                                                             error:&error];
    XCTAssertEqualObjects(shortString,
                         [[NSString alloc] initWithData:aesDecrypted encoding:NSUTF8StringEncoding],
                         @"aes decryption with password failed");
    
    aesEncrypted = [CTKAESCryptor encryptAES128ECBWithData:[shortString dataUsingEncoding:NSUTF8StringEncoding]
                                                 randomKey:&key
                                                     error:&error];
    XCTAssertNotNil(aesEncrypted, @"aes encryption with random key failed");

    aesDecrypted = [CTKAESCryptor decryptAES128ECBWithData:aesEncrypted
                                                       key:key
                                                     error:&error];
    XCTAssertEqualObjects(shortString,
                         [[NSString alloc] initWithData:aesDecrypted encoding:NSUTF8StringEncoding],
                         @"aes decryption with random key failed");

    
    // aes testing for long string
    aesEncrypted = [CTKAESCryptor encryptAES128ECBWithData:[longString dataUsingEncoding:NSUTF8StringEncoding]
                                                  password:password
                                                      salt:&salt
                                                     error:&error];
    XCTAssertNotNil(aesEncrypted, @"aes encryption with password failed");

    aesDecrypted = [CTKAESCryptor decryptAES128ECBWithData:aesEncrypted
                                                  password:password
                                                      salt:salt
                                                     error:&error];
    XCTAssertEqualObjects(longString,
                         [[NSString alloc] initWithData:aesDecrypted encoding:NSUTF8StringEncoding],
                         @"aes decryption with password failed");
    
    aesEncrypted = [CTKAESCryptor encryptAES128ECBWithData:[longString dataUsingEncoding:NSUTF8StringEncoding]
                                                 randomKey:&key
                                                     error:&error];
    XCTAssertNotNil(aesEncrypted, @"aes encryption with random key failed");
    
    aesDecrypted = [CTKAESCryptor decryptAES128ECBWithData:aesEncrypted
                                                       key:key
                                                     error:&error];
    XCTAssertEqualObjects(longString,
                         [[NSString alloc] initWithData:aesDecrypted encoding:NSUTF8StringEncoding],
                         @"aes decryption with random key failed");


}

- (void)testRSACryption
{
    NSString *shortString = @"Wenny is lovely";
    NSString *longString = @"Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely Wenny is lovely";
    
    NSData *rsaEncrypted;
    NSData *rsaDecrypted;
    CTKRSACryptor *rsa = [CTKRSACryptor sharedInstance];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    [rsa loadPublicKeyFromData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"docker-public" ofType:@"der"]]];
    [rsa loadPrivateKeyFromData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"docker-private" ofType:@"p12"]] password:@""];
    
    // rsa testing for short string
    rsaEncrypted = [rsa rsaPublicKeyEncryptData:[shortString dataUsingEncoding:NSUTF8StringEncoding] padding:kSecPaddingNone];
    XCTAssertNotNil(rsaEncrypted, @"rsa encryption for short string failed");

    rsaDecrypted = [rsa rsaPrivateKeyDecryptData:rsaEncrypted padding:kSecPaddingNone];
    XCTAssertEqualObjects(shortString,
                         [[NSString alloc] initWithData:rsaDecrypted encoding:NSUTF8StringEncoding],
                         @"rsa decryption for short string failed");
    
    rsaEncrypted = [rsa rsaPublicKeyEncryptData:[shortString dataUsingEncoding:NSUTF8StringEncoding] padding:kSecPaddingPKCS1];
    XCTAssertNotNil(rsaEncrypted, @"rsa encryption for short string failed");
    
    rsaDecrypted = [rsa rsaPrivateKeyDecryptData:rsaEncrypted padding:kSecPaddingPKCS1];
    XCTAssertEqualObjects(shortString,
                         [[NSString alloc] initWithData:rsaDecrypted encoding:NSUTF8StringEncoding],
                         @"rsa decryption for short string failed");
    
    // rsa testing for long string
    rsaEncrypted = [rsa rsaPublicKeyEncryptData:[longString dataUsingEncoding:NSUTF8StringEncoding] padding:kSecPaddingNone];
    XCTAssertNotNil(rsaEncrypted, @"rsa encryption for long string failed");
    
    rsaDecrypted = [rsa rsaPrivateKeyDecryptData:rsaEncrypted padding:kSecPaddingNone];
    XCTAssertEqualObjects(longString,
                         [[NSString alloc] initWithData:rsaDecrypted encoding:NSUTF8StringEncoding],
                         @"rsa decryption for short long failed");
    
    rsaEncrypted = [rsa rsaPublicKeyEncryptData:[longString dataUsingEncoding:NSUTF8StringEncoding] padding:kSecPaddingPKCS1];
    XCTAssertNotNil(rsaEncrypted, @"rsa encryption for long string failed");
    
    rsaDecrypted = [rsa rsaPrivateKeyDecryptData:rsaEncrypted padding:kSecPaddingPKCS1];
    XCTAssertEqualObjects(longString,
                         [[NSString alloc] initWithData:rsaDecrypted encoding:NSUTF8StringEncoding],
                         @"rsa decryption for long string failed");
}

@end
