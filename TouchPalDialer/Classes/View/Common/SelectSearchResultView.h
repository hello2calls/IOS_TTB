//
//  SelectSearchResultView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-24.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectViewProtocal.h"
#import "SearchResultModel.h"
@interface SelectSearchResultView : UIView<UITableViewDelegate,UITableViewDataSource,SelectViewProtocalDelegate,UIScrollViewDelegate> {
	UITableView *m_tableview;
	SearchResultModel *result_arr;
	
}

@property(nonatomic, retain) UITableView *m_tableview;
@property(nonatomic, retain) SearchResultModel *result_arr;
@property(nonatomic, assign) id<SelectViewProtocalDelegate> select_delegate;
@property(nonatomic, assign) BOOL isSingleCheckMode;

- (id)initWithArray:(SearchResultModel *)result_list;
- (id)initWithArray:(SearchResultModel *)result_list andFrame:(CGRect)frame;
- (void)refreshMyResult:(SearchResultModel *)result;
- (BOOL)isSelectedPersonInSearch:(NSInteger)personID withObject:(id)object;
- (void)refreshView;
@end
