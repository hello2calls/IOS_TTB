//
//  BannerScrollView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-5-14.
//
//

#ifndef TouchPalDialer_BannerScrollView_h
#define TouchPalDialer_BannerScrollView_h
#import "YPUIScrollView.h"
@class SectionGroup;
@interface BannerScrollView : YPUIScrollView<UIScrollViewDelegate>

@property(nonatomic, retain) SectionGroup* item;
@property(nonatomic, retain) UIPageControl* pageControl;

- (id)initWithFrame:(CGRect)frame andData:(SectionGroup *)group andPageControl:(UIPageControl*)pageControl;
-(void) drawView:(SectionGroup*)group;

@end

#endif
