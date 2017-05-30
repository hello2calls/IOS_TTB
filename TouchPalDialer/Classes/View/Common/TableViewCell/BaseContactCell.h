//
//  BaseContactCell.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseCommonCell.h"
#import "ContactsCellStrategy.h"
#import "TPDrawRich.h"
#import "LongGestureOperationView.h"
#import "CallerTypeSticker.h"


@interface BaseContactCell : BaseCommonCell

@property(nonatomic, retain) FaceSticker *faceSticker;
@property(nonatomic, retain) CallerTypeSticker *markSticker;
@property(nonatomic, retain) TPRichLabel *nameLabel;
@property(nonatomic, retain) TPRichLabel *numberLabel;
@property(nonatomic, retain) UIButton *customTagButton;
@property(nonatomic, retain) UILabel *dotLabel;
@property(nonatomic, retain) UIView *userContentView;
@property(nonatomic, retain) id<ContactsCellStrategyDelegate> actionStrategy;
@property(nonatomic, copy)   BOOL(^isExcuteAction)();
@property(nonatomic, retain) UIColor *textNameColor;
@property(nonatomic, retain) UIColor *textNumberColor;
@property(nonatomic, retain) UIColor *htNameTextColor;
@property(nonatomic, retain) UIColor *htNumberColor;
@property(nonatomic, assign) BOOL isHighlightedName;
@property(nonatomic, assign) BOOL isHighlightedNumber;
@property(nonatomic, retain) UIView *operView;
@property(nonatomic, retain) UILabel *bottomLine;
@property(nonatomic, retain) UILabel *partBottomLine;
@property(nonatomic, retain) UILabel *ifCootekUserView;

- (void)refreshCellView:(UIImage *)facePhoto 
             withNumber:(NSString *)number 
     withNumberHitRange:(NSRange )numberRange
               withName:(NSString *)name
       withNameHitArray:(NSMutableArray *)nameHitArray;

- (void)onClick;
- (void)showPartOfBottomLine;
- (void)showAllBottomLine;
- (void)hideBottomLine;
- (void)showAnimation;
- (void)exitAnimation;
-(void)openSlideItem;
-(void)closeSlideItem;
- (void)adjustNameAndNumberLabel; // adjust for vertical center align
- (void) adjustHeightOfLabel:(UILabel *)label;
@end
