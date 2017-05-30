//
//  FuWuHaoDetailController.h
//  TouchPalDialer
//
//  Created by tanglin on 15-8-4.
//
//

#ifndef TouchPalDialer_FuWuHaoDetailController_h
#define TouchPalDialer_FuWuHaoDetailController_h
#import "CootekViewController.h"
#import "PublicNumberMessage.h"
#import "TPBottomBar.h"
#import "PublicNumberModel.h"

@interface PublicNumberDetailController:  CootekViewController <UITableViewDataSource,
UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property(nonatomic, retain) HeaderBar *headerView;
@property(nonatomic, retain) UITableView *displayTableView;
@property(nonatomic, retain) NSMutableArray *publicNumberMesssages;
@property(nonatomic, retain) TPHeaderButton *gobackBtn;
@property(nonatomic, retain) TPBottomBar *bottomBar;
@property(nonatomic, retain) PublicNumberModel *model;
@property(nonatomic, retain) UIRefreshControl* refreshControl;
@property(nonatomic, retain) UIButton* confirmButton;
@property(nonatomic, retain) UIButton* cancelButton;

@end
#endif
