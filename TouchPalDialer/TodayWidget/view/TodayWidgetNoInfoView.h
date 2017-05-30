//
//  TodayWidgetNoInfoView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/6/10.
//
//

#import "TodayWidgetMainView.h"

@interface TodayWidgetNoInfoView : TodayWidgetMainView
- (instancetype)initWithNumber:(NSString*)number andAttr:(NSString*)attr andIfFreeCall:(BOOL)ifFreeCall delegate:(id<TodayWidgetMainViewDelegate>)delegate;
@end
