//
//  FuWuHaoListController.h
//  TouchPalDialer
//
//  Created by tanglin on 15-8-4.
//
//

#ifndef TouchPalDialer_FuWuHaoListController_h
#define TouchPalDialer_FuWuHaoListController_h
#import "CootekViewController.h"
#import "PublicNumberMessage.h"

@interface PublicNumberListController : CootekViewController <UITableViewDataSource,
UITableViewDelegate>

@property(nonatomic, retain) HeaderBar *headerView;
@property(nonatomic, retain) UITableView *displayTableView;
@property(nonatomic, retain) TPHeaderButton *gobackBtn;
@property(nonatomic, retain) NSMutableArray *publicNumberInfos;
@property(nonatomic, retain) UIImageView* blankImage;
@property(nonatomic, retain) UILabel* emptyTitleLabel;
@property(nonatomic, retain) UILabel* emptyContentLabel;

+ (void)requestForPublicNumberInfos;
+ (void)requestForPublicNumberMsgs:(int) count;
+ (void)requestForPublicNumberInfoByServiceId:(NSString *)serviceId;
+ (void)addPublicNumberMessage:(NSDictionary *)msg;
+ (void)updateAdvertisementMsg:(PublicNumberMessage *)m;
@end
#endif
