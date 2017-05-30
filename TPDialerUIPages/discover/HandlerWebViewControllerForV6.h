//
//  HandlerWebViewControllerForV6.h
//  TouchPalDialer
//
//  Created by weyl on 16/10/11.
//
//

#import "HandlerWebViewController.h"
#import "YellowPageWebViewController.h"
#import "MJRefreshHeader.h"

@interface HandlerWebViewControllerForV6 : YellowPageWebViewController
@property(strong) MJRefreshHeader* mj_header;
@end
