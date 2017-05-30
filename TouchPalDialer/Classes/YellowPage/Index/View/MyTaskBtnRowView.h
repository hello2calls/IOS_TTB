//
//  MyTaskBtnRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/8.
//
//

#import "YPUIView.h"
#import "VerticallyAlignedLabel.h"

@interface MyTaskBtnRowView : YPUIView

@property(strong) NSString* btnText;
@property(strong) UIColor* btnBgColor;
@property(strong) UIColor* btnPressBgColor;

- (void) drawView;

@end
