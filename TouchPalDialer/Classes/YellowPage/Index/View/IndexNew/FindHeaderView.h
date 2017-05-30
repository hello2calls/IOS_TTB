//
//  FindHeaderView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/14.
//
//

#import <UIKit/UIKit.h>
#import "VerticallyAlignedLabel.h"
#import "RightTopView.h"

@interface FindHeaderView : UIView

@property(nonatomic, strong) VerticallyAlignedLabel* title;
@property(nonatomic, strong) RightTopView* rightTopView;

-(void) drawViewWithTitle:(NSString* )title withColor:(NSString *)color andRightTopItem:(RightTopItem *)item;
@end
