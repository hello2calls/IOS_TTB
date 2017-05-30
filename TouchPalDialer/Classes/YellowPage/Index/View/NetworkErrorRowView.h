//
//  NetworkErrorRowView.h
//  TouchPalDialer
//
//  Created by apple on 16/7/18.
//
//

#import "YPUIView.h"
#import "VerticallyAlignedLabel.h"

@interface NetworkErrorRowView : YPUIView
@property (nonatomic, retain) VerticallyAlignedLabel* networkErrorIcon;
@property (nonatomic, retain) VerticallyAlignedLabel* networkErrorLabel;

-(void)drawView;
@end
