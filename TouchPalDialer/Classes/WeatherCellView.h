//
//  WeatherCellView.h
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 15/11/10.
//
//

#import "VerticallyAlignedLabel.h"
#import "CTUrl.h"
#ifndef WeatherCellView_h
#define WeatherCellView_h

@class SectionGroup;
@class VerticallyAlignedLabel;
@interface WeatherCellView : VerticallyAlignedLabel

@property (nonatomic, assign) BOOL pressed;
- (void) drawViewWithData:(NSString *)data andPressed:(BOOL)isPressed;
- (void) startWeatherPage;
@end

#endif /* WeatherCellView_h */
