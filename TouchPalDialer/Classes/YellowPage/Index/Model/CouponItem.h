//
//  CouponItem.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#ifndef TouchPalDialer_CouponItem_h
#define TouchPalDialer_CouponItem_h

#import "BaseItem.h"

@class CTUrl;
@class IndexFilter;

@interface CouponItem : BaseItem

@property(nonatomic,retain) NSString* price;
@property(nonatomic,retain) NSString* priceSale;
@property(nonatomic,retain) NSString* distance;
@property(nonatomic,retain) NSString* join;
@property(nonatomic,retain) NSString* discount;
@property(nonatomic,retain) NSArray* propertyList;

@end
#endif
