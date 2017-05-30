//
//  CallbackWizardTextView.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/2/4.
//
//

#import <UIKit/UIKit.h>

@interface CallbackWizardTextView : UIView

@property (nonatomic, strong) UILabel *line1Label;
@property (nonatomic, strong) UILabel *line2Label;

- (id)initWithFrame:(CGRect)frame withLine1Text:(NSString*)line1Text withLine2Text:(NSString*)line2Text;

@end
