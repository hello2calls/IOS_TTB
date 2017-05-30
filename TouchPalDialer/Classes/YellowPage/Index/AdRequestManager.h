//
//  AdRequestManager.h
//  TouchPalDialer
//
//  Created by tanglin on 16/5/26.
//
//

#import <Foundation/Foundation.h>

@interface AdRequestManager<BaiduMobAdNativeAdDelegate> : NSObject

- (void) generateTasksWithTu:(NSInteger)tu withBlock:(void (^)(NSMutableArray *))block isRefresh:(BOOL) refresh;
- (void) registerController:(UIViewController *)controller;


@property(nonatomic, strong, setter=setQueryId:)NSString* queryId;

@end
