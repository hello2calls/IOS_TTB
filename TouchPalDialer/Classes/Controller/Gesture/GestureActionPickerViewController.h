//
//  GestureActionPickerViewController.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCacheDataModel.h"
#import "CootekViewController.h"
@interface GestureActionPickerViewController : CootekViewController<UITableViewDataSource,UITableViewDelegate>{
    NSInteger personID;
    NSString *keyName;
    UITableView *gestureTable;
    ContactCacheDataModel *contactModel;
    NSArray *phoneList;
}
@property(nonatomic, retain)UITableView *gestureTable;
@property(nonatomic,assign) NSInteger personID;
@property(nonatomic,retain) NSString *keyName;
@property(nonatomic,retain) ContactCacheDataModel *contactModel;
@property(nonatomic,retain) NSArray *phoneList;

- (id)initWithPersonID:(NSInteger)tmppersonID;
@end
