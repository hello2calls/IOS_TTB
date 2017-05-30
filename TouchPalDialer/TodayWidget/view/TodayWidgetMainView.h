//
//  TodayWidgetMainView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/6/9.
//
//

#import <UIKit/UIKit.h>
@protocol TodayWidgetMainViewDelegate <NSObject>

- (void)onPressBgButton;
-(BOOL)ifShowUpdateViewInToday;
@optional
- (void)onPressRightButton;
- (void)onPressUpdateButton;

@end


@interface TodayWidgetMainView : UIView
@property (nonatomic,assign) id<TodayWidgetMainViewDelegate> delegate;
@property (nonatomic,retain) UIButton *viewButton;
@property (nonatomic,retain) UIView *lableView;
@property (nonatomic,retain) UILabel *mainLabel;
@property (nonatomic,retain) UILabel *subLabel;
@property (nonatomic,retain) UIButton *rightButton;

@property (nonatomic,retain) UIView *updateView;
@property (nonatomic,retain) UIView  *lineView;
@property (nonatomic,retain) UILabel *messageLable;
@property (nonatomic,retain) UILabel *messageLable2;
@property (nonatomic,retain) UIButton *updateButton;
@property (nonatomic,assign) BOOL  ifShowUpdateView;;

@end
