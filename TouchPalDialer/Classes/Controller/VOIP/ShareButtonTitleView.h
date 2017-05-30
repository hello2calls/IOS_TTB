//
//  shareButtonTitleView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/3/30.
//
//

#import <UIKit/UIKit.h>

@protocol shareButtonTitleViewDelegate <NSObject>
- (void)clickOnButton:(NSInteger)tag;
@end

@interface ShareButtonTitleView : UIView
@property (nonatomic,retain) UIButton *shareButton;
@property (nonatomic,retain) UILabel *shareLabel;
@property (nonatomic,assign) id<shareButtonTitleViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andButtonTitle:(NSString *)buttonTitle andLabelTitle:(NSString *)labelTitle andTag:(NSInteger)tag;
@end
