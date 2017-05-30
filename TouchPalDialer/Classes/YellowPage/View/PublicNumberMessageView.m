//
//  FuwuhaoMessageView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import "PublicNumberMessageView.h"
#import "PublicNumberMessage.h"
#import "NSString+Color.h"
#import "PushConstant.h"
#import "ImageUtils.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "NSString+Draw.h"
#import "ControllerManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "NSDictionary+Default.h"

@implementation PublicNumberMessageView {
    PublicNumberMessage *_message;
}

@synthesize title;
@synthesize desc;
@synthesize keynotesAreas;
@synthesize remark;
@synthesize message;
@synthesize url;
@synthesize dateLabel;
@synthesize nativeUrl;

-(id) initWithFrame:(CGRect)frame withPublicNumberMsg:(PublicNumberMessage*)msg
{
    self = [super initWithFrame:frame];
    [self setTag:LIST_ITEM_FUWUHAO_DETAIL_TAG];
    
    dateLabel = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, MSG_ITEM_DETAIL_DATE_HEIGHT)];
    [dateLabel setFont:[UIFont boldSystemFontOfSize:12]];
    dateLabel.verticalAlignment = VerticalAlignmentMiddle;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.textColor = [ImageUtils colorFromHexString:MSG_ITEM_DETAIL_DATE_TEXT_COLOR andDefaultColor:nil];
    dateLabel.backgroundColor = [UIColor clearColor];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
    NSDate *dateTarget = [NSDate dateWithTimeIntervalSince1970:[msg.createTime integerValue]];
    [dateLabel setText:[dateFormatter stringFromDate:dateTarget]];
    [self addSubview:dateLabel];
    self.backgroundColor = [UIColor clearColor];
    [self drawView:msg];
    return self;
}


