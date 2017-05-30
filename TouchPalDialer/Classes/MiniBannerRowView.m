//
//  MiniBannerRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 16/1/25.
//
//

#import "MiniBannerRowView.h"
#import "MiniBannerItem.h"
#import "SectionMiniBanner.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "ImageUtils.h"
#import "NSString+Draw.h"
#import "CTUrl.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "CootekNotifications.h"
#import "UpdateService.h"
#import "EdurlManager.h"
#import "UserDefaultsManager.h"

@interface MiniBannerRowView(){
    MiniBannerItem* _item;
    UIImage* _image;
}

@end
@implementation MiniBannerRowView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}
- (void) resetDataWithItem:(SectionMiniBanner*)item andIndexPath:(NSIndexPath*)indexPath
{
    if (item.items.count > 0) {
        _item = [item.items objectAtIndex:0];
        //set icon
        _image = [ImageUtils getImageFromLocalWithUrl:_item.iconLink];
        
        if (!_image) {
            [ImageUtils getImageFromUrl:_item.iconLink success:^(UIImage *image) {
                _image = image;
                [self setNeedsDisplay];
            } failed:^{
                _image = nil;
            }];
        }
        
        if (_item.edMonitorUrl) {
            [[EdurlManager instance] requestEdurl:_item.edMonitorUrl];
        }
    } else {
        _item = nil;
        _image = nil;
    }
    
}


- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat redPointWidth = MINI_BANNER_REDPOINT_WIDTH;
    CGFloat cornerRadius = MINI_BANNER_CONRER_RADIUS;
    
    //get image size
    CGFloat iconTargetHeight = MINI_ROW_HEIGHT - 8;
    CGFloat iconTargetWidth = _image? (_image.size.width * iconTargetHeight / _image.size.height) : 0;

    
    //get text size
    CGFloat maxTextSize = rect.size.width - iconTargetWidth - 10 - redPointWidth - 2 * cornerRadius;
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary* titleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIFont systemFontOfSize:MINI_BANNER_TEXT_SIZE], NSFontAttributeName,[ImageUtils colorFromHexString:MINI_BANNER_TEXT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    CGSize title = [_item.title sizeWithFont:[UIFont systemFontOfSize:MINI_BANNER_TEXT_SIZE] constrainedToSize:CGSizeMake(maxTextSize, INDEX_ROW_HEIGHT_MINI_BANNER) lineBreakMode:NSLineBreakByTruncatingTail];
    
    
       //画圆角矩形
    CGFloat width = title.width + iconTargetWidth + 36 + redPointWidth;
    CGFloat height = MINI_ROW_HEIGHT;
    CGFloat startX = (rect.size.width - width) / 2;
    CGFloat startY = (INDEX_ROW_HEIGHT_MINI_BANNER - MINI_ROW_HEIGHT) / 2;
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        startY = (self.frame.size.height - MINI_ROW_HEIGHT) / 2;
    }
    
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = MINI_ROW_HEIGHT / 2;
    
    // 移动到初始点
    CGContextMoveToPoint(context, startX + radius, startY);
    
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, startX + width - radius, startY);
    CGContextAddArc(context, startX + width - radius, startY + radius, radius, -0.5 * M_PI, 0.0, 0);
    
    // 绘制第2条线和第2个1/4圆弧
    CGContextAddLineToPoint(context, startX + width, startY + height - radius);
    CGContextAddArc(context, startX + width - radius, startY + height - radius, radius, 0.0, 0.5 * M_PI, 0);
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextAddLineToPoint(context, startX + radius, startY + height);
    CGContextAddArc(context, startX + radius, startY + height - radius, radius, 0.5 * M_PI, M_PI, 0);
    
    // 绘制第4条线和第4个1/4圆弧
    CGContextAddLineToPoint(context, startX, startY + radius);
    CGContextAddArc(context, startX + radius, startY + radius, radius, M_PI, 1.5 * M_PI, 0);
    
    // 闭合路径
    CGContextClosePath(context);
    
    // 填充背景色
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:MINI_BANNER_HIGHLIGHT_BG andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:MINI_BANNER_BG andDefaultColor:nil].CGColor);
    }
    CGContextDrawPath(context, kCGPathFill);
 
    CGFloat startImgX = startX + 16;
    CGFloat startImgY = (rect.size.height - iconTargetHeight) / 2;
    //draw image
    if (_image) {
        [_image drawInRect:CGRectMake(startImgX, startImgY, iconTargetWidth, iconTargetHeight)];
    }
    
    //draw Text
    CGFloat startTextX = startImgX + iconTargetWidth + 4;
    CGFloat startTextY = (rect.size.height - title.height) / 2;
    [_item.title drawInRect:CGRectMake(startTextX, startTextY, title.width, title.height) withAttributes:titleAttr withFont:[UIFont systemFontOfSize:MINI_BANNER_TEXT_SIZE] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft UIColor:[ImageUtils colorFromHexString:MINI_BANNER_TEXT_COLOR andDefaultColor:nil]];
    
    //draw redPoint
    CGFloat pointX = startTextX + title.width + redPointWidth / 2 + 4;
    CGFloat pointY = rect.size.height / 2;
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil].CGColor);
    CGContextSetLineWidth(context, 0);
    CGContextAddArc(context, pointX, pointY, RED_POINT_RADIUS, 0, 360, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void) doClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_REQUEST_SUCCESS object:nil userInfo:nil];
    [_item startWebView];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_MINI_BANNER_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title",_item.title), Pair(@"url",_item.ctUrl.url), nil];
   
    [[EdurlManager instance] sendCMonitorUrl:_item];
}

@end
