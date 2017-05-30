//
//  AnnouncementRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import <Foundation/Foundation.h>
#import "AnnouncementRowView.h"
#import "SectionAnnouncement.h"
#import "TPDialerResourceManager.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "SectionAnnouncement.h"
#import "SectionGroup.h"
#import "CTUrl.h"
#import "AnnouncementCellView.h"
#import "WeatherCellView.h"
#import "UIDataManager.h"
#import "PublicNumberMessageView.h"

@interface AnnouncementRowView()
{
    float iconHeight;
    CGPoint clickPoint;
}


@end
@implementation AnnouncementRowView



- (id)initWithFrame:(CGRect)frame andData:(SectionGroup *)data{
    self = [super initWithFrame:frame];
    self.groupItem = data;
    iconHeight = frame.size.height / 3;
    
    UIFont *font = [UIFont systemFontOfSize:WEATHER_TEXT_SIZE];
    CGSize weatherSize = [PublicNumberMessageView getSizeByText:[UIDataManager instance].weatherData andUIFont:font];
    self.weatherWidth = weatherSize.width;
    CGRect weatherRect = CGRectMake(frame.size.width - WEATHER_MARGIN_RIGHT - self.weatherWidth - WEATHER_MARGIN_LEFT, 0, self.weatherWidth + WEATHER_MARGIN_LEFT, frame.size.height);
    WeatherCellView* weatherCellV = [[WeatherCellView alloc]initWithFrame:weatherRect];
    self.weatherCellView = weatherCellV;
    
    CGRect announcementRect = CGRectMake(ANNOUNCEMENT_MARGIN_LEFT + frame.size.height / 2, 0,frame.size.width - ANNOUNCEMENT_MARGIN_LEFT - self.weatherWidth - WEATHER_MARGIN_RIGHT - frame.size.height / 2 - WEATHER_MARGIN_LEFT, frame.size.height);
    AnnouncementCellView* cellV = [[AnnouncementCellView alloc]initWithFrame:announcementRect andData:data];
    self.cellView = cellV;
    [self addSubview:cellV];
    [self addSubview:self.weatherCellView];
    [self setTag:ANNOUNCEMENT_TAG];
    return self;
}

- (void) setAnnouncementFrame:(CGRect)frame andData:(SectionGroup *)data{
    UIFont *font = [UIFont fontWithName:@"Helvetica-Light" size:WEATHER_TEXT_SIZE];
    CGSize weatherSize = [PublicNumberMessageView getSizeByText:[UIDataManager instance].weatherData andUIFont:font];
    self.weatherWidth = weatherSize.width;
    
    CGRect weatherRect = CGRectMake(frame.size.width - WEATHER_MARGIN_RIGHT - self.weatherWidth - WEATHER_MARGIN_LEFT, 0, self.weatherWidth + WEATHER_MARGIN_LEFT, frame.size.height);
    self.weatherCellView.frame = weatherRect;
    self.groupItem = data;
    iconHeight = frame.size.height / 3;
    CGRect announcementRect = CGRectMake(ANNOUNCEMENT_MARGIN_LEFT + frame.size.height / 2, 0,frame.size.width - ANNOUNCEMENT_MARGIN_LEFT - self.weatherWidth - WEATHER_MARGIN_RIGHT - frame.size.height / 2 - WEATHER_MARGIN_LEFT, frame.size.height);
    self.cellView.frame = announcementRect;
    self.cellView.topLabel.frame = self.cellView.bounds;
    self.cellView.centerLabel.frame = CGRectMake(0,self.cellView.bounds.size.height, self.cellView.bounds.size.width, self.cellView.bounds.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    clickPoint = [touch locationInView:self];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)isTouchInView:(UIView*)view
{
    return CGRectContainsPoint(view.frame, clickPoint);
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //highlight
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [ImageUtils colorFromHexString:ANNOUNCEMENT_BG_COLOR andDefaultColor:nil].CGColor);
    CGContextFillRect(context, rect);

    if (self.pressed && [self isTouchInView:self.cellView]) {
        self.icon = [[TPDialerResourceManager sharedManager] getImageByName:@"announcement_highlight@2x.png"];
    } else {
        self.icon = [[TPDialerResourceManager sharedManager] getImageByName:@"announcement@2x.png"];
    }
    if (self.groupItem.sectionArray.count > 0) {
        [self.icon drawInRect:CGRectMake(ANNOUNCEMENT_MARGIN_LEFT,
                                         (rect.size.height - iconHeight) / 2, iconHeight, iconHeight)];
    }
    [self.cellView drawViewWithData:self.groupItem andPressed:self.pressed && [self isTouchInView:self.cellView]];
    [self.weatherCellView drawViewWithData:[UIDataManager instance].weatherData andPressed:self.pressed && [self isTouchInView:self.weatherCellView]];
 
}

- (void) resetWithAnnouncementData:(SectionGroup *)data
{
    self.groupItem = data;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, INDEX_ROW_HEIGHT_ANNOUNCEMENT);
    [self setAnnouncementFrame:self.frame andData:self.groupItem];
    [self setNeedsDisplay];
}

- (void) doClick {
    if (self.cellView.pressed) {
        [self.cellView startWebView];
    } else if (self.weatherCellView.pressed) {
        [self.weatherCellView startWeatherPage];
    }
}

@end
