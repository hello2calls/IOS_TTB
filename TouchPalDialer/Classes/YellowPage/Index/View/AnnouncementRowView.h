//
//  AnnouncementRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//
#import "TPUIButton.h"
#import "YPUIView.h"
@class SectionGroup;
@class AnnouncementCellView;
@class SectionAnnouncement;
@class WeatherCellView;

@interface AnnouncementRowView : YPUIView

@property (nonatomic, retain) SectionGroup* groupItem;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) AnnouncementCellView* cellView;
@property (nonatomic, retain) WeatherCellView* weatherCellView;
@property (nonatomic, retain) NSString *weatherData;
@property (nonatomic, assign) CGFloat weatherWidth;

- (id) initWithFrame:(CGRect)frame andData:(SectionGroup *)data;
- (void) resetWithAnnouncementData:(SectionGroup *)data;
- (void) setAnnouncementFrame:(CGRect)frame andData:(SectionGroup *)data;

@end
