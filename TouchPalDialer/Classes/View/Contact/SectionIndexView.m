//
//  SectionIndexView.m
//  TouchPalDialer
//
//  Created by zhang Owen on 11/22/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SectionIndexView.h"
#import "consts.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"

@implementation SectionIndexView
@synthesize keys;
@synthesize current_section;
@synthesize delegate;


- (id)initSectionIndexView:(CGRect)frame {
	if (self = [self initWithFrame:frame]) {
		// CGRectMake(280, 90, 40, 320)
		self.keys = [NSArray arrayWithObjects:@"♡", @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"*",nil];
		current_section = -1;
		constvalue = frame.size.height / [self.keys count];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint b_point = [[touches anyObject] locationInView:self];
	int section = (int)(b_point.y / constvalue);
	if (section > [self.keys count] - 1) {
		section =  [self.keys count] - 1;
	}
	if (section < 0) {
		section = 0;
	}
	if (current_section != section) {
		current_section = section;
		NSString *key = [keys objectAtIndex:section];
		[delegate beginNavigateSection:key];
	}
	[delegate addClearView];
	[self setNeedsDisplay];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint move_point = [[touches anyObject] locationInView:self];
    if (move_point.y < 0 || move_point.y > self.frame.size.height) {
        return;
    }
	int section = (int)(move_point.y / constvalue);
    int keyCount = (int)[self.keys count];
	if (section > keyCount - 1) {
		section = keyCount - 1;
	}
	if (section < 0) {
		section = 0;
	}

	if (current_section != section) {
		current_section = section;
		NSString *key = [keys objectAtIndex:section];
		[delegate beginNavigateSection:key];
	}
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	current_section = -1;
	[delegate endNavigateSection];
	[self setNeedsDisplay];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	current_section = -1;
	[delegate endNavigateSection];
	[self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	int count = [keys count];
	
//	if (current_section != -1) {
//		UIImage *bg = [FunctionUtility imageWithColor:[UIColor colorWithRed:COLOR_IN_256(255) green:COLOR_IN_256(255) blue:COLOR_IN_256(122) alpha:0.7]
//											withFrame:rect];
//		[bg drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
     UIColor *textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"SectionIndexView_character_color" needCache:NO];
     CGContextSetFillColorWithColor(context, [textColor CGColor]);
	//CGContextSetRGBFillColor(context, 0x6E/255.0, 0x86/255.0, 0xA2/255.0, 1.0f);
    
//    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//    NSDictionary *tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:textColor};
    
	for (int i = 0; i < count; i++) {
		NSString *key = [keys objectAtIndex:i];
        
//        [key drawInRect:CGRectMake(2, constvalue*i, 20, constvalue) withAttributes:tdic];
        
		[key drawInRect:CGRectMake(2, constvalue*i, 20, constvalue)
			   withFont:[UIFont systemFontOfSize:10]  
		  lineBreakMode:NSLineBreakByTruncatingMiddle
			  alignment:NSTextAlignmentCenter];
	}
	
}

- (void)clear {
	current_section = -1;
	[delegate endNavigateSection];
	[self setNeedsDisplay];
    
}

@end
