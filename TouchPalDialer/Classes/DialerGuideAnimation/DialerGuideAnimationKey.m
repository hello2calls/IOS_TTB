//
//  DialerGuideAnimationKey.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/19.
//
//

#import "DialerGuideAnimationKey.h"
#import "TPDialerResourceManager.h"

@interface DialerGuideAnimationKey(){
    
}

@end

@implementation DialerGuideAnimationKey

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self drawLetter];
}

- (void)drawLetter{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[[TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"] CGColor]);
    float top = self.frame.size.height/8;
    float fontSize = _firstSize == 0 ? FONT_SIZE_0_KEY : _firstSize;
    [_firstLetter drawInRect:CGRectMake(self.frame.size.width/4, top, self.frame.size.width/2, fontSize)
                    withFont:[UIFont fontWithName:@"Helvetica-Light" size:fontSize]
               lineBreakMode:NSLineBreakByClipping
                   alignment:NSTextAlignmentCenter];
    
    if (_secondLetter != nil && ![_secondLetter isEqualToString:@""]){
        CGContextSetFillColorWithColor(context,[[TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"] CGColor]);
        CGFloat letterTop = top + 28;
        CGFloat letterSize = _subSize == 0 ? FONT_SIZE_7 : _subSize;
        
        [_secondLetter drawInRect:CGRectMake(self.frame.size.width/4, letterTop, self.frame.size.width/2, letterSize)
                         withFont:[UIFont fontWithName:@"Helvetica-Light" size:letterSize]
                    lineBreakMode:NSLineBreakByClipping
                        alignment:NSTextAlignmentCenter];
    }
}





@end
