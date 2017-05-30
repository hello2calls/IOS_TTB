//
//  AntiharassStepView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import <UIKit/UIKit.h>
#import "TPDialerResourceManager.h"
#import "TPButton.h"
#import "AntiharassUtil.h"
#import "DialerUsageRecord.h"

@protocol AntiharassStepViewDelegate <NSObject>
- (void)clickSureButton;
- (void)clickCancelButton;
- (void)clickTapButton;
@end

@interface AntiharassStepView : UIView
@property (nonatomic,assign) id<AntiharassStepViewDelegate> delegate;
@end
