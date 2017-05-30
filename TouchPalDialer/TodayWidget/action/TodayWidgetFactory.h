//
//  TodayWidgetFactory.h
//  TouchPalDialer
//
//  Created by game3108 on 15/6/9.
//
//

#import <Foundation/Foundation.h>
#import "TodayWidgetMainView.h"

@protocol TodayWidgetFactoryDelegate <NSObject>
- (void)adjustViewHeight:(float)height;
- (void)refreshView;

@end

@interface TodayWidgetFactory : NSObject
@property (nonatomic,retain) NSExtensionContext *context;
@property (nonatomic,assign) id<TodayWidgetFactoryDelegate> delegate;
- (TodayWidgetMainView *) getTodayWidgetView;
- (void)onPressBgButton;
- (void)onPressUpdateButton;
- (void)recordTimes;
-(BOOL)ifShowUpdateViewInToday;
@end
