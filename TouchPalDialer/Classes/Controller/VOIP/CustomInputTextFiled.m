//
//  CustomInputTextFiled.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-23.
//
//

#import "CustomInputTextFiled.h"
#import "TPDialerResourceManager.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomInputTextFiled (){
    NSInteger inputType;
    BOOL usePadding;
    int padding;
}
@end

@implementation CustomInputTextFiled

- (id)initWithFrame:(CGRect)frame withDefaultPadding:(int)defaultPadding andPlaceHolder:(NSString *)placeHolder andID:(id)object {
    padding = defaultPadding;
    usePadding = YES;
    return [self initWithFrame:frame andPlaceHolder:placeHolder andID:object];
}

- (id)initWithFrame:(CGRect)frame andPlaceHolder:(NSString*)placeHolder andID:(id)object{
    self = [super initWithFrame:frame];
    if (self) {
        inputType = 0;
        self.returnKeyType = UIReturnKeyDone;
        
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_text_color"];
        self.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];

        self.layer.borderWidth = 1.0f;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_border_color"].CGColor;
        
        self.placeholder = placeHolder;
        [self setValue:[TPDialerResourceManager getColorForStyle:@"voip_textfiled_placeholder_color"] forKeyPath:@"_placeholderLabel.textColor"];
        
        if ([object isKindOfClass:[NSString class]]){
            inputType = 1;
            self.middleLine = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 109, 11, 0.5, frame.size.height - 22)];
            _middleLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_border_color"];
            [self addSubview:_middleLine];
        }else if ([object isKindOfClass:[UIImage class]]){
            inputType = 2;
            _middleLine = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 73, 11, 0.5, frame.size.height - 22)];
            _middleLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_textfield_border_color"];
            [self addSubview:_middleLine];
        }
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    if ( inputType == 0)
        return CGRectMake(bounds.origin.x + (usePadding ? padding : 20), bounds.origin.y, bounds.size.width - (usePadding ? padding : 20), bounds.size.height);
    else if ( inputType == 1)
        return CGRectMake(bounds.origin.x + 5, bounds.origin.y, bounds.size.width - 113, bounds.size.height);
    else
        return CGRectMake(bounds.origin.x + 5, bounds.origin.y, bounds.size.width - 82, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    if ( inputType == 0)
        return CGRectMake(bounds.origin.x + (usePadding ? padding : 20), bounds.origin.y, bounds.size.width - (usePadding ? padding : 20), bounds.size.height);
    else if ( inputType == 1)
        return CGRectMake(bounds.origin.x + 5, bounds.origin.y, bounds.size.width - 113, bounds.size.height);
    else
        return CGRectMake(bounds.origin.x + 5, bounds.origin.y, bounds.size.width - 82, bounds.size.height);
}


@end
