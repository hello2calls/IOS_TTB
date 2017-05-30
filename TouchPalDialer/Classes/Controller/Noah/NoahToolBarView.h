//
//  NoahToolBarView.h
//  TouchPalDialer
//
//  Created by game3108 on 14-12-18.
//
//

#import <UIKit/UIKit.h>
#import "NoahManager.h"

#define VOIP_GUIDE_URL_PATH @"cootek-dialer-download.oss.aliyuncs.com/web/dialer/free_call_guide/index.html"

@protocol NoahToolBarViewDelegate <NSObject>
- (void) closeNoahToolBar;
@end

@interface NoahToolBarView : UIView
@property (nonatomic,assign) id<NoahToolBarViewDelegate> delegate;
@property (nonatomic,assign)NSInteger priority;
- (instancetype)initWithFrame:(CGRect)frame andToolbarToast:(ToolbarToast*) toolbarToast andDelegate:(id<NoahToolBarViewDelegate>) delegate;
- (instancetype)initWithFrame:(CGRect)frame andLocaMessage:(NSDictionary *)mesDic andDelegate:(id<NoahToolBarViewDelegate>) delegate;

@end
