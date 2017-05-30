//
//  CTKRSACryptor.m
//  TouchPalDialer
//
//  Created by Almark M on 15/9/9.
//
//

#import "CTKRSACryptor.h"

@implementation CTKRSACryptor
{
    SecKeyRef publicKey;
    SecKeyRef privateKey;
}

- (void)dealloc
{
    if (publicKey != NULL) {
        CFRelease(publicKey);
    }
    if (privateKey != NULL) {
        CFRelease(privateKey);
    }
}

- (void)loadPublicKeyFromData:(NSData*)derData
{
    SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)derData);
    if (cert == NULL) {
        cootek_log(@"cannot read certificate");
        return;
    }
    
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust;
    OSStatus status = SecTrustCreateWithCertificates(cert, policy, &trust);
    if (status != 0) {
        cootek_log(@"SecTrustCreateWithCertificates failed with error code: %ld", (long) status);
        return;
    }
    
    SecTrustResultType resultResultType;
    status = SecTrustEvaluate(trust, &resultResultType);
    if (status != 0) {
        cootek_log(@"SecTrustEvaluate failed with error code: %ld", (long) status);
        return;
    }
    
    publicKey = SecTrustCopyPublicKey(trust);
    if (publicKey == NULL) {
        cootek_log(@"SecTrustCopyPublicKey failed with error code: %ld", (long) status);
        return;
    }
    
    CFRelease(cert);
    CFRelease(policy);
    CFRelease(trust);
}

- (void)loadPublicKeyFromResource:(NSString*)derFileName
{
    NSString *suffix = @"der";
    if ([derFileName hasSuffix:@".der"]) {
        suffix = nil;
    }
    NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:derFileName ofType:suffix];
    if (publicKeyPath == nil) {
        cootek_log(@"not found given DER public key file: %@", derFileName);
        return;
    }
    [self loadPublicKeyFromData:[NSData dataWithContentsOfFile:publicKeyPath]];
}

- (void)loadPrivateKeyFromData:(NSData*)p12Data password:(NSString*)p12Password
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:p12Password forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus status = SecPKCS12Import((__bridge CFDataRef)p12Data,
                                      (__bridge CFDictionaryRef)options,
                                      &items);
    if (status == noErr && CFArrayGetCount(items) > 0) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp = (SecIdentityRef) CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        status = SecIdentityCopyPrivateKey(identityApp, &privateKey);
        if (status != noErr) {
            privateKey = NULL;
        }
    }
    
    CFRelease(items);
}

- (void)loadPrivateKeyFromResource:(NSString*)p12FileName password:(NSString*)p12Password
{
    NSString *suffix = @"p12";
    if ([p12FileName hasSuffix:@".p12"]) {
        suffix = nil;
    }
    NSString *privateKeyPath = [[NSBundle mainBundle] pathForResource:p12FileName ofType:suffix];
    if (privateKeyPath == nil) {
        cootek_log(@"not found given p12 private key file: %@", p12FileName);
        return;
    }
    [self loadPrivateKeyFromData:[NSData dataWithContentsOfFile:privateKeyPath] password:p12Password];
}

- (NSData*)rsaPublicKeyEncryptData:(NSData*)data padding:(SecPadding)padding
{
    if (publicKey == NULL) {
        cootek_log(@"cannot do encryption since public key has not been loaded.");
        return nil;
    }
    if (padding != kSecPaddingNone && padding != kSecPaddingPKCS1) {
        cootek_log(@"unsupportted padding option %d", padding);
        return nil;
    }

    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    size_t encrpytBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *encryptBuffer = malloc(encrpytBufferSize * sizeof(uint8_t));
    
    size_t offset = 0;  // kSecPaddingNone
    if (padding == kSecPaddingPKCS1) {
        offset = 11;
    }
    size_t plainBlockSize = encrpytBufferSize - offset;
    size_t blockCount = (size_t) ceil([data length] / (double) plainBlockSize);
    

    for (int i = 0; i < blockCount; ++i) {
        NSUInteger bufferSize = MIN(plainBlockSize, [data length] - i * plainBlockSize);
        NSData *buffer = [data subdataWithRange:NSMakeRange(i * plainBlockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        padding,
                                        (const uint8_t *) [buffer bytes],
                                        [buffer length],
                                        encryptBuffer,
                                        &encrpytBufferSize);
        if (status == noErr) {
            NSData *encrypted = [NSData dataWithBytes:(const void *) encryptBuffer length:encrpytBufferSize];
            [encryptedData appendData:encrypted];
        } else {
            cootek_log(@"error in encrypting the data with code %d", status);
            if (encryptBuffer) {
                free(encryptBuffer);
            }
            return nil;
        }
    }
    
    if (encryptBuffer) {
        free(encryptBuffer);
    }
    return  encryptedData;
}

- (NSData*)rsaPrivateKeyDecryptData:(NSData*)data padding:(SecPadding)padding
{
    if (privateKey == NULL) {
        cootek_log(@"cannot do decryption since private key has not been loaded.");
        return nil;
    }
    if (padding != kSecPaddingNone && padding != kSecPaddingPKCS1) {
        cootek_log(@"unsupportted padding option %d", padding);
        return nil;
    }
    
    NSMutableData *decryptedData = [[NSMutableData alloc] init];
    size_t decrpytBufferSize = SecKeyGetBlockSize(privateKey);
    uint8_t *decryptBuffer = malloc(decrpytBufferSize * sizeof(uint8_t));
    size_t blockCount = (size_t) ceil([data length] / (double) decrpytBufferSize);
    
    size_t offset = 0;  // kSecPaddingNone
    if (padding == kSecPaddingPKCS1) {
        offset = 11;
    }
    size_t plainBlockSize = decrpytBufferSize - offset;

    for (int i = 0; i < blockCount; ++i) {
        NSUInteger bufferSize = MIN(decrpytBufferSize, [data length] - i * decrpytBufferSize);
        NSData *buffer = [data subdataWithRange:NSMakeRange(i * decrpytBufferSize, bufferSize)];
        OSStatus status = SecKeyDecrypt(privateKey,
                                        padding,
                                        (const uint8_t *) [buffer bytes],
                                        [buffer length],
                                        decryptBuffer,
                                        &plainBlockSize);
        if (status == noErr) {
            NSData *decrypted = [NSData dataWithBytes:(const void *) decryptBuffer length:plainBlockSize];
            [decryptedData appendData:decrypted];
        } else {
            cootek_log(@"error in decrypting the data with code %d", status);
            if (decryptBuffer) {
                free(decryptBuffer);
            }
            return nil;
        }
    }
    
    if (decryptBuffer) {
        free(decryptBuffer);
    }
    return  decryptedData;
}


+ (CTKRSACryptor*)sharedInstance
{
    static CTKRSACryptor *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
        [instance loadPublicKeyFromResource:@"online-public"];
    });
    
    return instance;
}

@end
