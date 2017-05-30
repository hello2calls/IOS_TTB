//
//  FuWuHaoListItemView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-8-4.
//
//

#import <Foundation/Foundation.h>
#import "PublicNumberListItemView.h"
#import "PushConstant.h"
#import "ImageUtils.h"
#import "CTUrl.h"
#import "PublicNumberProvider.h"
#import "PublicNumberDetailController.h"
#import "UIDataManager.h"
#import "YellowPageMainTabController.h"
#import "TouchPalDialerAppDelegate.h"
#import "PublicNumberMessageView.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "NSString+Draw.h"

@implementation PublicNumberListItemView
@synthesize logoView;
@synthesize titleLabel;
@synthesize subTitleLabel;
@synthesize timeLabel;
@synthesize url;
@synthesize redpointLabel;
@synthesize model;

-(id) initWithFrame:(CGRect)frame withPublicNumber:(PublicNumberModel*)publicNumberModel
{
    self = [super initWithFrame:frame];
    
    self.logoView = [[UIImageView alloc]initWithFrame:CGRectMake(LIST_ITEM_LOGO_MARGIN_LEFT, LIST_ITEM_LOGO_MARGIN_TOP, self.bounds.size.height - 2 * LIST_ITEM_LOGO_MARGIN_TOP, self.bounds.size.height - 2 * LIST_ITEM_LOGO_MARGIN_TOP)];
    [self addSubview:logoView];
    
    self.titleLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(self.logoView.frame.size.width + 2 * LIST_ITEM_LOGO_MARGIN_LEFT, 2, self.bounds.size.width - self.logoView.frame.size.width - 3 * LIST_ITEM_LOGO_MARGIN_LEFT - LIST_ITEM_TIME_WIDTH, self.bounds.size.height * 3 / 5)];
    self.titleLabel.textColor = [ImageUtils colorFromHexString:LIST_ITEM_TITLE_TEXT_COLOR andDefaultColor:nil];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.verticalAlignment = VerticalAlignmentMiddle;
    self.titleLabel.userInteractionEnabled = YES;
    self.titleLabel.font = [UIFont systemFontOfSize:LIST_ITEM_TITLE_SIZE];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.timeLabel.numberOfLines = 1;
    [self addSubview:titleLabel];
    
    self.subTitleLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(self.logoView.frame.size.width + 2 * LIST_ITEM_LOGO_MARGIN_LEFT, self.bounds.size.height * 3 / 5, self.bounds.size.width - self.logoView.frame.size.width - 3 * LIST_ITEM_LOGO_MARGIN_LEFT, self.bounds.size.height * 2/ 5)];
    self.subTitleLabel.textColor = [ImageUtils colorFromHexString:LIST_ITEM_SUB_TITLE_TEXT_COLOR andDefaultColor:nil];
    self.subTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.subTitleLabel.verticalAlignment = VerticalAlignmentTop;
    self.subTitleLabel.userInteractionEnabled = YES;
    self.subTitleLabel.font = [UIFont systemFontOfSize:LIST_ITEM_SUB_TITLE_SIZE];
    self.subTitleLabel.numberOfLines = 1;
    self.subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:subTitleLabel];
    
    
    self.timeLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(self.bounds.size.width - LIST_ITEM_TIME_WIDTH, 0, LIST_ITEM_TIME_WIDTH, self.bounds.size.height / 2)];
    self.timeLabel.textColor = [ImageUtils colorFromHexString:LIST_ITEM_TIME_TEXT_COLOR andDefaultColor:nil];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.verticalAlignment = VerticalAlignmentMiddle;
    self.timeLabel.userInteractionEnabled = YES;
    self.timeLabel.font = [UIFont systemFontOfSize:LIST_ITEM_TIME_SIZE];
    [self addSubview:timeLabel];
    
    [self setTag:LIST_ITEM_FUWUHAO_TAG];
    
    self.model = publicNumberModel;

    [self drawView];
    return self;
}

