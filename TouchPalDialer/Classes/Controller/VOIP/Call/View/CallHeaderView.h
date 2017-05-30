//
//  CallHeaderDisplay.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/16.
//
//

#import <Foundation/Foundation.h>

@interface CallHeaderView : UIView
@property (nonatomic,assign) BOOL hiddenHeaderView;

- (void)showFreeGoingOut;

- (void)showNeedCellularData;

- (void)showRoamingFee;

- (void)hide;

- (void)showNetworkNotStable;

- (void)chekToShowNumberHideWarning;

- (void)displayNext;

- (void)clearDisplay;
@end
