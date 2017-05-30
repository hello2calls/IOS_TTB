//
//  NoahMananger.h
//  TouchPalDialer
//
//  Created by game3108 on 14-12-16.
//
//

#import <Foundation/Foundation.h>
#import <Ararat_iOS/Ararat_iOS.h>


@interface NoahManager : NSObject
@property (nonatomic,retain) NSMutableDictionary *actionConformDic;
+ (instancetype)sharedInstance;
+ (id)sharedPSInstance;
+ (BOOL)isReady;
- (void)initNoah:(BOOL) newUpdate;
- (void)onAppEnterBackground;
- (NSString *)storagePath;

- (BOOL) openUrl:(NSString *) url WebTitle:(NSString *)webTitle RequestToken:(BOOL)requestToken;
- (BOOL)lauchLocalController:(NSString *)controllerName;
@end