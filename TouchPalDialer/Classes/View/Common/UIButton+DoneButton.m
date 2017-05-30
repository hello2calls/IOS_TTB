//
//  UIButton+DoneButton.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-4-18.
//
//

#import "UIButton+DoneButton.h"
#import "TPDialerResourceManager.h"

@implementation UIButton (DoneButton)

- (UIColor *)textColor
{
    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
    NSDictionary *dict = [manager getPropertyDicByStyle:@"longPressView_style"];
    return [manager getUIColorFromNumberString:[dict objectForKey:@"doneButton_textColor"]];
}

@end
