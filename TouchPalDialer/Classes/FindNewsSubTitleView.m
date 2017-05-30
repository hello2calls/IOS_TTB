//
//  FindNewsTitleView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/24.
//
//

#import "FindNewsSubTitleView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "NSString+Draw.h"

@implementation FindNewsSubTitleView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.isLeft = NO;
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef bgColor = [UIColor whiteColor].CGColor;
    CGContextSetFillColorWithColor(context, bgColor);

    CGContextSetRGBStrokeColor(context,1,0,0,1);
    CGContextSetLineWidth(context, 1.0);
    
    CGFloat startX = FIND_NEWS_LEFT_MARGIN + rect.origin.x;
    if (!self.isAd) {
        if (self.hots && self.hots.count > 0) {
            for (int i = 0; i < self.hots.count; i++) {
                if (self.highLightFlags.count >= i + 1) {
                    NSNumber* flg = [self.highLightFlags objectAtIndex:i];
                    if (flg && flg.intValue == 1) {
                        startX = [self draw:[self.hots objectAtIndex:i] From:startX withHighLight:YES];
                    } else {
                        startX = [self draw:[self.hots objectAtIndex:i] From:startX withHighLight:NO];
                    }
                } else {
                    startX = [self draw:[self.hots objectAtIndex:i] From:startX withHighLight:NO];
                }
            }
        }
    }
    
    if (self.title && self.title.length > 0) {
        startX = [self draw:self.title From:startX withHighLight:NO];
    }
    
    if (self.isAd) {
        if (self.hots && self.hots.count > 0) {
            NSString* hotText = [self.hots objectAtIndex:0];
            
            if (self.isLeft ) {
                [self draw:hotText From:startX - 2 withHighLight:NO];
            } else {
                CGSize hotSize = [hotText sizeWithFont:[UIFont systemFontOfSize:FIND_NEWS_SUB_TITLE_SIZE] constrainedToSize:CGSizeMake(self.frame.size.width , self.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
                [self draw:hotText From:rect.size.width - hotSize.width - 1 withHighLight:NO];
            }
        }
    }
    
}


- (CGFloat) draw:(NSString*)text From:(CGFloat)startX withHighLight:(BOOL)isHighLight
{
    
    if(!text || text.length <= 0) {
        return startX ;
    }
    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    CGFloat topMargin = 5.0f;
    if (isHighLight) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorRef bgColor = [UIColor whiteColor].CGColor;
        CGContextSetFillColorWithColor(context, bgColor);
        
        CGContextSetRGBStrokeColor(context,1,0,0,1);
        CGContextSetLineWidth(context, 0.5f);
        
        NSDictionary* hotAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont boldSystemFontOfSize:FIND_NEWS_HOT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:FIND_NEWS_HOT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,paragraphStyle, NSParagraphStyleAttributeName, nil];
        CGSize hotSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:FIND_NEWS_HOT_SIZE] constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
        CGPoint topLeft = CGPointMake(startX, topMargin - 1);
        CGPoint bottomRight = CGPointMake(startX + hotSize.width + 6, hotSize.height + topMargin + 1);
        CGFloat radius = 2;
        [ImageUtils drawArcRectangleWithContext:context andPointTopLeft:topLeft andPointBottomRight:bottomRight andRadius:radius];
        CGContextDrawPath(context, kCGPathFillStroke);
        
        [text drawInRect:CGRectMake(startX + 3, topMargin, hotSize.width, hotSize.height) withAttributes:hotAttr withFont:[UIFont boldSystemFontOfSize:FIND_NEWS_HOT_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:FIND_NEWS_HOT_COLOR andDefaultColor:nil]];
        return startX + hotSize.width + 6 + 10;
    } else {
        NSDictionary* titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont systemFontOfSize:FIND_NEWS_SUB_TITLE_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:FIND_NEWS_SUB_TITLE_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,paragraphStyle, NSParagraphStyleAttributeName, nil];
        
        CGSize title = [text sizeWithFont:[UIFont systemFontOfSize:FIND_NEWS_SUB_TITLE_SIZE] constrainedToSize:CGSizeMake(self.frame.size.width  - startX, self.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
        
        
        [text drawInRect:CGRectMake(startX, topMargin - 2, title.width, title.height) withAttributes:titleAttr withFont:[UIFont systemFontOfSize:FIND_NEWS_SUB_TITLE_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:FIND_NEWS_SUB_TITLE_COLOR andDefaultColor:nil]];
        
        return startX + title.width + 10;
    }
    
}

+(CGFloat) getHeightByTitle:(NSString *)subTitle withWidth:(CGFloat) width
{
    CGSize oneLineSize = [@"a" sizeWithFont:[UIFont systemFontOfSize:FIND_NEWS_SUB_TITLE_SIZE] constrainedToSize:CGSizeMake(width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
    return oneLineSize.height ;
}
@end
