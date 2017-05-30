//
//  shareScrollButtonView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/3/30.
//
//

#import <UIKit/UIKit.h>
#define SHARE_WEIXIN 0
#define SHARE_TIMELINE 1
#define SHARE_QQ 2
#define SHARE_QQZONE 3
#define SHARE_SMS 4
#define SHARE_CLIPBOARD 5


@protocol ShareScrollButtonViewDelegate <NSObject>
- (void)clickOnButton:(NSInteger)tag;
@end


@interface shareScrollButtonView : UIView
@property (nonatomic,assign) id<ShareScrollButtonViewDelegate> shareDelegate;;
- (instancetype)initWithFrame:(CGRect)frame andButtonArray:(NSArray *)buttonArray;
@end
