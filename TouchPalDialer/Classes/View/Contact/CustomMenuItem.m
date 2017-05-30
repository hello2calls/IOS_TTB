//
//  CustomMenuItem.m
//  TouchPalDialer
//
//  Created by Sendor on 11-8-23.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CustomMenuItem.h"


@implementation CustomMenuItem

@synthesize delegate;
@synthesize normal_image;
@synthesize highlighted_image;
@synthesize normal_text_color;
@synthesize highlighted_text_color;
@synthesize image_frame;
@synthesize text_frame;
@synthesize is_highlighted;
@synthesize font_size;
@synthesize menu_text;

- (id)initWithFrame:(CGRect)frame withMenuItemId:(MenuItemId)menuItemId withDelegate:(id<CustomMenuItemProtocol>)menuItemDelegate {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code.
        delegate = menuItemDelegate;
        menu_item_id = menuItemId;
        normal_image = nil;
        highlighted_image = nil;
        menu_text = nil;
        normal_text_color = TinyColorMake(0, 0, 0, 1);
        highlighted_text_color = TinyColorMake(1, 1, 1, 1);
        is_highlighted = NO;
        font_size = 14;
        
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
    CGRect drawImageFrame = CGRectMake(0, 0, 0, 0);
    if (normal_image != nil) {
        drawImageFrame.origin.x = image_frame.origin.x + (image_frame.size.width - normal_image.size.width)/2;
        drawImageFrame.origin.y = image_frame.origin.y + (image_frame.size.height - normal_image.size.height)/2;
        drawImageFrame.size = normal_image.size;
    }
    
    // draw image
    if (is_highlighted && highlighted_image != nil) {
            [highlighted_image drawInRect:drawImageFrame];
    } else {
        if (normal_image != nil) {
            [normal_image drawInRect:drawImageFrame];
        }
    }

    // draw text
    if (menu_text != nil) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (is_highlighted) {
            CGContextSetRGBFillColor(context, highlighted_text_color.red, highlighted_text_color.green, highlighted_text_color.blue, highlighted_text_color.alpha);
        }
        else {
            CGContextSetRGBFillColor(context, normal_text_color.red, normal_text_color.green, normal_text_color.blue, normal_text_color.alpha);
        }
        [menu_text drawInRect:text_frame 
                     withFont:[UIFont boldSystemFontOfSize:font_size] 
                lineBreakMode:UILineBreakModeTailTruncation 
                    alignment:UITextAlignmentCenter];
    }
}


- (void)dealloc {
    [normal_image release];
    [highlighted_image release];
    [menu_text release];
    [super dealloc];
    
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	self.is_highlighted = YES;
	[self setNeedsDisplay];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.is_highlighted = NO;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.is_highlighted = NO;
    [delegate onMenuItem:menu_item_id];
	[self setNeedsDisplay];
}

@end
