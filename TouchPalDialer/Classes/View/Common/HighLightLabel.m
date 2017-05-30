#import "HighLightLabel.h"
#import "PhoneNumber.h"
#import "AppSettingsModel.h"

#define PADDING 30
@interface HighLightLabel(){
    NSMutableArray* highLightRangeList_;
}

- (BOOL) isHighLight:(NSInteger)index;
@end


@implementation HighLightLabel

@synthesize text;
@synthesize font;
@synthesize textColor;
@synthesize highLightColor;
@synthesize currentInfoArray = currentInfoArray_;


-(id) initHighLightLabeWithFrame:(CGRect)frame withName:(NSString *)name withInfoArr:(NSMutableArray *)info_arr {
	if (self = [self initWithFrame:frame]) {
		self.text = name;
		int pair_count = [info_arr count] / 2;
		int i = 0;
		for (; i < pair_count; i++) {
			NSRange r = {
				[(NSNumber*)[info_arr objectAtIndex:(2 * i)] intValue],
				[(NSNumber*)[info_arr objectAtIndex:(2 * i + 1)] intValue],
			};
			
			[self addHighLightRange:r];
		}
	}
	return self;
}

-(id) initHighLightLabeWithFrame:(CGRect)frame withNumber:(NSString *)num withRange:(NSRange)range {
	if (self = [self initWithFrame:frame]) {
		self.text = num;
		[self addHighLightRange:range];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		highLightRangeList_ = [[NSMutableArray alloc] init];
		self.font = [UIFont systemFontOfSize:15];
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void) addHighLightRange:(NSRange) pHighLightRange
{
	NSValue* range = [NSValue valueWithRange:pHighLightRange];
	[highLightRangeList_ addObject:range];
}

-(void) cleanUpHighLightRange
{
	[currentInfoArray_ removeAllObjects];
    [highLightRangeList_ removeAllObjects];
}


-(void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextFillRect(context, rect);
	
	int count = [text length];
	CGFloat x = 0;
	
	for(int i = 0; i < count ; i++) {
		
		NSRange r = {i, 1};
		
		NSString* s = [text substringWithRange:r];
        
//        CGSize z = CGSizeZero;
//        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
//        z = [s boundingRectWithSize:z
//                            options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                attributes:tdic
//                                   context:nil].size;
        
		CGSize z = [s sizeWithFont: font];
		if (x + PADDING >self.frame.size.width) {
//            NSDictionary *tdic = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
//            [@"..." drawAtPoint:CGPointMake(x, self.frame.size.height - z.height) withAttributes:tdic];
            [@"..." drawAtPoint:CGPointMake(x, self.frame.size.height - z.height) withFont:font];
            break;
        }else {
//            NSDictionary *tdic = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
//            [s drawAtPoint:CGPointMake(x, self.frame.size.height - z.height) withAttributes:tdic];
            [s drawAtPoint:CGPointMake(x, self.frame.size.height - z.height) withFont:font];
        }
		x = x + z.width;
	}
}


- (BOOL) isHighLight:(NSInteger)index
{
	int count = [highLightRangeList_ count];
	
	for (int i = 0 ; i < count ; i++)
	{
		NSValue* value = [highLightRangeList_ objectAtIndex:i];
		NSRange range = [value rangeValue];
		
		if( index >= range.location && index < (range.location + range.length)) {
			return YES;
		}
	}
	
	return NO;
}

- (void)refreshName:(NSString *)name withInfoArr:(NSMutableArray *)info_arr {
	[self cleanUpHighLightRange];
	
	self.text = name;
	int pair_count = [info_arr count] / 2;
	int i = 0;
	for (; i < pair_count; i++) {
		NSRange r = {
			[(NSNumber*)[info_arr objectAtIndex:(2 * i)] intValue],
			[(NSNumber*)[info_arr objectAtIndex:(2 * i + 1)] intValue],
		};
		
		[self addHighLightRange:r];
	}
	currentInfoArray_ = info_arr;
	[self setNeedsDisplay];
}
- (void)refreshNumber:(NSString *)number withRange:(NSRange)range isShowAttribution:(BOOL)is_attr isOnlyShowAttr:(BOOL)isOnlyShowAttr{
	[self cleanUpHighLightRange];
    if (is_attr) {
        AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
        if (appSettingsModel.display_location) {
            NSString *numberAttr =[[PhoneNumber sharedInstance] getNumberAttribution:number withType:attr_type_short];
            if ([numberAttr length]>0) {
                if (isOnlyShowAttr) {
                    self.text = numberAttr;
                }else {
                    self.text = [NSString stringWithFormat:@"%@ (%@)", 
                                 number, 
                                 numberAttr];
                }
            }else {
                self.text = number;
            }
        } else {
            if (isOnlyShowAttr) {
                NSString *numberAttr =[[PhoneNumber sharedInstance] getNumberAttribution:number withType:attr_type_short];
                self.text = numberAttr;
            }else{
                 self.text = number;
            }
        }
    }else {
        self.text = number;
    }
	[self addHighLightRange:range];
	[self setNeedsDisplay];
}

- (void)refreshNumber:(NSString *)number withRange:(NSRange)range isShowAttribution:(BOOL)is_attr{
    [self refreshNumber:number withRange:range isShowAttribution:NO isOnlyShowAttr:NO];
}

- (void)refreshNumber:(NSString *)number withRange:(NSRange)range isOnlyShowAttr:(BOOL)isOnlyShowAttr{
   [self refreshNumber:number withRange:range isShowAttribution:YES isOnlyShowAttr:isOnlyShowAttr];
}




@end
