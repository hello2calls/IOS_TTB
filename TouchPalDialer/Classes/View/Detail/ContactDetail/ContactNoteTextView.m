//
//  ContactNoteTextView.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-22.
//
//

#import "ContactNoteTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "TPDialerResourceManager.h"

@implementation ContactNoteTextView

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
        
        UIColor *borderColor = [manager getUIColorFromNumberString:@"tp_color_grey_150"];
        [self.layer setBorderColor:[borderColor CGColor]];
        [self.layer setCornerRadius:2];
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
        
		self.textColor = [manager getUIColorFromNumberString:@"tp_color_grey_800"];
        [self setBorderVisibility:YES];
    }
    return self;
}

- (UIEdgeInsets)contentInset
{
    return UIEdgeInsetsZero;
}

- (BOOL)borderVisibility
{
    return self.layer.borderWidth != 0.0f;
}

- (void)setBorderVisibility:(BOOL)borderVisibility
{
    if (borderVisibility) {
        [self.layer setBorderWidth:1];
    } else {
        [self.layer setBorderWidth:0];
    }
}

@end
