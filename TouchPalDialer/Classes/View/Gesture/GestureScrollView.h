//
//  GestureScrollView.h
//  TouchPalDialer
//
//  Created by Admin on 7/1/13.
//
//

#import <UIKit/UIKit.h>
#import "TPPageController.h"

@interface GestureScrollView : UIView<UIScrollViewDelegate> 
@property(nonatomic,assign) NSInteger currentPage;
@property(nonatomic,retain) NSMutableArray *gestureCustomList;
@property(nonatomic,retain) TPPageController *pageController;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,assign) BOOL isEdit;

- (id)initWithFrame:(CGRect)frame isEdit:(BOOL)isEdit WithCurrentPage:(NSInteger) currentPage;
- (void)loadScrollView;
- (void)setDeleteBtn: (BOOL) isEditMode;
@end
