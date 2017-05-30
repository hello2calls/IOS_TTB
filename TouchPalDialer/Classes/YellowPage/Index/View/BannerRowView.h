//
//  BannerRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//
#import "TPUIButton.h"

@class SectionGroup;
@class BannerScrollView;
@interface BannerRowView : UIView

@property(nonatomic,retain) BannerScrollView* scrollView;

- (id)initWithFrame:(CGRect)frame andData:(SectionGroup *)group;
- (void) resetWithBannerData:(SectionGroup *)data;

+ (BOOL)checkImageReady:(SectionGroup *)group;
@end