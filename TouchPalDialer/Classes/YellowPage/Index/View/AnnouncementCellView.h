//
//  AnnouncementCellView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-17.
//
//

#ifndef TouchPalDialer_AnnouncementCellView_h
#define TouchPalDialer_AnnouncementCellView_h

@class SectionGroup;
@class VerticallyAlignedLabel;
@interface AnnouncementCellView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, retain) VerticallyAlignedLabel* topLabel;
@property (nonatomic, retain) VerticallyAlignedLabel* centerLabel;
@property (nonatomic, retain) SectionGroup* item;
@property (nonatomic, assign) BOOL pressed;


- (id) initWithFrame:(CGRect)frame andData:(SectionGroup *)data;
- (void) drawViewWithData:(SectionGroup *)data andPressed:(BOOL)isPressed;
- (void) startWebView;
- (void) stop;
- (void) resume;
@end

#endif
