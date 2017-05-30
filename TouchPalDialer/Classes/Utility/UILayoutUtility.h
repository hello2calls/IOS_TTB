//
//  UILayoutUtility.h
//  TouchPalDialer
//
//  Created by Chen Lu on 9/17/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#define TAB_BAR_HEIGHT 50
#define IPHONE_5_WIDTH_POINTS (320.0f)
#define IPHONE_5_HEIGHT_POINTS (568.0f)
#define CT_RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

CGFloat TPStatusBarHeight(void);

CGFloat TPHeaderBarHeight(void);

CGFloat TPHeaderBarHeightDiff(void);

CGFloat TPScreenHeight(void);

CGFloat TPAppFrameHeight(void);

CGFloat TPScreenWidth(void);

CGFloat TPHeightOrYFitIPhone5(CGFloat height);

CGFloat TPHeightBetweenIP4AndIP5(void);

CGFloat TPHeightFit(CGFloat height);

CGFloat TPKeypadHeight(void);

CGFloat TPScaledWidth(CGFloat originalWidth);
CGFloat TPScaledHeight(CGFloat originalHeight);

CGSize TPScaledSizeMake(CGFloat originalWidth, CGFloat originalHeight);
CGSize TPScaledSize(CGSize originaSize);

BOOL isIPhone5Resolution(void);
BOOL isIPhone6Resolution(void);