+(CGSize) getSizeByText:(NSString* )text andUIFont:(UIFont *)font
{
    CGSize sizeTitle = [text sizeWithFont:font constrainedToSize:CGSizeMake(TPScreenWidth() - 2 * MSG_ITEM_BG_DETAIL_MARGIN - 2 * MSG_ITEM_DETAIL_LEFT, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
    return sizeTitle;
}


+(CGSize) getSizeByText:(NSString* )text andUIFont:(UIFont *)font andWidth:(CGFloat)width
{
    CGSize sizeTitle = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
    return sizeTitle;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    CGFloat offsetHeight = MSG_ITEM_DETAIL_DATE_HEIGHT;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint bgLeftTop = CGPointMake(MSG_ITEM_BG_DETAIL_MARGIN, offsetHeight);
    CGPoint bgRightBottom = CGPointMake(rect.size.width - MSG_ITEM_BG_DETAIL_MARGIN, rect.size.height - 5);
    CGContextSetLineWidth(context, 0.2);
    //highlight
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:LIST_ITEM_BG_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }

   [ImageUtils drawArcRectangleWithContext:context andPointTopLeft:bgLeftTop  andPointBottomRight:bgRightBottom andRadius:6];
    
    //draw date rect
    CGContextSetLineWidth(context, 0);
    CGPoint leftTop = CGPointMake((rect.size.width - MSG_ITEM_DETAIL_DATE_RECT_WIDTH) / 2, (MSG_ITEM_DETAIL_DATE_HEIGHT - MSG_ITEM_DETAIL_DATE_RECT_HEIGHT) / 2);
    CGPoint rightBottom = CGPointMake(leftTop.x + MSG_ITEM_DETAIL_DATE_RECT_WIDTH, leftTop.y + MSG_ITEM_DETAIL_DATE_RECT_HEIGHT);
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:MSG_ITEM_DETAIL_DATE_BG_COLOR andDefaultColor:nil].CGColor);
    [ImageUtils drawArcRectangleWithContext:context andPointTopLeft:leftTop  andPointBottomRight:rightBottom andRadius:3];
    
    //draw title
    NSString* titleStr = self.title;
    
    offsetHeight = offsetHeight + MSG_ITEM_DETAIL_MARGIN;
    if (titleStr.length > 0) {
        offsetHeight = offsetHeight + MSG_ITEM_TITLE_TOP;
        NSDictionary* attrTitle = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont boldSystemFontOfSize:18], NSFontAttributeName,[UIColor blackColor], NSForegroundColorAttributeName,nil];
        
        CGSize sizeTitle = [PublicNumberMessageView getSizeByText:titleStr andUIFont:[UIFont boldSystemFontOfSize:18]];
        
        [titleStr drawInRect:CGRectMake(MSG_ITEM_BG_DETAIL_MARGIN + MSG_ITEM_DETAIL_LEFT, offsetHeight + MSG_ITEM_DETAIL_TOP, bgRightBottom.x - bgLeftTop.x - MSG_ITEM_DETAIL_LEFT * 2, sizeTitle.height + 2 * MSG_ITEM_DETAIL_TOP) withAttributes:attrTitle withFont:[UIFont boldSystemFontOfSize:18] UIColor:[UIColor blackColor]];
        offsetHeight = offsetHeight + sizeTitle.height + 2 * MSG_ITEM_DETAIL_TOP + 2;
    }
    
    //draw description
    NSString* description = [desc stringForKey:@"value"];
    if (description.length > 0) {
        offsetHeight = offsetHeight + MSG_ITEM_DESC_TOP;
        NSDictionary* attrDescription = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont systemFontOfSize:16], NSFontAttributeName,[ImageUtils colorFromHexString:[self.desc stringForKey:@"color"] andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
        
        CGSize sizeDesc = [PublicNumberMessageView getSizeByText:description andUIFont:[UIFont systemFontOfSize:16]];
        
        [description drawInRect:CGRectMake(MSG_ITEM_BG_DETAIL_MARGIN + MSG_ITEM_DETAIL_LEFT, offsetHeight + MSG_ITEM_DETAIL_TOP, bgRightBottom.x - bgLeftTop.x - MSG_ITEM_DETAIL_LEFT * 2, sizeDesc.height + 2 * MSG_ITEM_DETAIL_TOP) withAttributes:attrDescription withFont:[UIFont systemFontOfSize:16] UIColor:[ImageUtils colorFromHexString:[self.desc stringForKey:@"color"] andDefaultColor:[UIColor blackColor]]];
        offsetHeight = offsetHeight + sizeDesc.height + 2 * MSG_ITEM_DETAIL_TOP + 10;
        

    }
       //draw keynote
    for (NSDictionary* dictionary in keynotesAreas) {
        NSString* keynoteTitle = [NSString stringWithFormat:@"%@: ", [dictionary stringForKey:@"key"]];
        NSString* keynote = [dictionary stringForKey:@"value" ];
        
        if (keynoteTitle.length == 0) {
            continue;
        }
       
        CGSize sizeKeynoteTitle = [PublicNumberMessageView getSizeByText:keynoteTitle andUIFont:[UIFont systemFontOfSize:16]];
        
        CGFloat width = TPScreenWidth() - 2 * MSG_ITEM_BG_DETAIL_MARGIN - 2 * MSG_ITEM_DETAIL_LEFT - sizeKeynoteTitle.width;

        CGSize sizeKeynote = [PublicNumberMessageView getSizeByText:keynote andUIFont:[UIFont systemFontOfSize:16] andWidth:width];
        
        NSDictionary* attrKeynoteTitle = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont systemFontOfSize:16], NSFontAttributeName,[ImageUtils colorFromHexString:MSG_ITEM_KEYNOTE_TITLE_TEXT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,nil];
        
        NSDictionary* attrKeynote = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont systemFontOfSize:16], NSFontAttributeName,[ImageUtils colorFromHexString:[dictionary stringForKey:@"color"] andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
        
        [keynoteTitle drawInRect:CGRectMake(MSG_ITEM_BG_DETAIL_MARGIN + MSG_ITEM_DETAIL_LEFT, offsetHeight + MSG_ITEM_DETAIL_TOP, sizeKeynoteTitle.width, sizeKeynote.height + 2 * MSG_ITEM_DETAIL_TOP) withAttributes:attrKeynoteTitle withFont:[UIFont systemFontOfSize:16] UIColor:[ImageUtils colorFromHexString:[dictionary stringForKey:@"color"] andDefaultColor:[UIColor blackColor]]];
        
        [keynote drawInRect:CGRectMake(MSG_ITEM_BG_DETAIL_MARGIN + MSG_ITEM_DETAIL_LEFT + sizeKeynoteTitle.width, offsetHeight + MSG_ITEM_DETAIL_TOP, bgRightBottom.x - bgLeftTop.x - MSG_ITEM_DETAIL_LEFT * 2 - sizeKeynoteTitle.width, sizeKeynote.height + 2 * MSG_ITEM_DETAIL_TOP) withAttributes:attrKeynote withFont:[UIFont systemFontOfSize:16] UIColor:[ImageUtils colorFromHexString:[dictionary stringForKey:@"color"] andDefaultColor:[UIColor blackColor]]];
       
        CGFloat keynoteHeight = sizeKeynote.height > sizeKeynoteTitle.height ? sizeKeynote.height : sizeKeynoteTitle.height;
        
        offsetHeight = offsetHeight + keynoteHeight + 2 * MSG_ITEM_DETAIL_TOP;
    }
    
    //draw remark
    NSString* remarkStr = [self.remark stringForKey:@"value"];

    if (remarkStr.length > 0) {
        offsetHeight = offsetHeight + MSG_ITEM_REMARK_TOP;
        NSDictionary* attrRemark = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:16], NSFontAttributeName,[ImageUtils colorFromHexString:[self.remark stringForKey:@"color"] andDefaultColor:[UIColor blackColor]], NSForegroundColorAttributeName,nil];
        
        CGSize sizeRemark = [PublicNumberMessageView getSizeByText:remarkStr andUIFont:[UIFont systemFontOfSize:16]];
        
        [remarkStr drawInRect:CGRectMake(MSG_ITEM_BG_DETAIL_MARGIN + MSG_ITEM_DETAIL_LEFT, offsetHeight + MSG_ITEM_DETAIL_TOP, bgRightBottom.x - bgLeftTop.x - MSG_ITEM_DETAIL_LEFT * 2, sizeRemark.height + 2 * MSG_ITEM_DETAIL_TOP) withAttributes:attrRemark withFont:[UIFont systemFontOfSize:16] UIColor:[ImageUtils colorFromHexString:[self.remark stringForKey:@"color"] andDefaultColor:[UIColor blackColor]]];
        offsetHeight = offsetHeight + sizeRemark.height + 2 * MSG_ITEM_DETAIL_TOP;
    }
    
    if ([url isValid] || [self.nativeUrl allKeys].count > 0) {
        offsetHeight = offsetHeight + 10;
        [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MSG_ITEM_SPERATE_BORDER_COLOR andDefaultColor:nil] andFromX:MSG_ITEM_BG_DETAIL_MARGIN + 5 andFromY:offsetHeight andToX:TPScreenWidth() - 5 - MSG_ITEM_BG_DETAIL_MARGIN andToY:offsetHeight andWidth:1];
        NSString* more = @"查看详情";
        NSDictionary* attrMore = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:14], NSFontAttributeName,[ImageUtils colorFromHexString:MSG_ITEM_MORE_TEXT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,nil];
        CGSize sizeMore = [PublicNumberMessageView getSizeByText:more andUIFont:[UIFont systemFontOfSize:14]];
        [more drawInRect:CGRectMake(MSG_ITEM_BG_DETAIL_MARGIN + MSG_ITEM_DETAIL_LEFT, offsetHeight + (MSG_ITEM_MORE_HEIGHT - sizeMore.height) / 2 - 2, sizeMore.width, MSG_ITEM_MORE_HEIGHT) withAttributes:attrMore withFont: [UIFont systemFontOfSize:14] UIColor:[ImageUtils colorFromHexString:MSG_ITEM_MORE_TEXT_COLOR andDefaultColor:nil]];
        
        NSDictionary* attrMoreIcon = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont fontWithName:IPHONE_ICON_2 size:14], NSFontAttributeName,[ImageUtils colorFromHexString:MSG_ITEM_MORE_TEXT_COLOR andDefaultColor:nil], NSForegroundColorAttributeName,nil];
        
        [@"n" drawInRect:CGRectMake(bgRightBottom.x - MSG_ITEM_BG_DETAIL_MARGIN - 20, offsetHeight + (MSG_ITEM_MORE_HEIGHT - sizeMore.height) / 2, 20, MSG_ITEM_MORE_HEIGHT) withAttributes:attrMoreIcon withFont:[UIFont fontWithName:IPHONE_ICON_2 size:14] UIColor:[ImageUtils colorFromHexString:MSG_ITEM_MORE_TEXT_COLOR andDefaultColor:nil]];
    }
}

