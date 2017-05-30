//
//  ContactTransferMainController.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/18.
//
//

#ifndef ContactTransferMainController_h
#define ContactTransferMainController_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactTransferConst.h"


#define TOP_PART_HEIGHT_PERCENT (0.56)
#define TOP_PART_HEIGHT_PERCENT_SMALL (0.6)

#define AVATAR_DIAMETER_PERCENT (0.3)
#define AVATAR_DIAMETER_PERCENT_SMALL (0.35)

#define AVATAR_MARGIN_BOTTOM_PERCENT (0.088)
#define AVATAR_MARGIN_BOTTOM_PERCENT_SAMLL (0.062)

#define ICON_TOP_MARGIN_PERCENT (0.10)
#define ICON_TOP_MARGIN_PERCENT_SAMLL (0.66)

@interface ContactTransferMainController : UIViewController

@end


@interface TransferDirectionInfo : NSObject
@property (nonatomic) NSString *imageName;
@property (nonatomic) NSString *mainTitle;
@property (nonatomic) NSString *altTitle;
@property (nonatomic, assign) ContactTransferDirection direction;

@end

@interface TransferDirectionView : UIView
- (instancetype) initWithDirectionInfo: (TransferDirectionInfo *) info;

@property (nonatomic) UIButton *imageButton;
@property (nonatomic) TransferDirectionInfo *info;
@end

#endif /* ContactTransferMainController_h */
