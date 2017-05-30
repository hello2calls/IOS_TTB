//
//  GestureSinglePageView.h
//  TouchPalDialer
//
//  Created by Admin on 7/1/13.
//
//

#import <UIKit/UIKit.h>
#import "GestureModel.h"
#import "GestureSinglePersonView.h"
#import "GestureScrollView.h"

@interface GestureSinglePageView : UIView
@property(nonatomic,retain) NSMutableArray *gestureCustomList;
@property(nonatomic,retain) GestureModel *gestureModel;
@property(nonatomic,assign) NSInteger pageNumber;
@property(nonatomic,assign) GestureScrollView *parentView;
@property(nonatomic,retain) TPUIButton *maskBtn;

-(id)initWithPageNumber:(NSInteger)number Frame:(CGRect)frame EditMode:(Boolean)isEdit;
-(void)setData;
-(void)addDeleteBtn;
-(void)hideDeleteBtn;

@end