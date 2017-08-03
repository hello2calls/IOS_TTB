//
//  CitySelectView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#import <Foundation/Foundation.h>
#import "CitySelectView.h"
#import "TPDialerResourceManager.h"
#import "VerticallyAlignedLabel.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "CTUrl.h"
#import "CootekNotifications.h"
#import "LocalStorage.h"
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "CitySelectViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "FindNewsItem.h"

@interface CitySelectView()

@property (nonatomic, retain) UIImage *icon;
@property(nonatomic, retain) UIColor* bgColor;
@end

@implementation CitySelectView

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //highlight
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    
    CGContextFillRect(context, rect);
    
    float iconWidth = rect.size.height * 7 / 20;
    float iconHeight = rect.size.height * 7 / 20;
    
    if (self.icon.size.height > self.icon.size.width) {
        iconWidth = iconWidth * self.icon.size.width / self.icon.size.height;
    } else {
        iconHeight = iconHeight * self.icon.size.height / self.icon.size.width;
    }
    
    UIFont* textFont = [UIFont systemFontOfSize:SEARCH_BAR_CITY_TEXT_SIZE];
    if (self.text.length > 3) {
        textFont = [UIFont systemFontOfSize:SEARCH_BAR_CITY_TEXT_SMALL_SIZE];
    }
    CGSize size = [_text sizeWithFont:textFont];
    [self.icon drawInRect:CGRectMake(SEARCH_BAR_CITY_ICON_X_OFFSET, (rect.size.height - iconHeight) / 2, iconWidth, iconHeight)];
    if (self.pressed) {
        CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:SEARCH_BAR_CITY_TEXT_HIGHLIGHT_COLOR andDefaultColor:nil].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    }
    [self.text drawInRect:CGRectMake(iconWidth + SEARCH_BAR_CITY_TEXT_X_OFFSET, (rect.size.height - size.height) / 2, size.width, size.height) withFont:textFont];
    
}

- (void) doClick {
    CitySelectViewController* controller = [[CitySelectViewController alloc]init];
    [[TouchPalDialerAppDelegate naviController]pushViewController:controller animated:YES];
    
}

- (void) drawView:(NSString*)city
{
    if (city == nil || city.length <= 0) {
        return;
    }
    
    self.text = city;
    self.bgColor = [ImageUtils colorFromHexString:SEARCH_BAR_CITY_BG_COLOR andDefaultColor:nil];
    CTUrl* url = nil;
    if (USE_DEBUG_SERVER) {
        url = [[CTUrl alloc]initWithUrl:[NSString stringWithFormat:YP_CITY_SELECT_PATH, YP_DEBUG_SERVER]];
    } else {
        url = [[CTUrl alloc]initWithUrl:[NSString stringWithFormat:YP_CITY_SELECT_PATH, SEARCH_SITE]];
    }
    
    self.ctUrl = url;
    self.icon = [[TPDialerResourceManager sharedManager] getImageByName:@"location_highlight@2x.png"];
    
    [self setNeedsDisplay];
}
@end
