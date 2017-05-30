//
//  FuWuHaoListItemView.h
//  TouchPalDialer
//
//  Created by tanglin on 15-8-4.
//
//

#ifndef TouchPalDialer_FuWuHaoListItemView_h
#define TouchPalDialer_FuWuHaoListItemView_h
#import "VerticallyAlignedLabel.h"
#import "YPUIView.h"
#import "PublicNumberModel.h"

@interface PublicNumberListItemView : YPUIView

@property (nonatomic, retain) UIImageView* logoView;
@property (nonatomic, retain) VerticallyAlignedLabel* titleLabel;
@property (nonatomic, retain) VerticallyAlignedLabel* subTitleLabel;
@property (nonatomic, retain) VerticallyAlignedLabel* timeLabel;
@property (nonatomic, retain) VerticallyAlignedLabel* redpointLabel;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) PublicNumberModel* model;

-(id) initWithFrame:(CGRect)frame withPublicNumber:(PublicNumberModel*)model;
-(void) drawView;

@end

#endif
