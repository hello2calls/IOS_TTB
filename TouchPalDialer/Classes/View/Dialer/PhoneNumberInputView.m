//
//  PhoneNumberInputView.m
//  TouchPalDialer
//
//  Created by zhang Owen on 9/29/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "PhoneNumberInputView.h"
#import "PhonePadModel.h"
#import <quartzcore/QuartzCore.h>
#import "consts.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SmartDailerSettingModel.h"
#import "CallerIDModel.h"
#import "FunctionUtility.h"
#import "NSString+PhoneNumber.h"
#import "TPTextFlowView.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
@interface PhoneNumberInputView (){
    TPTextFlowView *attrView_;
}
@end

@implementation PhoneNumberInputView

@synthesize inputStr = inputStr_;
@synthesize textColor;
@synthesize attrTextColor;
@synthesize isYellowPage;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        CGFloat attrTopGap = 28;
        CGFloat attrFontSize = CELL_FONT_XSMALL;
        CGFloat leftGap = 0;
        CGRect attrViewRect = CGRectMake(leftGap, attrTopGap, frame.size.width, frame.size.height - attrTopGap);
        attrView_ = [[TPTextFlowView alloc] initWithFrame:attrViewRect
                                                     text:@""
                                                textColor:[UIColor redColor]
                                            textAlignment:NSTextAlignmentCenter
                                                     font:[UIFont systemFontOfSize:attrFontSize]
                                               spaceWidth:30
                                             timeInterval:0.04];
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 30)];
        _numLabel.backgroundColor = [UIColor clearColor];
        _numLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        _numLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_numLabel];
        
        
        [self addSubview:attrView_];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawAttr) name:N_REDRAW_PHONE_NUMBER_INPUT_VIEW object:nil];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
	if ([super becomeFirstResponder]) {
		return YES;
	} else {
		return NO;
	}

}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if (action == @selector(paste:)) {
		return YES;
	} else if (action == @selector(copy:)) {
		return YES;
	} else {
		return NO;
	}
}

- (void)paste:(id)sender {
	cootek_log(@"am paste...");
    [self.delegate pasteClickedInView:self];
    [self resignFirstResponder];
}

- (void)copy:(id)sender {
	cootek_log(@"am copy.... %@", inputStr_);
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
	pasteboard.persistent = YES;
	pasteboard.string = inputStr_;
	[self resignFirstResponder];
}

- (void)setInputStr:(NSString *)inputString{
    if (inputString.length > SEARCH_INPUT_MAX_LENGTH) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Ooops, the input is too long.", @"")
                                                  message:nil];
        return;
    }
    
    inputStr_ = inputString;
    [self updateNumLable];
    if (!isYellowPage) {
        NSString *callerIDString = nil;
        CallerIDInfoModel *callerInfo = [PhonePadModel getSharedPhonePadModel].caller_id_info;
        if(callerInfo != nil &&
           [callerInfo isCallerIdUseful] &&
           [inputString isEqualToString:[PhonePadModel getSharedPhonePadModel].input_number]){
            callerIDString = callerInfo.name;
            if([FunctionUtility isNilOrEmptyString:callerIDString]) {
                callerIDString = callerInfo.localizedTag;
            }
        }
        
        NSString *attrString = [PhonePadModel getSharedPhonePadModel].number_attr;
        NSString *numberAttrString = nil;
        if(callerIDString.length>0 && attrString.length > 0){
            numberAttrString = [NSString stringWithFormat:@"%@  %@",callerIDString,attrString];
        }else if(callerIDString.length > 0){
            numberAttrString = callerIDString;
        }else if(attrString.length > 0){
            numberAttrString = attrString;
        }
        if(![numberAttrString isEqualToString:attrView_.text]){
           attrView_.text = @"00+国际区号+电话号码";
        }
    }
}
#pragma mark  -
#pragma mark touch control.

-(void)updateNumLable{
 
    CGFloat fontSize = CELL_FONT_XLARGE;
    CGFloat topGap = 3;
    NSString *phone_number;
    
    if (isYellowPage) {
        phone_number = inputStr_;
        topGap = 10;
    } else {
        phone_number = [PhonePadModel getSharedPhonePadModel].input_number;
        phone_number = [phone_number formatPhoneNumber];
    }
    
    if(phone_number.length > 11){
        fontSize = 20;
    }
    if (phone_number != nil && [phone_number length] > 0) {
    _numLabel.font = [UIFont systemFontOfSize:fontSize];
    _numLabel.text =phone_number;
    _numLabel.textColor = textColor;
    _numLabel.frame = CGRectMake(0, topGap, self.frame.size.width, 30);
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isYellowPage) {
        return;
    }
	cootek_log(@"hello touch end.");
	if ([self isFirstResponder]) {
		cootek_log(@"touch end ---> is first responder");
		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setMenuVisible:NO animated:YES];
		[menu update];
		[self resignFirstResponder];
	} else if ([self becomeFirstResponder]) {
		cootek_log(@"touch end ---> become first responder");
		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setTargetRect:self.bounds inView:self];
		[menu setMenuVisible:YES animated:YES];
	}
}


- (void)redrawAttr{
    [self setInputStr:inputStr_];
}

- (void)dealloc {
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)selfSkinChange:(NSString *)style{
     NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
     self.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]];
     self.attrTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"attrTextColor"]];
     attrView_.textColor = self.attrTextColor;
     NSNumber *toTop =[NSNumber numberWithBool:YES];
     return toTop;
}

@end
