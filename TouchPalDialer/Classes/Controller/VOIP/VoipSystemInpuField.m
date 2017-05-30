//
//  VoipSystemInpuField.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/9.
//
//

#import "VoipSystemInpuField.h"
#import "TPDialerResourceManager.h"

@implementation VoipSystemInpuField
- (id)initWithFrame:(CGRect)frame andPlaceHolder:(NSString*)placeHolder{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        self.returnKeyType = UIReturnKeyDone;
        
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_text_color"];
        self.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
        
        self.layer.borderWidth = 0.5f;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_textField_border_color"].CGColor;
        
        self.placeholder = placeHolder;
        [self setValue:[TPDialerResourceManager getColorForStyle:@"voip_landline_addzoneView_textField_placeholder_color"] forKeyPath:@"_placeholderLabel.textColor"];
        
    }
    
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 5, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 5, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
}

@end
