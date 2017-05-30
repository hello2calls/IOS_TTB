//
//  InfoLabel.m
//  TouchPalDialer
//
//  Created by zhang Owen on 8/9/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "InfoLabel.h"


@implementation InfoLabel
@synthesize info;


- (id)initInfoLabelWithFrame:(CGRect)frame withInfo:(NSString *)info_str {
	if (self = [self initWithFrame:frame]) {
		self.info = info_str;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
    
//    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
//    paragraphStyle.alignment = NSTextAlignmentLeft;
//    NSDictionary *tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName:paragraphStyle};
//    
//    [info drawInRect:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height) withAttributes:tdic];
	[info drawInRect:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height)
				  withFont:[UIFont systemFontOfSize:20] 
			 lineBreakMode:NSLineBreakByClipping
				 alignment:NSTextAlignmentLeft];
}


@end
