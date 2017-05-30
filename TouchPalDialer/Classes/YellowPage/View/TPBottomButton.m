//
//  TPBottomButton.m
//  TouchPalDialer
//
//  Created by tanglin on 15-8-11.
//
//

#import "TPBottomButton.h"
#import "ImageUtils.h"
#import "PushConstant.h"
#import "TPDialerResourceManager.h"
#import "YellowPageMainTabController.h"
#import "UIDataManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "ControllerManager.h"
#import "UserDefaultsManager.h"
#import "NetworkUtility.h"
#import "SeattleFeatureExecutor.h"
#import "TouchPalVersionInfo.h"
#import "IndexConstant.h"
#import "PublicNumberMessageView.h"
#import "CTUrl.h"

@implementation TPBottomButton
@synthesize title;
@synthesize url;

- (id) initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    title = [[VerticallyAlignedLabel alloc]initWithFrame:self.bounds];
    title.textAlignment = NSTextAlignmentCenter;
    title.verticalAlignment = VerticalAlignmentMiddle;
    [self addSubview:title];
    
    return self;
}

- (void) drawView:(NSDictionary *)json
{
    if ([[json allKeys] containsObject:@"name"]) {
        title.text = [json objectForKey:@"name"];
    }
    if ([[json allKeys] containsObject:@"color"]) {
        title.textColor = [ImageUtils colorFromHexString:[json objectForKey:@"color"] andDefaultColor:[UIColor blackColor]];
    }
    if ([[json allKeys] containsObject:@"link"]) {
        url = [[CTUrl alloc]initWithJson:[json objectForKey:@"link"]];
        if([[json allKeys] containsObject:@"identifier"]) {
            self.url.serviceId = [json objectForKey:@"identifier"];
        }
    }

    if ([[json allKeys] containsObject:@"native"]) {
        url.nativeUrl = [json objectForKey:@"native"];
    }
}

- (void) drawViewForService:(NSDictionary *)json
{
    if ([[json allKeys] containsObject:@"name"]) {
        title.text = [json objectForKey:@"name"];
    }
    if ([[json allKeys] containsObject:@"color"]) {
        title.textColor = [ImageUtils colorFromHexString:[json objectForKey:@"color"] andDefaultColor:[UIColor blackColor]];
    }
    if ([[json allKeys] containsObject:@"link"]) {
        url = [[CTUrl alloc]initWithJson:[json objectForKey:@"link"]];
        if([[json allKeys] containsObject:@"identifier"]) {
            self.url.serviceId = [json objectForKey:@"identifier"];
        }
        if (url.params.length > 0) {
            url.params = [NSString stringWithFormat:@"%@&_ts=%.0f", url.params, [[NSDate date] timeIntervalSince1970]];
        } else {
            url.params = [NSString stringWithFormat:@"_ts=%.0f", [[NSDate date] timeIntervalSince1970]];
        }
    }
    
    if ([[json allKeys] containsObject:@"native"]) {
        url.nativeUrl = [json objectForKey:@"native"];
    }
    
    if ([[json allKeys] containsObject:@"rate"]) {
        self.serviceRateUrl = [NSString stringWithFormat:@"%@&_token=%@",[json objectForKey:@"rate"], [SeattleFeatureExecutor getToken]];
        [self requestServiceRate];
        
    }
    
}

- (void) requestServiceRate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        self.serviceRateUrl = [CTUrl encodeRequestUrl:self.serviceRateUrl];
        NSURL *urlRequest=[NSURL URLWithString:self.serviceRateUrl];
        NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
        [httpIndexRequest setHTTPMethod:@"GET"];
        NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
        NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
        NSInteger status=[response_url statusCode];
        NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
        cootek_log(@"updateService requestServiceBottomData url : %@ , status : %d, response: %@",self.serviceRateUrl, status, responseString);
        if (status != 404 && [responseString length]>0) {
            NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error =nil;
            NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
            NSDictionary* dataDic = [returnData objectForKey:@"result"];
          
            NSString* status = [dataDic objectForKey:@"status"];
            if ([@"1" isEqualToString:status]) {
                if ([[dataDic allKeys] containsObject:@"avg_rate"]) {
                    NSNumber* rate = [dataDic objectForKey:@"avg_rate"];
                    CGFloat rateFloat = roundf(rate.floatValue * 10) / 10 ;
                    NSString* rateStr = [NSString stringWithFormat:@"%.1f分",rateFloat];
                    if (rateFloat < 1) {
                        if (rate.floatValue >= 1) {
                            rateStr = [NSString stringWithFormat:@"%.1f分",rate.floatValue];
                        } else {
                            return;
                        }
                    }
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.serviceRate = rateStr;
                        [self setNeedsDisplay];
                    });
                }
            }
            
        } else {
            
        }
    });
        
 
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //highlight
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:LIST_ITEM_BG_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillRect(context, rect);
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MSG_ITEM_DETAIL_BORDER_COLOR andDefaultColor:nil] andFromX:0.0f andFromY:0 andToX:TPScreenWidth() andToY:0 andWidth:2];
    
    [ImageUtils drawLineWithColor:[ImageUtils colorFromHexString:MSG_ITEM_DETAIL_BORDER_COLOR andDefaultColor:nil] andFromX:rect.size.width andFromY:0 andToX:rect.size.width andToY:rect.size.height andWidth:2];
    
    if (self.serviceRate && self.serviceRate.length > 0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
       
        CGSize rateSize = [PublicNumberMessageView getSizeByText:self.serviceRate andUIFont:[UIFont systemFontOfSize:10]];
        
        CGPoint bgLeftTop = CGPointMake(rect.size.width - rateSize.width - 2 - 10, 4 - 1);
        CGPoint bgRightBottom = CGPointMake(rect.size.width - 2, rateSize.height + 4 + 1);
        CGContextSetLineWidth(context, 0.2);
        //highlight
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_ROTATE_BG_COLOR andDefaultColor:nil].CGColor);
        
        [ImageUtils drawArcRectangleWithContext:context andPointTopLeft:bgLeftTop  andPointBottomRight:bgRightBottom andRadius:rateSize.height / 2];
      
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        [self.serviceRate drawInRect:CGRectMake(rect.size.width - rateSize.width - 2 - 5, 4, rateSize.width, rateSize.height) withFont:[UIFont systemFontOfSize:10]];
    }
    
}

- (void) doClick
{
    [self.url startWebView];
    if (self.url.nativeUrl) {
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_BOTTOM_BAR_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title",@"native url"), Pair(@"url", self.url.nativeUrl), nil];
    }else if (self.url.url.length > 0){
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_BOTTOM_BAR_ITEM kvs:Pair(@"action", @"selected"), Pair(@"title",@"web url"), Pair(@"url", self.url.url), nil];
        
    }
}
@end
