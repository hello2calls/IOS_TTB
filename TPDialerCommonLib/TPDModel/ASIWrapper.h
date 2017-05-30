//
//  ASIWrapper.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/14.
//
//

#import <Foundation/Foundation.h>


@interface ASIWrapper : NSObject

// 服务器返回的完整二进制数据
@property (nonatomic,strong) NSString* cache;

// 二进制数据（适用于文件下载）
@property (nonatomic,strong) NSData* binary;

// url
@property (nonatomic,strong) NSString* pathStr;

// 字典形式的请求参数
@property (nonatomic,strong) NSDictionary* params;

// GET或POST。使用者不要设定
@property (nonatomic,strong) NSString* method;

// 请求出错提示信息。可能是后台返回的，也可能是在无网络时我们自定义的。外部只管用
@property (nonatomic,strong) NSString* errInfo;

// 请求的缓存时间
@property (nonatomic) NSInteger cacheTimeInSecond;

// 请求结果成功与否
@property (nonatomic) BOOL success;

// 请求返回数据中对应于responseStructKey的结构。一般为字典或数组
@property (nonatomic, strong) id responseStruct;

@property (nonatomic, copy) NSString* responseStructKey;

// 成功时，区别数据的来源是否从cache拿到
@property (nonatomic, assign) BOOL isDataFromCache;

// post请求时，如果要传二进制数据，如文件，设为yes
@property (nonatomic) BOOL obligeUsingMultiform;

+(ASIWrapper*)defaultWrapperObject;

+(void)getRequest:(ASIWrapper*)wrapper;

+(void)postRequest:(ASIWrapper*)wrapper;

+(NSData*)downloadFile:(NSString*)url;

- (ASIWrapper *)refresh;

+ (NSString *) createParamString:(NSDictionary*)params;


#pragma mark 特殊用途的请求（第三方等等）
+(ASIWrapper*)nameCardPost:(NSData*)fileContent;


+ (NSString *)getIPAddress:(BOOL)preferIPv4;
@end



