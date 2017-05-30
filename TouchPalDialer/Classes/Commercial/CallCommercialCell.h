//
//  CallCommercialCell.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/12.
//
//

#import <UIKit/UIKit.h>
#import "CallCommercialModel.h"
#import "Ad.pb.h"

@interface CallCommercialCell : UIView

- (id)initWithFrame:(CGRect)frame andModel:(udp_response_tData *)model;

@property(nonatomic, copy)void(^onClick)(void);

@end
