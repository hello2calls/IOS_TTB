//
//  PreShareViewController.m
//  TouchPalDialer
//
//  Created by junhzhan on 8/21/15.
//
//

#import "PreShareFactory.h"
#import "PreShareVersion0View.h"
#import "PreShareVersion1View.h"
#import "TouchLifeShareMgr.h"

@interface PreShareFactory()
@end

@implementation PreShareFactory

+ (PreShareView *)showPreShareView:(ShareData*)shareData inParent:(UIView*)container {
    NSInteger uiVersion = [shareData.uiVersion integerValue];
    PreShareView *root;
    switch (uiVersion) {
        case 0:
            root = [[PreShareVersion0View alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height) andShareData:shareData];
            break;
        default:
            root = [[PreShareVersion1View alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height) andShareData:shareData];
            break;
    }
    
    [container addSubview:root];
    return root;
}


@end
