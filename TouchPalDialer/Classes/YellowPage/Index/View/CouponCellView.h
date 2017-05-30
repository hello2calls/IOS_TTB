//
//  CouponCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-8-19.
//
//

#import <UIKit/UIKit.h>
#import "YPUIView.h"
#import "CouponItem.h"
#import "VerticallyAlignedLabel.h"
#import "UILabelStrikeThrough.h"

@interface CouponCellView : YPUIView

@property(nonatomic, retain) VerticallyAlignedLabel* title;
@property(nonatomic, retain) VerticallyAlignedLabel* distance;
@property(nonatomic, retain) VerticallyAlignedLabel* content;
@property(nonatomic, retain) VerticallyAlignedLabel* currentPrice;
@property(nonatomic, retain) UILabelStrikeThrough* oldPrice;
@property(nonatomic, retain) VerticallyAlignedLabel* join;
@property(nonatomic, retain) UIImage* couponIcon;

- (id) initWithFrame:(CGRect)frame andCouponItem:(CouponItem*) couponItem;
- (void) resetWithCouponData:(CouponItem*)couponData andRect:(CGRect)rect;
@end
