//
//  FeedsSiginManager.h
//  TouchPalDialer
//
//  Created by lin tang on 16/10/17.
//
//

#import <Foundation/Foundation.h>

@interface FeedsSigninManager : NSObject

+ (BOOL) shouldShowSignin;
+ (void) updateSignTime;
+ (void) showSigninGuideDialog:(UIView *) rootView;


@end
