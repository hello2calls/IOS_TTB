//
//  NSString+MD5.m
//  TouchPalDialer
//
//  Created by Scyuan on 14-8-28.
//
//
#import <CommonCrypto/CommonDigest.h>
#import "NSString+MD5.h"
#import <Usage_iOS/GTMBase64.h>

@implementation NSString (MD5)
- (NSString *) MD5Hash {
	CC_MD5_CTX md5;
	CC_MD5_Init(&md5);
	CC_MD5_Update(&md5, [self UTF8String], [self length]);
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final(digest, &md5);
    
	NSString *md5String = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
	                       digest[0],  digest[1],
	                       digest[2],  digest[3],
	                       digest[4],  digest[5],
	                       digest[6],  digest[7],
	                       digest[8],  digest[9],
	                       digest[10], digest[11],
	                       digest[12], digest[13],
	                       digest[14], digest[15]];
    
	return md5String;
}

- (NSString *) md5_base64
{
    const char *cStr = [self UTF8String];
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, strlen(cStr), digest );

    NSData * base64 = [[NSData alloc]initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    
    base64 = [GTMBase64 encodeData:base64];

    NSString * output = [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
    
    output = [output stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    output = [output stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    
    return output;
    
}

@end
