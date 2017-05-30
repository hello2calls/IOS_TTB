//
//  FeatureTipsLabel.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeatureTipsLabel.h"

@implementation FeatureTipsLabel

- (id)initWithFrame:(CGRect)frame withLeftImage:(UIImage *)leftImage withRightImage:(UIImage *)rightImage withTitleString:(NSString *) title withUITextAligment:(TipsLabelTextAligment)aligment
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat leftWidth = leftImage.size.width;
        CGFloat rightWidth = rightImage.size.width;
        
//        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingHead;
//        NSDictionary *tdic = @{NSFontAttributeName:[UIFont systemFontOfSize:CELL_FONT_INPUT], NSParagraphStyleAttributeName:paragraphStyle};
//        CGSize size = [title boundingRectWithSize:CGSizeMake(self.frame.size.width,self.frame.size.height)
//                                              options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                           attributes:tdic
//                                              context:nil].size;
        
        
        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:CELL_FONT_INPUT]  constrainedToSize:CGSizeMake(self.frame.size.width,self.frame.size.height) lineBreakMode:NSLineBreakByTruncatingHead];
        CGFloat middleWidth = size.width;
        
        CGFloat startX = 0.0;
        switch (aligment) {
            case LabelTextAligmentLeft:
                startX = 0.0;
                break;
            case LabelTextAligmentCenter:
                startX = (self.frame.size.width - (leftWidth + middleWidth + rightWidth))/2;
                break;
            case LabelTextAligmentRight:
                startX = self.frame.size.width - (leftWidth + middleWidth + rightWidth);
                break;    
            default:
                break;
        }
        CGRect rect = CGRectMake(startX, 0, leftWidth, self.frame.size.height);
        
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:rect];
        leftView.image = leftImage;
        [self addSubview:leftView];
        
        rect = CGRectMake(startX +leftWidth, 0, middleWidth, self.frame.size.height);
        UILabel* labelDraw = [[UILabel alloc] initWithFrame:rect];
        labelDraw.textColor = [UIColor colorWithRed:COLOR_IN_256(255.0) green:COLOR_IN_256(255.0) blue:COLOR_IN_256(255.0) alpha:1.0];
        labelDraw.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
        labelDraw.textAlignment = NSTextAlignmentCenter;
        labelDraw.backgroundColor = [UIColor clearColor];
        labelDraw.text = title;
        [self addSubview:labelDraw];
        
        rect = CGRectMake(startX +leftWidth + middleWidth, 0, rightWidth, self.frame.size.height);
        UIImageView *rightView = [[UIImageView alloc] initWithFrame:rect];
        rightView.image = rightImage;
        [self addSubview:rightView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
