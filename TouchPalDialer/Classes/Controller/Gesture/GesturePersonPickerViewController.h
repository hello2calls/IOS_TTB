//
//  GesturePersonPickerViewController.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCellView.h"
#import "SelectModel.h"
#import "SelectSearchResultView.h"
#import "ContactSearchModel.h"
#import "GestureUtility.h"
#import "TPUISearchBar.h"

@interface GesturePersonPickerViewController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,SelectViewProtocalDelegate>
@property(nonatomic,retain)TPUISearchBar *m_searchbar;
@property(nonatomic,retain)UITableView *m_contentView;
@property(nonatomic,retain)SelectModel *selectItem;
@property(nonatomic,retain)NSArray *personList;
@property(nonatomic,retain)NSArray *oftenContactsList;
@property(nonatomic,assign)GestureActionType actionKey;
@property(nonatomic,retain)SelectCellView *preTableViewCell;
@property(nonatomic,retain)ContactSearchModel *searchEngine;

- (id)initWithPopToRoot:(BOOL)shouldPopToRoot;

@end
