//
//  CustomTextField.m
//  CallInfoShow
//
//  Created by Liangxiu on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomTextField.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
//
// CustomTextField
//
// UITextView seems to automatically be resetting the contentInset
// bottom margin to 32.0f, causing strange scroll behavior in our small
// textView.  Maybe there is a setting for this, but it seems like odd behavior.
// override contentInset to always be zero.
//


@implementation CustomTextField
@synthesize needFilterCharacters = needFilterCharacters_;
@synthesize pasteDelegate = pasteDelegate_;
- (void)paste:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
    NSString* candidate = pasteboard.string;
    if(needFilterCharacters_){
        NSMutableString * builder = [NSMutableString stringWithString:@""];
        for (NSUInteger i = 0; i < candidate.length; i++) {
            unichar  ch = [candidate characterAtIndex:i];
            if ((ch >= '0' && ch <= '9')) {
                [builder appendFormat:@"%c",ch];
            }
        }
        if(builder.length==0){
            [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Ooops, no number in the clipboard.", @"") message:nil];
            return;
        }else{
            self.text = builder;
        }
    }else{
        self.text = candidate;
    }
    if(self.text.length > 0){
        [pasteDelegate_ textField:self didPasteWithEffectText:self.text];
    }
}

// place holder text left gap 5
- (CGRect)textRectForBounds:(CGRect)bounds {
    if(self.leftInset <=0){
        self.leftInset =0;
    }
    return CGRectInset( bounds , self.leftInset , 0 );
}
//text left gap 5
- (CGRect)editingRectForBounds:(CGRect)bounds {
    if(self.leftInset <=0){
        self.leftInset =0;
    }
    return CGRectInset( bounds , self.leftInset , 0 );
}
@end
