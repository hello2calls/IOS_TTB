//
//  RDVTabBarController+TPDExtension.h
//  TouchPalDialer
//
//  Created by weyl on 16/11/11.
//
//

#import <RDVTabBarController/RDVTabBarController.h>

@interface RDVTabBarController (TPDExtension)
-(UIButton*)customizeOverlayTabBarItemAtIndex:(NSInteger)index whenClick:(void (^)(id sender))block;
@end
