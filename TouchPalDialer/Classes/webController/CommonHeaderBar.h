//
//  CommonHeaderBar.h
//  TouchPalDialer
//
//  Created by game3108 on 15/4/13.
//
//

#import <UIKit/UIKit.h>
#import "TPHeaderButton.h"
#import "TPHeaderLabel.h"

@protocol CommonHeaderBarProtocol <NSObject>
@optional
- (void) leftButtonAction;
@end

@interface CommonHeaderBar : UIView
@property (nonatomic, weak) id<CommonHeaderBarProtocol> delegate;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) TPHeaderButton *leftButton;
@property (nonatomic) TPHeaderLabel *headerLabel;
@property (nonatomic, assign) BOOL skinEnabled;

- (void) setHeaderTitle:(NSString *)headerTitle;
- (instancetype)initWithFrame:(CGRect)frame andHeaderTitle:(NSString *)headerTitle;
- (void) setLight:(BOOL)ifLight;
@end
