//
//  LongGestureOperationView.h
//
//  Created by Liangxiu on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"
#import "TPUIButton.h"
#import "LongGestureController.h"
#import "OperationCommandBase.h"
#import "CooTekPopUpSheet.h"

#define N_REFRESH_TABLE_VIEW @"N_REFRESH_TABLE_VIEW"
#define N_MULTI_SELECT_ENTERED @"N_MULTI_SELECT_ENTERED"
#define N_MULTI_SELECT_EXIT  @"N_MULTI_SELECT_EXIT"
#define N_REMOVE_CALLS_IN_DIALER_VIEW @"N_REMOVE_CALLS_IN_DIALER_VIEW"

@interface LongGestureOperationView : UIView <UIScrollViewDelegate, OperationCommandDelegate>
@property(nonatomic,assign) id<LongGestureStatusChangeDelegate> delegate;
@property(nonatomic,retain) UINavigationController *rootViewController;
@property(nonatomic,assign) LongGestureSupportedType supportedType;
@property(nonatomic,retain) UIView *bottomView; // the view matching the cell; against the top triangle view
@property (nonatomic, assign) BOOL shouldTriangleInMiddle;
- (UIView *)initWithTableName:(NSString *)tableName frame:(CGRect)frame;

- (void)onLongGesturePressed;
- (void)loadOperationForData:(id)data forColorfulCell:(BOOL)color;
- (void)removeLongGestureOperationView;

+ (NSArray *)commandsForData:(id)data withLongGestureSupportedType:(LongGestureSupportedType)supportedType;
+ (NSArray *)excutablePopupCommandsForData:(id)data withLongGestureSupportedType:(LongGestureSupportedType)supportedType;
@end
