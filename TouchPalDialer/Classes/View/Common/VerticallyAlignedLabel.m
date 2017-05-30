//
//  VerticallyAlignedLabel.m
//  TouchPalDialer
//
//  Created by Alice on 11-11-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "VerticallyAlignedLabel.h"

@implementation VerticallyAlignedLabel

@synthesize verticalAlignment = verticalAlignment_;
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.verticalAlignment = VerticalAlignmentTop;
		self.lineBreakMode=NSLineBreakByTruncatingTail;
		self.numberOfLines=0;
		self.font=[UIFont systemFontOfSize:14];
		self.backgroundColor = [UIColor clearColor];
		self.textColor= [UIColor colorWithRed:COLOR_IN_256(60) green:COLOR_IN_256(64) blue:COLOR_IN_256(69) alpha:1.0];
		self.textAlignment=NSTextAlignmentLeft;
    }
    return self;
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment {
    verticalAlignment_ = verticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) {
        case VerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case VerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case VerticalAlignmentMiddle:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }
    return textRect;
}

-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}
@end