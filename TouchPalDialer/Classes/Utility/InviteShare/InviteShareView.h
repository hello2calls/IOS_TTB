//
//  InviteShareView.h
//  TouchPalDialer
//
//  Created by game3108 on 16/3/8.
//
//

#import <UIKit/UIKit.h>
#import "InviteShareData.h"

@interface InviteShareView : UIView
@property(nonatomic, copy)void(^cancelBlock)(void);
@property(nonatomic, copy)void(^leftBlock)(void);
@property(nonatomic, copy)void(^rightBlock)(void);
- (instancetype)initWithFrame:(CGRect)frame andInviteShareData:(InviteShareData *)shareData;
@end
