//
//  CallLogCell.h
//  TouchPalDialer
//
//  Created by zhang Owen on 11/10/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallLogDataModel.h"
#import "FaceSticker.h"
#import "CootekTableViewCell.h"
#import "UIView+WithSkin.h"
#import "WithEyeViewForBaseContactCell.h"
#import "TPUIButton.h"

#define CALLLOG_CELL_HEIGHT (66)
#define CALLLOG_CELL_MARGIN_LEFT (36)

#define NAME_LABEL_DIFF (6)

@interface CallLogCell : WithEyeViewForBaseContactCell <SelfSkinChangeProtocol>{
	TPUIButton *detailButton;
    UILabel *dateLabel;
    UILabel *voipLabel;
}
@end
