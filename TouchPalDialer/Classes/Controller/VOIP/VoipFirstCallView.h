//
//  VoipFirstCallView.h
//  TouchPalDialer
//
//  Created by game3108 on 15-1-7.
//
//

#import <UIKit/UIKit.h>
#import "DialerUsageRecord.h"
@protocol VoipFirstCallViewDelegate <NSObject>
- (void)clickRegisterButton;
- (void)clickNoInterestButton;
@end

@interface VoipFirstCallView : UIView
- (instancetype)initWithFrame:(CGRect)frame ifOversea:(BOOL)oversea;
@property(nonatomic,assign) id<VoipFirstCallViewDelegate> delegate;
@end
