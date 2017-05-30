//
//  AlipayPopupView.m
//  TouchPalDialer
//
//  Created by Chen Lu on 8/12/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#import "AlipayPopupView.h"
#import "ImageViewUtility.h"
#import "TPDialerResourceManager.h"
#import "TPUIButton.h"

@interface AlipayPopupView (){
    BOOL checked_;
    UIImageView *checkBoxImageView_;
    void(^actionBlock_)(BOOL checked);
    void(^cancelBlock_)(BOOL checked);
}
@end

@implementation AlipayPopupView

- (id)initWithTitle:(NSString *)title 
            message:(NSString *)message
   cancelButtonText:(NSString *)cancelButtonText
   actionButtonText:(NSString *)actionButtonText
       checkBoxText:(NSString*) checkBoxText
        actionBlock:(void (^) (BOOL checked))actionBlock
        cancelBlock:(void (^) (BOOL checked))cancelBlock
{
    self = [self initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    
    if (self) {
        
        // semi-transparent mask
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        
        // background image
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(20,(TPScreenHeight()- 215)/2, TPScreenWidth() - 40, 215)];
        bgView.backgroundColor = [[TPDialerResourceManager sharedManager]
                                  getUIColorFromNumberString:@"popup_bg_color"];
        [self addSubview:bgView];
        
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, 41)];
        headView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_dialog_title_bg@2x.png"];
        headView.backgroundColor = [UIColor clearColor];
        [bgView addSubview:headView];
		
		// headerLabel
        int headerHight = 40;
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, TPScreenWidth()-50, headerHight)];
		headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"defaultCellMainText_color"];
		headerLabel.font = [UIFont systemFontOfSize:CELL_FONT_LARGE];
		headerLabel.text = title;
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		[headView addSubview:headerLabel];
        
        // sloganView
        UIImage *slogan = [[TPDialerResourceManager sharedManager] getImageByName:NSLocalizedString(@"alipay_slogan@2x.png", @"")];
        UIImageView *sloganView = [[UIImageView alloc] initWithImage:slogan];
        sloganView.frame = CGRectMake(0, 40, 270, 40);
        [bgView addSubview:sloganView];
		
		// messageLabel
		UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 85, TPScreenWidth()-50, 50)];
		messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_popup_text_color"];
		messageLabel.text = message;
		messageLabel.font = [UIFont systemFontOfSize:16];
        messageLabel.numberOfLines = 0;
		[bgView addSubview:messageLabel];
        
        // checkButton
        checked_ = false;
        if (checkBoxText) {
            TPUIButton *checkButton = [TPUIButton buttonWithType:UIButtonTypeCustom];
            checkButton.frame = CGRectMake(5, 140, TPScreenWidth(), 25);
            checkButton.backgroundColor = [UIColor clearColor];
            [bgView addSubview:checkButton];
            
            UIImage *unCheckedImage = [[TPDialerResourceManager sharedManager] getImageByName:@"common_select_small_normal@2x.png"];
            checkBoxImageView_ = [[UIImageView alloc] initWithImage:unCheckedImage];
            [checkButton addSubview:checkBoxImageView_];
            [checkButton addTarget:self action:@selector(clickCheckBox) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, TPScreenWidth()-2, 25)];
            checkLabel.backgroundColor = [UIColor clearColor];
            checkLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_popup_shareToSinaText_color"];
            checkLabel.font = [UIFont systemFontOfSize:15];
            checkLabel.text = checkBoxText;
            [checkButton addSubview:checkLabel];
        }
        
		// bottomView
		UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 170, TPScreenWidth()-40, 45)];
		[bgView addSubview:bottomView];
        
        UIImage *buttonBackgroundNormal = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_button_left_normal@2x.png"];
        UIImage *buttonBackgroundHighlighted = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_button_ht@2x.png"];


        //left: cancelButton
        TPUIButton *cancelButton = [TPUIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, (TPScreenWidth()-40)/2, 45);
        [cancelButton setBackgroundImage:buttonBackgroundNormal forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (TPScreenWidth()-40)/2, 45)];
        label.backgroundColor=[UIColor clearColor];
        label.font = [UIFont systemFontOfSize:CELL_FONT_LARGE];
        label.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"common_popup_button_text_color"];
        label.text = cancelButtonText;
        label.textAlignment=NSTextAlignmentCenter;
        [cancelButton addSubview:label];
        [bottomView addSubview:cancelButton];
        
        buttonBackgroundNormal = [[TPDialerResourceManager sharedManager]
                                  getImageByName:@"common_popup_button_right_normal@2x.png"];
        //right: actionButton
        TPUIButton *actionButton = [TPUIButton buttonWithType:UIButtonTypeCustom];
        actionButton.frame = CGRectMake((TPScreenWidth()-40)/2, 0, (TPScreenWidth()-40)/2, 45);
        [actionButton setBackgroundImage:buttonBackgroundNormal forState:UIControlStateNormal];
        [actionButton setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];        
        [actionButton addTarget:self action:@selector(clickActionButton) forControlEvents:UIControlEventTouchUpInside];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (TPScreenWidth()-40)/2, 45)];
        label.backgroundColor=[UIColor clearColor];
        label.font = [UIFont systemFontOfSize:CELL_FONT_LARGE];
        label.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"common_popup_button_text_color"];
        label.text = actionButtonText;
        label.textAlignment=NSTextAlignmentCenter;
        [actionButton addSubview:label];
        [bottomView addSubview:actionButton];
        
        //actionBlock
        actionBlock_ = [actionBlock copy];        
        //cancelBlock
        cancelBlock_ = [cancelBlock copy];
    }
    
    return self;
}

- (void)clickCheckBox {
    UIImage *image = nil;
    checked_ = !checked_;
    if (checked_) {
        image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_select_small_press@2x.png"];
    } else {
        image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_select_small_normal@2x.png"];
    }
    checkBoxImageView_.image = image;
}

- (void)clickCancelButton {
    if (cancelBlock_) {
        cancelBlock_(checked_);
    }
	[self removeFromSuperview];
}

-(void)clickActionButton {
    if (actionBlock_) {
        actionBlock_(checked_);
    }
    [self removeFromSuperview];
}

@end
