//
//  CallbackWizardTextView.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/2/4.
//
//

#import "CallbackWizardTextView.h"
#import "TPDialerResourceManager.h"
#define ICON_RADIUS 5
#define FRAME_WIDTH 270

@implementation CallbackWizardTextView

@synthesize line1Label;
@synthesize line2Label;

- (id)initWithFrame:(CGRect)frame withLine1Text:(NSString*)line1Text withLine2Text:(NSString*)line2Text{
    self = [super initWithFrame:frame];
    CGFloat iconX = (frame.size.width - FRAME_WIDTH) / 2;
    CGFloat iconY = frame.size.height / 2 - ICON_RADIUS;
    UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(iconX, iconY, 10, 10)];
    iconView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_hint_color"];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = ICON_RADIUS;
    [self addSubview:iconView];
    
    CGFloat lineX = iconX + 2 * ICON_RADIUS + 18;
    CGFloat lineY = line2Text.length > 0 ? 0 : (frame.size.height - FONT_SIZE_3) / 2;
    line1Label = [[UILabel alloc] initWithFrame:CGRectMake(lineX, lineY, FRAME_WIDTH, 17)];
    [line1Label setFont:[line1Label.font fontWithSize:FONT_SIZE_3]];
    line1Label.textColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_hint_color"];
    line1Label.backgroundColor = [UIColor clearColor];
    line1Label.text = line1Text;
    [self addSubview:line1Label];
    
    if (frame.size.height > 20 && line2Text.length > 0) {
        line2Label = [[UILabel alloc] initWithFrame:CGRectMake(lineX, 27, FRAME_WIDTH, 17)];
        [line2Label setFont:[line2Label.font fontWithSize:FONT_SIZE_3]];
        line2Label.textColor = [TPDialerResourceManager getColorForStyle:@"voip_callback_wizard_hint_color"];
        line2Label.backgroundColor = [UIColor clearColor];
        line2Label.text = line2Text;
        [self addSubview:line2Label];
    }
    return self;
}

@end
