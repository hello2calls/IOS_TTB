//
//  AllServiceViewController.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/6.
//
//

//#import "CootekViewController.h"

@interface AllServiceViewController : UIViewController<UITableViewDataSource,
UITableViewDelegate>

@property(nonatomic, strong) UIView* headerView;
@property(nonatomic, strong) UIView* contentView;
@property(nonatomic, strong) UITableView* contentTableView;
@property(nonatomic, strong) UITableView* titleTableView;
@property(nonatomic, strong) NSMutableDictionary* categoryCount;
@property(nonatomic, strong) NSMutableArray* classifyItems;
@property(nonatomic, strong) NSMutableArray* serviceArray;

@end
