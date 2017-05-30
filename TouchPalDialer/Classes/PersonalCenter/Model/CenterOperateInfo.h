//
//  CenterOperateInfo.h
//  TouchPalDialer
//
//  Created by game3108 on 15/5/12.
//
//

#import <Foundation/Foundation.h>
#import "NoahManager.h"

typedef enum {
    WALLET_INFO,
    BACK_FEE_INFO,
    CARD_INFO,
    FREE_MINUTE_INFO,
    ACTIVITY_INFO,
    RED_BAG_INFO,
    SKIN_INFO,
    VOIP_INFO,
    HELP_INFO,
    LOG_OUT_INFO,
    ANTIHARASS_INFO,
    TRAFFIC_INFO,
    EXCHANGE_INFO,
    TOUCHPAL_FAN_INFO,
    DIALER_SETTING,
    VIP_INFO,
} OperationCellType;

typedef enum {
    LONG_CELL,
    RECT_CELL
} OperationCellViewType;

@protocol CenterOperateDelegate <NSObject>
- (void) onOperatePress:(OperationCellType)type;
@end

@interface CenterOperateInfo : NSObject
@property (nonatomic,assign) BOOL ifHidden;
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,strong) NSString *iconText;
@property (nonatomic,strong) NSString *iconColor;
@property (nonatomic,strong) NSString *iconTypeName;
@property (nonatomic,strong) NSString *labelText;
@property (nonatomic,strong) NSString *labelSubText;
@property (nonatomic,assign) BOOL subtitleHidden;
@property (nonatomic,assign) PointType dotType;
@property (nonatomic,strong) NSString *guidePointId;
@property (nonatomic,strong) NSAttributedString *rightAttrText;
@property (nonatomic,assign) id<CenterOperateDelegate> delegate;
@property (nonatomic,assign) OperationCellType cellViewType;
@property (nonatomic,assign) BOOL lastItem;
@end
