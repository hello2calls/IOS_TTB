//
//  BiBiPairManager.h
//  TouchPalDialer
//
//  Created by lingmeixie on 17/1/10.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BiBiPairManager : NSObject

+ (BiBiPairManager *)manager;

- (BOOL)canBibiCall:(NSString *)number;

- (void)asycBiBiPair;

- (NSString *)recommendNumber;

- (UIImage *)defualtBibiPhoto;

- (void)pushBibiWebController:(UINavigationController *)nav;

- (BOOL)canShowBibiGuide;

@end
