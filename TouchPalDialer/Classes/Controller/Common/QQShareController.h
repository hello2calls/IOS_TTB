//
//  QQShareController.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/27.
//
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "TPWebShareController.h"

@interface QQShareController : NSObject
+(instancetype)instance;
-(void)registerQQApi;
-(BOOL)handleOpenURL:(NSURL *)url;
-(void)shareQQMessage:(NSString *)title
       andDescription:(NSString *)description
               andUrl:(NSString *)url
          andImageUrl:(NSString *)imageUrl
          andIfQQZone:(BOOL)ifQQZone
             andBlock:(void(^)(void))block;

-(void)shareQQMessage:(NSString *)title
       andDescription:(NSString *)description
               andUrl:(NSString *)url
          andImageUrl:(NSString *)imageUrl
          andIfQQZone:(BOOL)ifQQZone
       resultCallback:(ShareResultCallback)block;

- (void)setAfterSuccessNil;

@end
