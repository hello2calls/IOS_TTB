//
//  MyTaskBtnRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/8.
//
//

#import "MyTaskBtnRowView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "NSString+Draw.h"
#import "CTUrl.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "AccountInfoManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "TPFilterRecorder.h"

@implementation MyTaskBtnRowView


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    [self setTag:MT_TASK_BTN_TAG];
    return self;
}


-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGPoint topLeft = CGPointMake((rect.size.width - INDEX_ROW_WIDTH_MY_TASK_BTN) / 2, 0);

    CGPoint bottomRight = CGPointMake((rect.size.width + INDEX_ROW_WIDTH_MY_TASK_BTN) / 2, MY_TASK_BTN_HEIGHT);
    if (self.pressed) {
        topLeft = CGPointMake((rect.size.width - INDEX_ROW_WIDTH_MY_TASK_BTN) / 2, 0);
        bottomRight = CGPointMake((rect.size.width + INDEX_ROW_WIDTH_MY_TASK_BTN) / 2, MY_TASK_BTN_HEIGHT);
    }
    CGFloat radius = MY_TASK_BTN_HEIGHT / 2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef bgColor = self.btnBgColor.CGColor;
    
    if (self.pressed) {
        bgColor = self.btnPressBgColor.CGColor;
    }
    CGContextSetFillColorWithColor(context, bgColor);
    
    UIColor* color = [ImageUtils colorFromHexString:MY_TASK_BTN_TEXT_COLOR andDefaultColor:nil];
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(context,red,green,blue,alpha);
    CGContextSetLineWidth(context, 0.5f);
   
    [ImageUtils drawArcRectangleWithContext:context andPointTopLeft:topLeft andPointBottomRight:bottomRight andRadius:radius];


    
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    
    UIFont* font = [UIFont fontWithName:IPHONE_ICON_2 size:FIND_NEWS_TITLE_SIZE];
    NSDictionary* titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                               font, NSFontAttributeName,color, NSForegroundColorAttributeName,paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    CGSize title = [self.btnText sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, rect.size.height) lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat startX = topLeft.x + (INDEX_ROW_WIDTH_MY_TASK_BTN - title.width) / 2;
    CGFloat startY = topLeft.y + (MY_TASK_BTN_HEIGHT - title.height) / 2;
    
    [self.btnText drawInRect:CGRectMake(startX, startY, title.width, title.height) withAttributes:titleAttr withFont:[UIFont systemFontOfSize:FIND_NEWS_TITLE_SIZE] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft UIColor:color];
    
    
    //    CGFloat toY = (bottomRight.y- topLeft.y - 3) / 2;
    //    CGFloat endX = rect.size.width - MY_PROPERTY_LEFT_MARGIN - 1;
    //draw left line
    //    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:CATEGORY_BORDER_COLOR andDefaultColor:nil] andFromX:MY_PROPERTY_LEFT_MARGIN andFromY:0 andToX:MY_PROPERTY_LEFT_MARGIN andToY:toY andWidth:MY_TASK_BTN_BORDER_WIDTH];
    //draw right line
    //    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_PROPERTY_BORDER_COLOR andDefaultColor:nil] andFromX:endX andFromY:0 andToX:endX andToY:toY andWidth:MY_TASK_BTN_BORDER_WIDTH];
    //draw bottom left line
    //    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_PROPERTY_BORDER_COLOR andDefaultColor:nil] andFromX:MY_PROPERTY_LEFT_MARGIN andFromY:toY andToX:topLeft.x andToY:toY andWidth:MY_TASK_BTN_BORDER_WIDTH];
    
    //draw bottom right line
    //    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MY_PROPERTY_BORDER_COLOR andDefaultColor:nil] andFromX:bottomRight.x andFromY:toY andToX:endX andToY:toY andWidth:MY_TASK_BTN_BORDER_WIDTH];
}

- (void) drawView
{
    NSString* text = @"立即登录，查看我的钱包";
    self.btnBgColor = [ImageUtils colorFromHexString:MY_TASK_BG_UNLOGGED_COLOR andDefaultColor:nil];
    self.btnPressBgColor = [ImageUtils colorFromHexString:MY_TASK_BG_PRESS_UNLOGGED_COLOR andDefaultColor:nil];
    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        text = @"做任务 赢奖励";
        self.btnBgColor = [ImageUtils colorFromHexString:MY_TASK_BG_COLOR andDefaultColor:nil];
        self.btnPressBgColor = [ImageUtils colorFromHexString:MY_TASK_PRESS_BG_COLOR andDefaultColor:nil];
    }
    
    self.btnText = text;
    
    [self setNeedsDisplay];
}

- (void) doClick
{
    CTUrl* cturl;
    if (USE_DEBUG_SERVER) {
        cturl = [[CTUrl alloc] initWithUrl:[NSString stringWithFormat:@"%@/page_v3/profit_center.html", YP_DEBUG_SERVER]];
    } else {
        cturl = [[CTUrl alloc] initWithUrl:[NSString stringWithFormat:@"%@/page_v3/profit_center.html", SEARCH_SITE]];
    }
    cturl.needWrap = YES;
    cturl.needTitle = YES;
    cturl.nativeParams = [[NSArray alloc] initWithObjects:@"_city",@"_lat",@"_lng",@"_addr", nil];
    [cturl startWebView];
    [[AccountInfoManager instance] setRequestAccountInfo:YES];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_CLICK_PROFIT_BUTTON kvs:Pair(@"action", @"selected"), nil];
    
    //还未登录
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO]) {
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_FROM, LOGIN_FROM_TAB_WALLET), nil];
    }
}

@end
