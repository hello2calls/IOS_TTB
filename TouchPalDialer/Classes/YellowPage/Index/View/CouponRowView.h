//
//  CouponRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#ifndef TouchPalDialer_CouponRowView_h
#define TouchPalDialer_CouponRowView_h
#import "SectionCoupon.h"
#import "YPUIView.h"
#import "VerticallyAlignedLabel.h"
#import "UILabelStrikeThrough.h"
#import "CouponItem.h"

@interface CouponRowView:YPUIView

@property(nonatomic, retain) SectionCoupon* couponSection;
@property(nonatomic, retain) NSIndexPath* rowIndexPath;
@property(nonatomic, assign) NSInteger index;

- (id)initWithFrame:(CGRect)frame andData:(SectionCoupon*)data andIndexPath:(NSIndexPath*)indexPath;

- (void) resetDataWithCouponItem:(SectionCoupon*)item andIndexPath:(NSIndexPath*)indexPath;

+(int) getRowHeight:(SectionCoupon *)item;
@end
#endif
