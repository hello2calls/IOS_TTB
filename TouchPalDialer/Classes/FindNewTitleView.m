//
//  FindNewTitleView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/31.
//
//

#import "FindNewTitleView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "NSString+Draw.h"

@implementation FindNewTitleView

static UIFont *sTextFont;
static NSMutableParagraphStyle *sParaStyle;


#define LINE_HEIGHT_MULTIPLE (1.1)

+ (void) load {
    [super load];
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        CGFloat titleSize = FIND_NEWS_NEW_TITLE_SIZE;
        if (isIPhone6Resolution()) {
            if (WIDTH_ADAPT <= 1) {
                titleSize -= 1;
            } else if ( WIDTH_ADAPT > 1.1) {
                titleSize += 1;
            }
        }
        if ([[UIDevice currentDevice].systemVersion intValue] >= 9) {
            sTextFont = [UIFont fontWithName:@"PingFangSC-Regular" size:titleSize];
        } else {
            sTextFont = [UIFont systemFontOfSize:titleSize];
        }
        
        sParaStyle= [[NSMutableParagraphStyle alloc] init];
        sParaStyle.lineBreakMode = NSLineBreakByWordWrapping;
        sParaStyle.lineHeightMultiple = LINE_HEIGHT_MULTIPLE;
        sParaStyle.alignment = NSTextAlignmentLeft;
    });
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSString* colorString = FIND_NEWS_TITLE_COLOR;
    if(self.isClicked) {
        colorString = FIND_NEWS_TITLE_CLICKED_COLOR;
    }
    UIColor *textColor = [ImageUtils colorFromHexString:colorString
                                        andDefaultColor:nil];
    
    NSDictionary* titleAttr = @{
             NSFontAttributeName: sTextFont,
             NSForegroundColorAttributeName: textColor,
             NSParagraphStyleAttributeName: [sParaStyle copy]};

    CGSize title = [self.title sizeWithFont:sTextFont
                          constrainedToSize:rect.size
                              lineBreakMode:NSLineBreakByCharWrapping];
    
    CGRect drawingRect = CGRectMake(rect.origin.x, rect.origin.y,
                                    title.width, title.height * LINE_HEIGHT_MULTIPLE) ;
    
    [self.title drawInRect:drawingRect
            withAttributes:titleAttr
                  withFont:sTextFont
             lineBreakMode:NSLineBreakByCharWrapping
                 alignment:NSTextAlignmentLeft
                   UIColor:textColor];
}

+(CGFloat) getHeightByTitle:(NSString *)title withWidth:(CGFloat) width
{
    CGSize oneLineSize = [@"a" sizeWithFont:sTextFont
                          constrainedToSize:CGSizeMake(width, 200)
                              lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize sizeTitle = [title sizeWithFont:sTextFont
                         constrainedToSize:CGSizeMake(width, oneLineSize.height * 2 + 5)
                             lineBreakMode:NSLineBreakByCharWrapping];
    
    // hack for iPhone 5s
    if (isIPhone6Resolution()) {
        return sizeTitle.height;
    } else {
        return sizeTitle.height + 4;
    }
}

+(CGFloat) getHeightByTitle:(NSString *)title withWidth:(CGFloat) width withLines:(NSInteger) lines
{
    CGSize oneLineSize = [@"a" sizeWithFont:sTextFont
                          constrainedToSize:CGSizeMake(width, 200)
                              lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize sizeTitle = [title sizeWithFont:sTextFont
                         constrainedToSize:CGSizeMake(width, oneLineSize.height * lines + 5)
                             lineBreakMode:NSLineBreakByCharWrapping];
    
    // hack for iPhone 5s
    if (isIPhone6Resolution()) {
        return sizeTitle.height;
    } else {
        return sizeTitle.height + 4;
    }
}

@end
