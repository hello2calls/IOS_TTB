//
//  WeatherCellView.m
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 15/11/10.
//
//

#import <Foundation/Foundation.h>
#import "WeatherCellView.h"
#import "SectionGroup.h"
#import "VerticallyAlignedLabel.h"
#import "IndexConstant.h"
#import "SectionAnnouncement.h"
#import "CTUrl.h"
#import "ImageUtils.h"
#import "NSTimer+Addition.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "UIDataManager.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"


@implementation WeatherCellView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.textColor = [ImageUtils colorFromHexString:WEATHER_TEXT_COLOR andDefaultColor:nil];
    self.verticalAlignment = VerticalAlignmentMiddle;
    self.font = [UIFont fontWithName:@"Helvetica-Light" size:WEATHER_TEXT_SIZE];
    self.numberOfLines = 1;
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void) drawViewWithData:(NSString *)data andPressed:(BOOL)isPressed
{
    if (isPressed) {
        self.textColor = [ImageUtils colorFromHexString:WEATHER_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil];
    } else {
       self.textColor = [ImageUtils colorFromHexString:WEATHER_TEXT_COLOR andDefaultColor:nil];
    }
    self.pressed = isPressed;
    self.text = data;
}

- (void) startWeatherPage
{
    CTUrl* url = [[CTUrl alloc] init];
    url.needWrap = YES;
    NSString* prefixUrl = SEARCH_SITE;
    if (USE_DEBUG_SERVER) {
        prefixUrl = YP_DEBUG_SERVER;
    }
   
    
    url.url = [NSString stringWithFormat:@"%@%@?_city=%@",prefixUrl, WEATHER_PAGE_PATH, [UserDefaultsManager stringForKey:INDEX_CITY_SELECTED]];
    [url startWebView];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_ANNOUNCE_WEATHER_ITEM kvs:Pair(@"action", @"selected"), Pair(@"weather_url", url.url), nil];
}
@end
