//
//  FindNewsListViewController.h
//  TouchPalDialer
//
//  Created by tanglin on 16/5/17.
//
//

#import <UIKit/UIKit.h>
#import "LoadMoreTableFooterView.h"
#import "FindNewsItem.h"
#import "SignBtnManager.h"

@interface FindNewsListViewController : UIViewController<UITableViewDataSource,
UITableViewDelegate, LoadMoreTableFooterDelegate>

@property(nonatomic, strong) UITableView* contentTableView;
@property(nonatomic, strong) UIView* headerView;
@property(nonatomic, strong) NSString* tu;
@property(nonatomic, strong) UIView* contentView;;
@property(strong) SignBtnManager* signManager;
@property(assign) BOOL isTabSelected;
@property(strong) NSDictionary* topItems;

+ (CGFloat) heightForFindNewsRow:(FindNewsItem *)item withHeader:(BOOL)hasHeader;
@end
