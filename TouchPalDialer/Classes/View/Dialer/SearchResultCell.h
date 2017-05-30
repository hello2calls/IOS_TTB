//
//  SearchResultCell.h
//  TouchPalDialer
//
//  Created by zhang Owen on 11/11/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPUIButton.h"
#import "FaceSticker.h"
#import "DialResultModel.h"
#import "HighLightLabel.h"
#import "CootekTableViewCell.h"
#import "BaseContactCell.h"
#import "WithEyeViewForBaseContactCell.h"
@interface SearchResultCell : WithEyeViewForBaseContactCell {
     TPUIButton *_detailButton;
}
@property(nonatomic,retain) TPUIButton *detailButton;


- (NSMutableArray *)getArratFromRange:(NSRange)range;
@end