- (void) parseMsg:(PublicNumberMessage *)msg
{
    title = msg.title;
    NSData *data =[msg.desc dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error =nil;
    desc= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    NSData *data2 =[msg.keynotes dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error2 =nil;
    keynotesAreas= [NSJSONSerialization JSONObjectWithData:data2 options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error2];
    
    NSData *data3 =[msg.remark dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error3 =nil;
    remark= [NSJSONSerialization JSONObjectWithData:data3 options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error3];

    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[msg.url dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    url = [[CTUrl alloc]initWithJson:json];
    url.serviceId = msg.sendId;
    self.nativeUrl = [NSJSONSerialization JSONObjectWithData:[msg.nativeUrl dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    self.message = msg;
    
}

- (void)drawView:(PublicNumberMessage *)msg
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [PublicNumberMessageView getRowHeight:msg]);
    [self parseMsg:msg];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
    NSDate *dateTarget = [NSDate dateWithTimeIntervalSince1970:[msg.createTime integerValue]];
    [dateLabel setText:[dateFormatter stringFromDate:dateTarget]];
    
    [self setNeedsDisplay];
}


+(int) getRowHeight:(PublicNumberMessage *)msg
{
    NSString* titleStr = msg.title;
    
    NSData *data =[msg.desc dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error =nil;
    NSDictionary* descStr= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    NSData *data2 =[msg.keynotes dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error2 =nil;
    NSArray* keynotesArray= [NSJSONSerialization JSONObjectWithData:data2 options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error2];
    
    NSData *data3 =[msg.remark dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error3 =nil;
    NSDictionary* remarkStr= [NSJSONSerialization JSONObjectWithData:data3 options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error3];
   
    NSDictionary* nativeUrl = [NSJSONSerialization JSONObjectWithData:[msg.nativeUrl dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    int rowHeight = MSG_ITEM_DETAIL_MARGIN;
    if ([titleStr length] > 0) {
        rowHeight = rowHeight + [PublicNumberMessageView getSizeByText:titleStr andUIFont:[UIFont boldSystemFontOfSize:18]].height + 2 * MSG_ITEM_DETAIL_TOP + MSG_ITEM_TITLE_TOP + 2;
    }
    if ([[descStr stringForKey:@"value"] length] > 0) {
        rowHeight = rowHeight + [PublicNumberMessageView getSizeByText:[descStr stringForKey:@"value"] andUIFont:[UIFont systemFontOfSize:16]].height + 2 * MSG_ITEM_DETAIL_TOP + MSG_ITEM_DESC_TOP + 10;
    }
    if ([[remarkStr stringForKey:@"value"] length] > 0) {
        rowHeight = rowHeight + [PublicNumberMessageView getSizeByText:[remarkStr stringForKey:@"value"] andUIFont:[UIFont systemFontOfSize:16]].height + 2 * MSG_ITEM_DETAIL_TOP + MSG_ITEM_REMARK_TOP;
    }
    
    //draw keynote
    for (NSDictionary* dictionary in keynotesArray) {
        NSString* keynoteTitle = [NSString stringWithFormat:@"%@: ", [dictionary stringForKey:@"key"]];
        CGSize titleSize = [PublicNumberMessageView getSizeByText:keynoteTitle andUIFont:[UIFont systemFontOfSize:16]];
        NSString* keynote = [dictionary stringForKey:@"value"];
        
        CGFloat width = TPScreenWidth() - 2 * MSG_ITEM_BG_DETAIL_MARGIN - 2 * MSG_ITEM_DETAIL_LEFT - titleSize.width;
        CGFloat height = [PublicNumberMessageView getSizeByText:keynote andUIFont:[UIFont systemFontOfSize:16] andWidth:width].height;
        height = height > titleSize.height ? height : titleSize.height;
        rowHeight = rowHeight + height + 2 * MSG_ITEM_DETAIL_TOP;
    }
    
    CTUrl* url = [[CTUrl alloc]initWithUrl:msg.url];
    if([url isValid] || [nativeUrl allKeys].count > 0) {
        rowHeight = rowHeight + MSG_ITEM_MORE_HEIGHT + 10;
    } else {
        rowHeight = rowHeight + 10;
    }
    rowHeight = rowHeight + MSG_ITEM_DETAIL_DATE_HEIGHT;
    
    rowHeight = rowHeight + 5;
    return rowHeight;
}

-(void) doClick
{
    if ([self.nativeUrl allKeys].count > 0) {
        [ControllerManager pushController:self.nativeUrl];[DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_PN_MESSAGE_ITEM kvs:Pair(@"action", @"selected"), Pair(@"send_id",message.sendId), Pair(@"native_url", message.nativeUrl),nil];
    } else if ([self.url isValid]) {
        [self.url startWebView];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_PN_MESSAGE_ITEM kvs:Pair(@"action", @"selected"), Pair(@"send_id",message.sendId), Pair(@"url",message.url), nil];
    }
    if ([message hasStatKey]) {
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_STAT_KEY_MSG_CLICKED kvs:Pair(@"stat_key", message.statKey), Pair(@"service_id", message.sendId), nil];
    }
}
@end
