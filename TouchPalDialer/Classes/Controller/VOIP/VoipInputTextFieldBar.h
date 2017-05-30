//
//  VoipInputTextFieldBar.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import <UIKit/UIKit.h>
#import "CustomInputTextFiled.h"
#import "VoipScrollView.h"

@protocol VoipInputTextFieldBarDelegate <NSObject>

@optional
- (void)onButtonAction;
@end


@interface VoipInputTextFieldBar : UIView
@property(nonatomic, assign)VoipScrollView *hostView;
@property(nonatomic, assign)id<VoipInputTextFieldBarDelegate> delegate;
@property(nonatomic, assign)NSInteger moveY;
- (id) initWithFrame:(CGRect)frame
         andLeftIcon:(UIImage*)leftIcon
      andPlaceHolder:(NSString*)placeHolder
               andID:(id) object;
- (CustomInputTextFiled *)getTextField;
- (UIButton *) getTextFieldButton;
@end
