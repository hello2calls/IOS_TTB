//
//  CitySelectViewController.h
//  TouchPalDialer
//
//  Created by tanglin on 15/8/26.
//
//

#import <UIKit/UIKit.h>
#import "CootekViewController.h"

@interface CitySelectViewController : CootekViewController <UITableViewDataSource,
UITableViewDelegate>

@property(nonatomic, strong) UITableView* cityTableView;
@property(nonatomic, strong) UITableView* letterTableView;
@property(nonatomic, strong) UIView* headerView;
@end
