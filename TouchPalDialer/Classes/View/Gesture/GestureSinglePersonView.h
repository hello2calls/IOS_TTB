//
//  SinglePersonView.h
//  TouchPalDialer
//
//  Created by Admin on 7/1/13.
//
//

#import <UIKit/UIKit.h>
#import "GestureModel.h"
#import "GestureUtility.h"
#import "TPUIButton.h"
#import "GestureScrollView.h"

@protocol DeleteDelegate
- (void)onDeletePressed:(UIButton *)button;
@end

@interface GestureSinglePersonView : UIView
@property(nonatomic,assign)GestureActionType actionKey;
@property(nonatomic,retain)Gesture* gesture;
@property(nonatomic,retain)UIView* transView;
@property(nonatomic,assign)BOOL isAdd;
@property(nonatomic, assign)id<DeleteDelegate> deleteDelegate;

-(id)initWithGesture:(Gesture *)ges Frame:(CGRect)frame andIndex:(int)index;
-(id)initWithAdd:(CGRect)frame;
- (void)hideDeleteButton;
- (void)showDeleteButton;

@end