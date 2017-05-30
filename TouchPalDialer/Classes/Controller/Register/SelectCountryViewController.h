//
//  SelectCountryViewController.h
//  TouchPalDialer
//
//  Created by Alice on 11-10-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterProtocol.h"
#import "SectionIndexView.h"
#import "ClearView.h"
@interface SelectCountryViewController : UIViewController<UITableViewDelegate,
														UITableViewDataSource,
                                                        SectionIndexDelegate,
                                                        RegisterProtocolDelegate> {
	UITableView *m_table_view;
	NSMutableDictionary *all_country_dic;
	NSMutableArray *keys_arr;	
	NSMutableDictionary *m_country_code_dic;
	NSMutableArray *tmp_mutablearr;
    SectionIndexView *sectionIndexView_;
    ClearView *clearView_;
	id<RegisterProtocolDelegate> __unsafe_unretained delegate;
    NSDictionary __strong *sectionMap_;
    UILabel *titleLabel_;
}
@property(nonatomic,assign)id<RegisterProtocolDelegate> delegate;
@property(nonatomic,assign)BOOL loadSimSettingData;

@end
