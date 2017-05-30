//
//  CooTekAlertView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/13/12.
//
//

#import <UIKit/UIKit.h>
@protocol CootekAlertViewProtocol
@optional
 -(void)pressOnCootekAlertView:(UIButton *)buttonPressed;
 - (void)pressOnCootekTextAlertView:(NSString *)textFieldText;
@end

@interface CooTekAlertView : UIView <UITextViewDelegate>
@property(nonatomic,assign) id<CootekAlertViewProtocol> delegate;

- (id)initWithFrame:(CGRect)frame Icon:(UIImage *)icon Title:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle textViewPlaceText:(NSString *)textViewText;
@end
