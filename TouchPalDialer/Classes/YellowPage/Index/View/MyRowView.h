//
//  MyRowView.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/7.
//
//

#import "YPUIView.h"
#import "VerticallyAlignedLabel.h"

@interface MyRowView : YPUIView
@property (nonatomic, retain) VerticallyAlignedLabel* phoneIcon;
@property (nonatomic, retain) VerticallyAlignedLabel* phoneLabel;
@property (nonatomic, retain) VerticallyAlignedLabel* rightTextLabel;
@property (nonatomic, retain) VerticallyAlignedLabel* rightTextIcon;

- (void) drawView;
@end
