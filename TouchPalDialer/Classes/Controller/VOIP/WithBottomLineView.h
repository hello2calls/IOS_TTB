//
//  bottomLineView.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-6.
//
//

#import <UIKit/UIKit.h>

@interface WithBottomLineView : UIView
@property (nonatomic, assign) UILabel *mainTitle;
@property (nonatomic, assign) UILabel *subTitle;
@property (nonatomic, retain) UILabel *dotLabel;
@property (nonatomic, assign)UILabel *attributeLabel;
- (id) initWithFrame:(CGRect)frame withTitle:(NSString *)title  withDescription:(NSString *)description ifParticipate:(BOOL)ifParticipate;
-(void)refreshWithTitle:(NSString *)title;
@end
