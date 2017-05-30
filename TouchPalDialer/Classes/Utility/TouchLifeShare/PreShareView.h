//
//  PreShareView.h
//  TouchPalDialer
//
//  Created by game3108 on 16/1/13.
//
//

#import <UIKit/UIKit.h>
#import "ShareData.h"

@interface PreShareView : UIView

- (id)initWithFrame:(CGRect)frame andShareData:(ShareData *)shareData;

@property(nonatomic, copy)void(^shareBlock)(void);

@property(nonatomic, copy)void(^cancelBlock)(void);

@end
