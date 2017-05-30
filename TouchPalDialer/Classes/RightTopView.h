//
//  RightTopView.h
//  TouchPalDialer
//
//  Created by tanglin on 15/12/16.
//
//

#import <UIKit/UIKit.h>
#import "VerticallyAlignedLabel.h"
#import "RightTopItem.h"
#import "YPUIView.h"
#import "RightTopHighLightView.h"

@interface RightTopView : YPUIView
@property(nonatomic, strong) VerticallyAlignedLabel* content;
@property(nonatomic, strong) RightTopHighLightView* highlightView;
@property(nonatomic, strong) RightTopItem* item;

-(void) drawView:(RightTopItem *)item;
@end
