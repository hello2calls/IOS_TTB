//
//  PersonInfoDescViewController.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/9/5.
//
//


/*
**
  comment       model_name              center_detail key
------------------------------------------------------------------------------------------
  免费流量       MODEL_TRAFFIC              CENTER_DETAIL_BYTES
  vip特权        MODEL_VIP_PRIVILEGE        包含vip相关的
  免费时长        MODEL_FREE_FEE            CENTER_DETAIL_MINUTES
  零钱           MODEL_BACK_FEE            CENTER_DETAIL_COINS
  卡券           （无，单独的controller）     CENTER_DETAIL_CRADS
------------------------------------------------------------------------------------------
**
*/

#import <UIKit/UIKit.h>
#import "LoginController.h"

#define MODEL_TRAFFIC @"traffic"
#define MODEL_VIP_PRIVILEGE @"vip_privilege"
#define MODEL_FREE_FEE @"free_fee"
#define MODEL_BACK_FEE @"back_fee"
#define VIP_URL @"http://search.cootekservice.com/page_v3/profit_center.html?_city=全国&_token=auth_token"


#define ID_FEE_MORE (101)
#define ID_FEE_USE (102)

#define ID_TRAFFIC_MORE (201)
#define ID_TRAFFIC_USE (202)

#define ID_MINUTES_INVITE (301)
#define ID_MINUTES_TASK (302)


#define CENTER_DETAIL_CRADS @"cards"
#define CENTER_DETAIL_BYTES @"bytes"
#define CENTER_DETAIL_COINS @"coins"
#define CENTER_DETAIL_MINUTES @"minutes"
#define CENTER_DETAIL_VIP_EXPIRED @"vip_expired"
#define CENTER_DETAIL_SERVER_TIME @"server_time"
#define CENTER_DETAIL_SAVED @"saved"
#define CENTER_DETAIL_BYTES_F @"bytes_f"
#define VIP_URL @"http://search.cootekservice.com/page_v3/profit_center.html?_city=全国&_token=auth_token"

#define PROFIT_CENTER_URL @"http://search.cootekservice.com/page_v3/profit_center.html"
#define GAME_CENTER_URL @"http://touchlife.cootekservice.com/page_v3/game_center.html"

@interface InfoDescModel : NSObject
@property (nonatomic, strong) NSArray<NSAttributedString *> *title;
@property (nonatomic, strong) NSArray *desc;
@property (nonatomic) NSInteger tag;
@property (nonatomic, copy) void (^actionBlock)();
@end

@interface InfoActionModel : NSObject
@property (nonatomic, strong) NSString *actionText;
@property (nonatomic, strong) NSString *actionHighColor;
@property (nonatomic, copy)void(^actionBlock)(void);
@end

@interface PersonInfoDescModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detailUrl;
@property (nonatomic, strong) NSString *themeColor;
@property (nonatomic, strong) NSString *iconString;
@property (nonatomic, assign) CGFloat iconSize;
@property (nonatomic, strong) NSString *iconFontName;
@property (nonatomic, strong) NSString *headerDesc1;
@property (nonatomic, strong) NSAttributedString *headerDesc2;
@property (nonatomic, strong) NSString *headerDesc3;
@property (nonatomic, strong) NSArray *contentDescs;
@property (nonatomic) NSString *contentTitle;
@property (nonatomic, strong) InfoActionModel *actionModel;
@property (nonatomic, strong) NSString *topRightIconString;
@property (nonatomic, strong) NSString *actionFontName;
@property (nonatomic) NSString *modelName;
@property (nonatomic) NSString *unit;
@property (nonatomic, strong) void(^topRightAction)(void);

+ (PersonInfoDescModel *) getModelByName: (NSString *)modelName;

+ (PersonInfoDescModel *)backFeeModel;

+ (PersonInfoDescModel *)freeFeeModel;

+ (PersonInfoDescModel *)trafficModel;

+ (PersonInfoDescModel *)PrivilegaModel;
@end

@interface PersonInfoDescViewController : UIViewController<LoginProtocol>

@property(nonatomic,retain)UILabel *label2;
@property(nonatomic,retain)UIButton *button;
@property(nonatomic,retain)UILabel *labelToWeichat;
@property(nonatomic,retain)NSString *pageType;
- (id)initWithModel:(PersonInfoDescModel *)model;
- (id)initWithModel:(PersonInfoDescModel *)model andPageType:(NSString *) type;
- (id)initWithLinkDictionary:(NSDictionary *)dic;

+ (void(^)()) getProfitCenterActionBlock;

@end
