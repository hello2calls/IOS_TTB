//
//  ServiceHeaderView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/10.
//
//

#import <UIKit/UIKit.h>
#import "VerticallyAlignedLabel.h"

@interface ServiceHeaderView : UIView

@property (nonatomic, retain) VerticallyAlignedLabel* title;

- (void) drawTitle:(NSString *)title;
@end
