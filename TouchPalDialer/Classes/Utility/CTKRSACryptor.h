//
//  CTKRSACryptor.h
//  TouchPalDialer
//
//  Created by Almark M on 15/9/9.
//
//

#import <Foundation/Foundation.h>

@interface CTKRSACryptor : NSObject

- (void)loadPublicKeyFromData:(NSData*)derData;
- (void)loadPublicKeyFromResource:(NSString*)derFileName;

- (void)loadPrivateKeyFromData:(NSData*)p12Data password:(NSString*)p12Password;
- (void)loadPrivateKeyFromResource:(NSString*)p12FileName password:(NSString*)p12Password;

/* padding is one of the values of [kSecPaddingNone, kSecPaddingPKCS1] */
- (NSData*)rsaPublicKeyEncryptData:(NSData*)data padding:(SecPadding)padding;
- (NSData*)rsaPrivateKeyDecryptData:(NSData*)data padding:(SecPadding)padding;


+ (CTKRSACryptor*)sharedInstance;

@end
