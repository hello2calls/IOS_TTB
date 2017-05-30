//
//  FindNewsHeaderView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/24.
//
//

#import <UIKit/UIKit.h>
#import "VerticallyAlignedLabel.h"
#import "YPUIView.h"

@interface FindNewsHeaderView : YPUIView
@property (nonatomic, retain) VerticallyAlignedLabel* title;
@property (nonatomic, retain) VerticallyAlignedLabel* shortcut;
@property (nonatomic, retain) VerticallyAlignedLabel* shortcutIcon;

- (void) drawTitle:(NSString *)title;
@end
