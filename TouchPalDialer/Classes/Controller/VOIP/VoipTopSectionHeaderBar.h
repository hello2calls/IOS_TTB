//
//  VoipTopSectionHeaderBar.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import <UIKit/UIKit.h>

@protocol VoipTopSectionHeaderBarProtocol <NSObject>

@optional
- (void) gotoBack;
- (void) headerButtonAction;
- (void) headerButtonAction2;
@end


@interface VoipTopSectionHeaderBar : UIView
@property (nonatomic , assign) id<VoipTopSectionHeaderBarProtocol> delegate;
@property (nonatomic , retain) UILabel *headerTitle;
@property (nonatomic , retain) UIButton *headerButton;
@property (nonatomic , retain) UIButton *headerButton2;
- (id) initWithFrame:(CGRect)frame;
- (void) setButtonText:(NSString*)text;
- (void) setButton2Text:(NSString*)text;
@end
