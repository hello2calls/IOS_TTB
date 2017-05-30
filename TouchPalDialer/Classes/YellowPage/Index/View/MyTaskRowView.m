//
//  MyTaskRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/8.
//
//

#import "MyTaskRowView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "CTUrl.h"
#import "NSString+Draw.h"
#import "PublicNumberMessageView.h"
#import "AccountInfoManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"

@implementation MyTaskRowView

- (id)initWithFrame:(CGRect)frame andData:(SectionMyTask*)data andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animationView = [[MyTaskAnimationView alloc]initWithFrame:self.bounds];
       
        self.task = [data.items objectAtIndex:indexPath.row];
        self.animationView.task = self.task;
        self.path = indexPath;
        self.animationView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.animationView];
    }
    
    [self drawView];
    [self setTag:MY_TASK];
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
   
    //highlight
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:CATEGORY_CELL_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    
    CGFloat fromX = MY_TASK_LEFT_MARGIN;
    CGFloat fromY = 0;
    CGFloat toY = rect.size.height;
    CGFloat toX = rect.size.width - MY_TASK_LEFT_MARGIN;
    
    //draw left line
//    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_TASK_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:fromY andToX:fromX andToY:toY andWidth:MY_TASK_BORDER_WIDTH];
    
    //draw top line
    if (self.path.row != 0) {
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_TASK_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:fromY andToX:toX andToY:fromY andWidth:MY_TASK_BORDER_WIDTH];
    }

    
    //draw bottom line
//    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_TASK_BORDER_COLOR andDefaultColor:nil] andFromX:fromX andFromY:toY andToX:toX andToY:toY andWidth:MY_TASK_BORDER_WIDTH];
    //draw right line
//    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:toX andFromY:fromY andToX:toX andToY:toY andWidth:MY_TASK_BORDER_WIDTH];
    
}


-(void)drawView
{
    [self setNeedsDisplay];
    [self.animationView drawView];
}

- (void) doClick
{
    [self.task.ctUrl startWebView];
    [[AccountInfoManager instance] setRequestAccountInfo:YES];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CLICK_PROFIT_TASK kvs:Pair(@"action", @"selected"), nil];
}

@end
