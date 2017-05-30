//
//  ClearView.m
//  TouchPalDialer
//
//  Created by zhang Owen on 11/24/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ClearView.h"
#import "TPDialerResourceManager.h"

@implementation ClearView
@synthesize key;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		//self.backgroundColor = [UIColor clearColor];
		self.key = @"";
    }
    return self;
}

- (void)setSectionKey:(NSString *)mkey {
	self.key = mkey;
	[self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {	
	CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"ClearViewText_color" needCache:NO];
    CGContextSetFillColorWithColor(context, [textColor CGColor]);
    
//    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//    NSDictionary *tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:50], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:textColor};
//    
//	[key drawInRect:CGRectMake(0, 7, 70, 70) withAttributes:tdic];
//
    [key drawInRect:CGRectMake(0, 7, 70, 70)
           withFont:[UIFont systemFontOfSize:50]
      lineBreakMode:NSLineBreakByTruncatingMiddle
          alignment:NSTextAlignmentCenter];
}


@end
