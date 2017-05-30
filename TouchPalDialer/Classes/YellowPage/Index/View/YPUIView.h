//
//  YPUIView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-7-9.
//
//

#ifndef TouchPalDialer_YPUIView_h
#define TouchPalDialer_YPUIView_h
@interface YPUIView : UIView
@property(nonatomic, assign)BOOL pressed;
@property(nonatomic, strong)void (^block)();
- (void) doClick;
@end

#endif
