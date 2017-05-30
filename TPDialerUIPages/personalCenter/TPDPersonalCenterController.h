//
//  TPDPersonalCenterController.h
//  TouchPalDialer
//
//  Created by siyi on 16/9/19.
//  Attention: This is a copy of YellowPageMainTabController, for V6 testing
//
//

#ifndef TPDPersonalCenterController_h
#define TPDPersonalCenterController_h

#import <Foundation/Foundation.h>
#import "CootekViewController.h"
#import "SearchRowView.h"
#import "EntranceIcon.h"
#import "LoadMoreTableFooterView.h"
#import "PublicNumberCenterView.h"
#import "YPUIView.h"
#import "YPAdItem.h"
#import "SectionAD.h"
#import "YPUIView.h"

@interface TPDPersonalCenterController : UIViewController <UITableViewDataSource,
UITableViewDelegate,EntranceIconDelegate>

@property(nonatomic, retain) HeaderBar *headerView;
@property(nonatomic, retain) UITableView *all_content_view;
@property(nonatomic, retain) NSDictionary *yellowpage_data;
@property(nonatomic, retain) LoadMoreTableFooterView* load_more_foot_view;
@property(nonatomic, assign) BOOL notHome;
@property(nonatomic, retain) PublicNumberCenterView* pnCenter;
@property(nonatomic, retain) UIImageView* fullScreenAds;

- (void) initLoad;
- (void) controlAccessoryView:(NSNumber *)alphaValue;

@end


@interface YPAdCellView : YPUIView

- (instancetype) initWithData:(YPAdItem *)data andSection:(SectionAD *)section;
- (void) updateUIWithData:(YPAdItem *)data;

@property (nonatomic, strong, readwrite) YPAdItem *adItem;
@property (nonatomic, strong, readonly) SectionAD *section;

@property (nonatomic, strong, readwrite) UIView *rightContainer;
@property (nonatomic, strong, readwrite) UIView *iconContainer;

@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *subTitleLabel;

@end


@interface YPAdRowView : YPUIView
- (instancetype) initWithData:(SectionAD *)data;
- (instancetype) initWithData:(SectionAD *)data contentInsets:(UIEdgeInsets)insets;
- (UIView *) addBottomLineForView:(UIView *)container;

- (void) updateUIWithData:(SectionAD *)data;

@end

@interface YPAdUtil : NSObject
+ (NSDictionary *) deserializedFontString:(NSString *)tpFontString;
@end

@interface YPPropertyRowView : YPAdRowView
- (void) update;
@end

@interface YPPropertyNotLogginView : UIView

@property (nonatomic, assign, readonly) BOOL animating;
@property (nonatomic, strong, readonly) UIImageView *animationImageView;
@property (nonatomic, strong) UIButton *loginButton;

- (void) beginAnimation;
- (void) endAnimation;

@end

@interface RedPointLabel : UILabel

@property (nonatomic, strong, readonly) UILabel *dotLabel;

- (void) setText:(NSString *)text;
- (void) setShadowColor:(UIColor *)shadowColor offset:(CGSize)offset opacity:(CGFloat)opacity;
- (void) setSize:(CGSize)size andCornorRadius:(CGFloat)radius;
- (void) setSize:(CGSize)tp_size;
@end

#endif /* TPDPersonalCenterController_h */
