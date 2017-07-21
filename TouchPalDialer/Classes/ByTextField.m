//
//  ByTextField.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/7/21.
//
//

#import "ByTextField.h"

@implementation ByTextField
{
    int mLeft;
    int mRight;
    int mTop;
    int mBottom;
}

-(void)setPadding : (int)left right : (int)right top : (int)top bottom : (int )bottom
{
    mLeft = left;
    mRight = right;
    mTop = top;
    mBottom = bottom;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + mLeft,
                          bounds.origin.y  + mTop,
                          bounds.size.width - mRight, bounds.size.height - mBottom);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}


@end
