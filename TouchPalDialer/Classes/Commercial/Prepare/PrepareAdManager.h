//
//  PrepareAdManager.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/9/9.
//
//

#import <Foundation/Foundation.h>
#import "PrepareAdModel.h"

@interface PrepareAdManager : NSObject

+ (PrepareAdManager *)instance;

- (PrepareAdItem *)getPrepareAdItem:(NSString *)tu;

- (void)didShowPrepareAd:(NSString *)tu;

@end
