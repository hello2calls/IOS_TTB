//
//  TodayWidgetInfoView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/6/10.
//
//

#import "TodayWidgetMainView.h"
#import "TodayWidgetInfo.h"

@interface TodayWidgetInfoView : TodayWidgetMainView
- (instancetype)initWithInfo:(TodayWidgetInfo *)info andAttr:(NSString*)attr andIfFreeCall:(BOOL)ifFreeCall delegate:(id<TodayWidgetMainViewDelegate>)delegate;
@end
