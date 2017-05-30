//
//  CommonSingleSelectTableViewController.h
//  TouchPalDialer
//
//  Created by Sendor on 11-9-9.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommonSingleSelectDelegate

- (void)onSelectedData:(int)data;

@end

@interface  CommonSingleSelectData : NSObject
{
    NSString* name;
    int data;
}

@property(nonatomic, retain) NSString* name;
@property(nonatomic) int data;

-(id)initWithName:(NSString*)paraName withData:(int)paraData;

@end


@interface CommonSingleSelectTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    id<CommonSingleSelectDelegate> delegate;
    NSArray *all_items;
    NSArray *existed_datas;
}

@property(nonatomic, retain) NSArray *all_items;
@property(nonatomic, retain) NSArray *existed_datas;

- (id)initWithAllItems:(NSArray*)allItems existedDatas:(NSArray*)existedDatas delegate:(id<CommonSingleSelectDelegate>)paraDelegate;
- (BOOL)isExistedData:(int)data;

@end
