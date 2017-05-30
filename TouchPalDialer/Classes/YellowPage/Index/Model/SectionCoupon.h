//
//  SectionCoupon.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#ifndef TouchPalDialer_SectionCoupon_h
#define TouchPalDialer_SectionCoupon_h
#import "SectionBase.h"
#import "CouponItem.h"

@interface SectionCoupon : SectionBase

@property(nonatomic, retain) CouponItem* coupon;
@property(nonatomic, retain) NSString* queryId;
@property(nonatomic, retain) NSString* title;
@property(nonatomic, assign) BOOL isFirst;

- (id) initWithJson: (NSDictionary*) json;

@end

#endif
