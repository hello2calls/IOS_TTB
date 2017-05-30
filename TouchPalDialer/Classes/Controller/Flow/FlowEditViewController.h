//
//  FlowEditViewController.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/22.
//
//

#import <UIKit/UIKit.h>
#import "FlowExchangeView.h"

@interface FlowEditViewController : UIViewController
@property (nonatomic,assign) FlowExchangeView *exchangeView;
- (void)refreshHeaderButton;
- (void)refreshController;
@end
