//
//  FindHeaderView.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/14.
//
//

#import "FindHeaderView.h"
#import "IndexConstant.h"
#import "ImageUtils.h"

@implementation FindHeaderView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)];
        self.title.textAlignment = NSTextAlignmentLeft;
        self.title.verticalAlignment = VerticalAlignmentMiddle;
        self.title.font = [UIFont systemFontOfSize:FIND_TITLE_SIZE];
        self.title.textColor = [ImageUtils colorFromHexString:COMMON_TITLE_TEXT_COLOR andDefaultColor:nil];
        self.rightTopView = [[RightTopView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];
        [self addSubview:self.title];
        [self addSubview:self.rightTopView];
    }
    return self;
}

-(void) drawViewWithTitle:(NSString* )title withColor:(NSString *)color andRightTopItem:(RightTopItem *)item
{
    self.title.text = title;
    
    [self.rightTopView drawView:item];
}

@end
