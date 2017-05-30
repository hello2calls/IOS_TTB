//
//  FeedsSignPopupView.h
//  TouchPalDialer
//
//  Created by lin tang on 16/10/19.
//
//

#import "YPUIView.h"
#import "YPImageView.h"

@interface FeedsSignPopupView : YPUIView
- (instancetype) initWithContent:(NSString *)content;
- (void) closeSelf;

@end
