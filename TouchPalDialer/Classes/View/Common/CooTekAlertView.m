//
//  CooTekAlertView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/13/12.
//
//

#import "CooTekAlertView.h"
#import "ImageViewUtility.h"
#import "TPDialerResourceManager.h"
#import "TPUIButton.h"
#import "BCZeroEdgeTextView.h"
#import "ContactNoteTextView.h"

@interface CooTekAlertView (){
    ContactNoteTextView *numberInputTextField_;
    UIButton *buttonConfirm_;
    UIImageView *inputView_;
}

@end

@implementation CooTekAlertView
@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame Icon:(UIImage *)icon Title:(NSString *)title message:(NSString *)message delegate:(id<CootekAlertViewProtocol>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle textViewPlaceText:(NSString *)textViewText
{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.delegate = delegate;
        
        
        UIView *bgView = [[UIView alloc] initWithFrame:frame];
        bgView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"popup_bg_color"];
        [self addSubview:bgView];
        
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 41)];
        headView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_dialog_title_bg@2x.png"];
        headView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:headView];
        
        UIImageView *headIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, icon.size.width, icon.size.height)];
        headIconView.image = icon;
        [headView addSubview:headIconView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + icon.size.width, 5,
                                                                        frame.size.width - 15 - icon.size.width, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
        [headView addSubview:titleLabel];

        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(10, 45, frame.size.width - 20, frame.size.height - 90)];
		contentView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:contentView];
        
        UILabel *msgLabel = [[UILabel alloc]initWithFrame:
                             CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
		msgLabel.backgroundColor = [UIColor clearColor];
		msgLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
		msgLabel.text = message;
        msgLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"common_popup_text_color"];
        msgLabel.textAlignment = NSTextAlignmentLeft;
        msgLabel.numberOfLines = 3;
        msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [contentView addSubview:msgLabel];
        
        if(textViewText!=nil){
            inputView_ = [[UIImageView alloc]initWithFrame:CGRectMake(0, contentView.frame.size.height - 38,
                                                                     contentView.frame.size.width, 38)];
            inputView_.image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_dialog_input_bg_activite@2x.png"];
            [contentView addSubview:inputView_];

            numberInputTextField_ = [[ContactNoteTextView alloc]
                                     initWithFrame:CGRectMake(0, contentView.frame.size.height - 38,
                                                              contentView.frame.size.width, 38)];
            [msgLabel setFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height - 40)];
            numberInputTextField_.scrollEnabled = NO;
            numberInputTextField_.font = [UIFont systemFontOfSize:16];
            numberInputTextField_.text = @"";
            numberInputTextField_.backgroundColor = [UIColor clearColor];
            numberInputTextField_.keyboardType = UIKeyboardTypePhonePad;
            numberInputTextField_.selectedRange = NSMakeRange(0, 0);
            numberInputTextField_.textAlignment = NSTextAlignmentLeft;
            [numberInputTextField_ becomeFirstResponder];
            numberInputTextField_.delegate = self;
            [contentView addSubview:numberInputTextField_];
        }
        
        UIImage *buttonBackgroundHighlighted = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_popup_button_ht@2x.png"];
        
        TPUIButton *buttonConfirm = [TPUIButton buttonWithType:UIButtonTypeCustom];
        buttonConfirm.frame = CGRectMake(0, frame.size.height - 40, frame.size.width, 40);
        buttonConfirm.tag = 0;
        [buttonConfirm setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_popup_button_right_normal@2x.png"] forState:UIControlStateNormal];
        [buttonConfirm setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
        [buttonConfirm setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [buttonConfirm setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"common_popup_button_text_color"] forState:UIControlStateNormal];        
        [buttonConfirm setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"common_popup_button_disabled_text_color"] forState:UIControlStateDisabled];
        [buttonConfirm addTarget:self action:@selector(pressOnButton:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:buttonConfirm];
        buttonConfirm_ = buttonConfirm;
        if(otherButtonTitle!=nil){
            buttonConfirm.frame = CGRectMake(0, frame.size.height - 40, frame.size.width * 0.5, 40);
            TPUIButton *otherButton = [TPUIButton buttonWithType:UIButtonTypeCustom];
            otherButton.frame = CGRectMake(frame.size.width * 0.5, frame.size.height - 40, frame.size.width * 0.5, 40);
            otherButton.tag = 1;
            [buttonConfirm setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_popup_button_left_normal@2x.png"] forState:UIControlStateNormal];
            [otherButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_popup_button_right_normal@2x.png"] forState:UIControlStateNormal];
            [otherButton setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
            [otherButton setTitle:otherButtonTitle forState:UIControlStateNormal];
            [otherButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"common_popup_button_text_color"] forState:UIControlStateNormal];
            [otherButton addTarget:self action:@selector(pressOnButton:) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:otherButton];
        }
        
        if(textViewText!=nil && numberInputTextField_.text.length < 7){
            buttonConfirm.enabled = NO;
        }
    }
    return self;
}

- (void)pressOnButton:(UIButton *)buttonPressed{
    if(numberInputTextField_==nil){
      [delegate_ pressOnCootekAlertView:buttonPressed];
    }else{
        [numberInputTextField_ resignFirstResponder];
        [delegate_ pressOnCootekTextAlertView:numberInputTextField_.text];
    }
    [self removeFromSuperview];
}

#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    if(textView.text.length>=7){
        buttonConfirm_.enabled = YES;
    } else {
        buttonConfirm_.enabled = NO;
    }
}

@end