- (void) drawView
{
    self.url = model.iconPath;
    self.logoView.image = nil;
    if (self.url.length <=0) {
        self.url = model.iconLink;
    } else {
        self.logoView.image = [UIImage imageWithContentsOfFile:self.url];
    }
    
    if (self.logoView.image == nil) {
        self.logoView.image = [ImageUtils getImageFromLocalWithUrl:url];
    }
    if (self.logoView.image == nil) {
        [self performSelectorInBackground:@selector(downloadImageFromNetwork) withObject:nil];
    }
    
    self.titleLabel.text = model.name;
    NSDictionary* contentDic =  [NSJSONSerialization JSONObjectWithData:[model.msgContent dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    self.subTitleLabel.text = [contentDic objectForKey:@"value"];
    self.timeLabel.text = [self getDateWithTime:model.newMsgTime];
    if (model.msgContent.length == 0) {
        self.timeLabel.hidden = YES;
    } else {
        self.timeLabel.hidden = NO;
    }
    
    [self setNeedsDisplay];
}


-(NSString*) getDateWithTime:(NSInteger) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd"];
    
    NSDate *dateTarget = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDate* today = [dateFormatter dateFromString:currentDateStr];
    NSInteger todatSec = [today timeIntervalSince1970];
    if ((todatSec - time) > 0 && (todatSec - time) <= 24 * 60 * 60) {
        return @"昨天";
    }
    
    NSString *dateTargetStr = [dateFormatter stringFromDate:dateTarget];
    if ([dateTargetStr isEqualToString:currentDateStr]) {
        [dateFormatter setDateFormat:@"HH:mm"];
        dateTargetStr = [dateFormatter stringFromDate:dateTarget];
    }
    
    return dateTargetStr;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //highlight
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:LIST_ITEM_BG_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:PUBLIC_NUMBER_LIST_BG_COLOR andDefaultColor:nil].CGColor);
    }
    CGContextFillRect(context, rect);
    
    if(self.model.newMsgCount > 0) {
        [self drawRedPoint:context];
    }
}


- (void) doClick {
    cootek_log(@"do click");
    if (self.model.url && self.model.url.length > 0) {
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[self.model.url dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        CTUrl* ctUrl = [[CTUrl alloc]initWithJson:dic];
        [ctUrl startWebView];
        NSMutableArray* array = [NSMutableArray new];
        [PublicNumberProvider getPublicNumberMsgs:array withNoahArray:nil withSendId:model.sendId count:1 fromMsgId:nil];
        if ([array count] > 0){
            PublicNumberMessage *msg = [array objectAtIndex:0];
            if ([msg hasStatKey]) {
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_STAT_KEY_AD_FUWUHAO_CLICKED kvs:Pair(@"stat_key", msg.statKey), Pair(@"service_id", msg.sendId), Pair(@"url", self.model.url), nil];
            }
        }
        [PublicNumberProvider clearNewCountForServiceId:self.model.sendId];
    } else {
        PublicNumberDetailController* controller= [[PublicNumberDetailController alloc] init];
        controller.model = self.model;
        controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
        
        [[TouchPalDialerAppDelegate naviController]pushViewController:controller animated:YES];
        self.model.newMsgCount = 0;
        [PublicNumberProvider clearNewCountForServiceId:self.model.sendId];
        [self setNeedsDisplay];
    }
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_PN_LIST_ITEM kvs:Pair(@"action", @"selected"),Pair(@"name", self.model.name), Pair(@"send_id", self.model.sendId), Pair(@"user_phone", self.model.userPhone),nil];
}

- (void)downloadImageFromNetwork
{
    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
    if(save){
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.logoView.image = [ImageUtils getImageFromLocalWithUrl:url];
            [self.logoView setNeedsDisplay];
        });
//        [PublicNumberProvider saveDownloadLinks:nil];
        
    }
}

- (void) drawRedPoint:(CGContextRef)context
{
    
    CGPoint p = CGPointMake(self.bounds.size.width - LIST_ITEM_RED_POINT_RADIUS - LIST_ITEM_TIME_WIDTH, self.bounds.size.height / 2);
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:LIST_ITEM_REDPOINT_BG_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    CGContextSetLineWidth(context, 0);
    CGContextAddArc(context, p.x, p.y / 2 , LIST_ITEM_RED_POINT_RADIUS, 0, 360, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    NSNumber* countText = [NSNumber numberWithInt:self.model.newMsgCount];
    NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIFont boldSystemFontOfSize:8], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    if (countText.intValue >= 100) {
        countText = [NSNumber numberWithInt:99];
    }
    CGSize sizeCount = [PublicNumberMessageView getSizeByText:[countText stringValue] andUIFont:[UIFont boldSystemFontOfSize:8]];
    [[countText stringValue] drawInRect:CGRectMake(p.x - sizeCount.width / 2, (p.y - sizeCount.height) / 2, sizeCount.width, sizeCount.height) withAttributes:attr withFont:[UIFont boldSystemFontOfSize:8] UIColor:[UIColor whiteColor]];
}

@end