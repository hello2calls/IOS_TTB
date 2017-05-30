//
//  NewFeatureGuideManager.h
//  TouchPalDialer
//
//  Created by ALEX on 16/9/12.
//
//

#import <Foundation/Foundation.h>

@interface NewFeatureGuideManager : NSObject

+ (instancetype)sharedManager;

- (void)checkNewFeatureGuide;
@end
