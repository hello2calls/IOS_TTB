//
//  LetterCircleView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/8/28.
//
//

#import "LetterCircleView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "NSString+Draw.h"

@implementation LetterCircleView
@synthesize letter;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:LETTER_NORMAL_BG_COLOR andDefaultColor:nil].CGColor);
    CGContextSetLineWidth(context, 0);
    CGContextAddArc(context, rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2, rect.size.width / 2, 0, 360, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //draw letter
    NSMutableParagraphStyle *letterStyle= [[NSMutableParagraphStyle alloc] init];
    letterStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    letterStyle.alignment = NSTextAlignmentCenter;
    NSDictionary* letterAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:LETTER_TITLE_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:LETTER_TITLE_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,letterStyle, NSParagraphStyleAttributeName, nil];
    
    CGSize letterSize = [letter sizeWithFont:[UIFont systemFontOfSize:LETTER_TITLE_SIZE] constrainedToSize:CGSizeMake(rect.size.width, rect.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
    
    [letter drawInRect:CGRectMake(0, (rect.size.height - letterSize.height) / 2, rect.size.width, letterSize.height) withAttributes:letterAttr withFont:[UIFont systemFontOfSize:LETTER_TITLE_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter UIColor:[ImageUtils colorFromHexString:LETTER_TITLE_COLOR andDefaultColor:nil]];
    
}

//-(void)setHidden:(BOOL)hidden
//{
//    if (hidden) {
//        //隐藏时
//        self.alpha= 1.0f;
//        [UIView beginAnimations:@"fadeOut" context:nil];
//        [UIView setAnimationDuration:0.7];
//        [UIView setAnimationDelegate:self];//设置委托
//        [UIView setAnimationDidStopSelector:@selector(animationStop)];//当动画结束时，我们还需要再将其隐藏
//        self.alpha = 0.0f;
//        [UIView commitAnimations];
//    }
//    else
//    {
//        self.alpha= 0.0f;
//        [super setHidden:hidden];
//        [UIView beginAnimations:@"fadeIn" context:nil];
//        [UIView setAnimationDuration:0.7];
//        self.alpha= 1.0f;
//        [UIView commitAnimations];
//    }
//}

-(void)animationStop
{
    [super setHidden:!self.hidden];
}

@end
