//
//  ChargeViewController.h
//  TouchPalDialer
//
//  Created by by.huang on 2017/5/26.
//
//

#import <UIKit/UIKit.h>
#import "CootekWebViewController.h"
#import "CootekWebHandler.h"
#import "WebViewControllerDelegate.h"

@interface ChargeViewController : CootekWebViewController

@property(nonatomic, strong) CootekWebHandler* webviewHandler;

@property(nonatomic, weak)   id<WebViewControllerDelegate> controllerDelegate;


@end
