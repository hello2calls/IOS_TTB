//
//  ContactTransferGuidePageView.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/15.
//
//

#ifndef ContactTransferGuidePageView_h
#define ContactTransferGuidePageView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactTransferPageInfo.h"

#define PAGE_MARGIN_TOP (0.14)
#define PAGE_MARGIN_TOP_SMALL (0.14)

#define PAGE_MARGIN_BOTTOM (0.14)
#define PAGE_MARGIN_BOTTOM_SMALL (0.10)

@interface ContactTransferGuidePageView : UIView

- (instancetype) initWithFrame:(CGRect)frame PageInfo: (ContactTransferPageInfo *) pageInfo;
- (instancetype) initWithPageInfo:(ContactTransferPageInfo *) pageInfo;

@property (nonatomic) ContactTransferPageInfo *pageInfo;
@property (nonatomic) UIButton *button;

@end

#endif /* ContactTransferGuidePageView_h */
