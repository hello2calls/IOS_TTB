//
//  TPTextFlowView.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/26/12.
//
//

#import "TPTextFlowView.h"

@interface TPTextFlowView(){
    NSTimer *timer_;
    BOOL needFlow_;
    
    //accumulated xOffest
    CGFloat xOffset_;
    
    //one line text size
    CGSize textSize_;
    NSTextAlignment textAlignment_;
    
    CGFloat spaceWidth_;
    NSTimeInterval timeInterval_;
    
    BOOL firstLoop_;
}

@property (nonatomic, retain) UIFont *font;

@end

@implementation TPTextFlowView
@synthesize text = text_;
@synthesize textColor = textColor_;
@synthesize font = font_;

- (id)initWithFrame:(CGRect)frame
               text:(NSString *)text
          textColor:(UIColor *)textColor
      textAlignment:(NSTextAlignment)textAlignment
               font:(UIFont *)font
         spaceWidth:(CGFloat)spaceWidth
       timeInterval:(NSTimeInterval)interval
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = font;
        self.backgroundColor = [UIColor clearColor];
        textAlignment_ = textAlignment;
        spaceWidth_ = spaceWidth >= 0.0f ? spaceWidth : 0.0f;
        timeInterval_ = interval >= 0.0f ? interval : 0.1f;
        self.clipsToBounds = YES;
        [self setTextColor:textColor];
        [self setText:text];
    }
    return self;
}

-(void)setText:(NSString *)text
{
    text_ = [text copy];
    
    // check if it needs flow
    textSize_ = [self computeTextSize:text];
    if (textSize_.width > self.frame.size.width) {
        [self stopTimer];
        needFlow_ = YES;
        xOffset_ = 0.0f;
        [self performSelector:@selector(startTimer) withObject:nil afterDelay:2.0f];
    } else {
        [self stopTimer];
    }
    [self setNeedsDisplay];
}

-(void)setTextColor:(UIColor *)textColor
{
    textColor_ = textColor;
    [self setNeedsDisplay];
}

- (CGRect)moveNewPoint:(CGPoint)point rect:(CGRect)rect
{
    CGSize tmpSize;
    tmpSize.height = rect.size.height + (rect.origin.y - point.y);
    tmpSize.width = textSize_.width;
    return CGRectMake(point.x, point.y, tmpSize.width, tmpSize.height);
}

- (CGRect)getAnotherRectWithRect:(CGRect)rect{
    return CGRectMake(textSize_.width+spaceWidth_+rect.origin.x, rect.origin.y, textSize_.width, rect.size.width);
}

- (void)startTimer
{
    [self stopTimer];
    needFlow_ = YES;
    xOffset_ = 0.0f;
    firstLoop_ = YES;
    timer_ = [NSTimer scheduledTimerWithTimeInterval:timeInterval_
                                              target:self
                                            selector:@selector(timerJob)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopTimer
{
    needFlow_ = NO;
    if (timer_) {
        [timer_ invalidate];
        timer_ = nil;
        [self setNeedsDisplay];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)timerJob
{
    if (firstLoop_ == YES && xOffset_ == 0.0f) {
        firstLoop_ = NO;
    } else if (firstLoop_ == NO && xOffset_ == 0.0f) {
        [self stopTimer];
        return;
    }
    
    CGFloat offsetOnce = -1.0f;
    xOffset_ += offsetOnce;
    if (xOffset_ +  textSize_.width <= 0) {
        xOffset_ += textSize_.width;
        xOffset_ += spaceWidth_;
    }
    [self setNeedsDisplay];
}

- (CGSize)computeTextSize:(NSString *)text
{
    if (text == nil) {
        return CGSizeMake(0, 0);
    }
    CGSize boundSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
//    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    NSDictionary *tdic = @{NSFontAttributeName:font_, NSParagraphStyleAttributeName:paragraphStyle};
//    CGSize stringSize = [text_ boundingRectWithSize:boundSize
//                                            options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                         attributes:tdic
//                                            context:nil].size;
    
    CGSize stringSize = [text_ sizeWithFont:font_
                          constrainedToSize:boundSize
                              lineBreakMode:NSLineBreakByWordWrapping];
    return stringSize;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context= UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, textColor_.CGColor);
    // Drawing code
    CGFloat y = (rect.size.height - textSize_.height)/2;
    if (needFlow_ == YES) {
        rect = [self moveNewPoint:CGPointMake(xOffset_, y) rect:rect];
//        NSDictionary *tdic;
//        if (textColor_){
//            tdic = @{NSFontAttributeName:font_,NSForegroundColorAttributeName:textColor_};
//        }else{
//            tdic = @{NSFontAttributeName:font_};
//        }
//        [text_ drawInRect:rect withAttributes:tdic];
        [text_ drawInRect:rect withFont:font_];
        if(rect.origin.x+rect.size.width < self.frame.size.width-spaceWidth_){
            CGRect rect2 = [self getAnotherRectWithRect:rect];
            [text_ drawInRect:rect2 withFont:font_];
            //[text_ drawInRect:rect2 withAttributes:tdic];
        }
    }
    else {
        CGPoint origin = rect.origin;
        origin.y = (rect.size.height - textSize_.height)/2;
        if (textAlignment_ == NSTextAlignmentCenter) {
            origin.x = (rect.size.width - textSize_.width)/2;
        } else if (textAlignment_ == NSTextAlignmentRight) {
            origin.x = (rect.size.width - textSize_.width);
        }
        if (origin.x < 0) {
            origin.x = 0;
        }
        rect.origin = origin;
        rect.size.height = textSize_.height;
        
//        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//        NSDictionary *tdic;
//        if (textColor_){
//            tdic = @{NSFontAttributeName:font_, NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:textColor_};
//        }else{
//            tdic = @{NSFontAttributeName:font_, NSParagraphStyleAttributeName:paragraphStyle};
//        }
//        
//        [text_ drawInRect:rect withAttributes:tdic];
        [text_ drawInRect:rect withFont:font_ lineBreakMode:NSLineBreakByTruncatingTail];
    }
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self setText:text_];
    } else {
        [self stopTimer];
    }
}

@end
