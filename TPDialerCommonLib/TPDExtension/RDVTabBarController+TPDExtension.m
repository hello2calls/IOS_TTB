//
//  RDVTabBarController+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/11.
//
//

#import "RDVTabBarController+TPDExtension.h"
#import <RDVTabBarController.h>
#import <RDVTabBar.h>
#import <RDVTabBarItem.h>
#import "TPDLib.h"
#import <Masonry.h>

@implementation RDVTabBarController (TPDExtension)
-(UIButton*)customizeOverlayTabBarItemAtIndex:(NSInteger)index whenClick:(void (^)(id sender))block{
    
    UIButton* ret = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        if (block) {
            EXEC_BLOCK(block, sender);
        }
    }];
    RDVTabBarItem* coverItem = self.tabBar.items[index];
    
    [coverItem addSubview:ret];
    [ret remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(coverItem);
    }];
    
    return ret;
}
@end
