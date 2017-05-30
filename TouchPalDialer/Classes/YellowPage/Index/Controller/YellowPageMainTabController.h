//
//  YellowPageMainTabController.h
//  TouchPalDialer
//
//  Created by tanglin on 15-3-31.
//
//

#import <Foundation/Foundation.h>
#import "CootekViewController.h"
#import "SearchRowView.h"
#import "EntranceIcon.h"
#import "LoadMoreTableFooterView.h"
#import "PublicNumberCenterView.h"

@interface YellowPageMainTabController : UIViewController <UITableViewDataSource,
UITableViewDelegate,EntranceIconDelegate,LoadMoreTableFooterDelegate>
{
    UITableView *all_content_view;
}

@property(nonatomic, retain) HeaderBar *headerView;
@property(nonatomic, retain) UITableView *all_content_view;
@property(nonatomic, retain) NSDictionary *yellowpage_data;
@property(nonatomic, retain) LoadMoreTableFooterView* load_more_foot_view;
@property(nonatomic, assign) BOOL notHome;
@property(nonatomic, retain) PublicNumberCenterView* pnCenter;
@property(nonatomic, retain) UIImageView* fullScreenAds;


- (void) initLoad;
- (void) controlAccessoryView:(NSNumber *)alphaValue;


+ (void) startCityPage;
@end