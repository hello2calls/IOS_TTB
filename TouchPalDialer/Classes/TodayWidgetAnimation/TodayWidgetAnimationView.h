//
//  TodayWidgetAnimationView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/1.
//
//

#import <UIKit/UIKit.h>
#import "TodayWidgetAnimationUtil.h"
#import "UserDefaultsManager.h"

#define HEIGHT_ADAPT self.heightAdapt

@protocol TodayWidgetAnimationViewDelegate <NSObject>
- (void)onAnimationOver:(NSInteger)num;
@end

@interface TodayWidgetAnimationView : UIView
@property (nonatomic,assign) id<TodayWidgetAnimationViewDelegate> delegate;
@property (nonatomic,assign) BOOL ifAnimation;
@property (nonatomic,assign) CGFloat heightAdapt;
- (void)doAnimation;
- (void)refreshView;
@end
