//
//  YellowPageViewController.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectViewProtocal.h"
#import "SelectView.h"


@interface SelectViewController: UIViewController<SelectViewProtocalDelegate> {
    id<SelectViewProtocalDelegate> __unsafe_unretained delegate;
	SelectView *select_view;
    SelectViewType viewType;
    NSString *commandName;
    BOOL autoDismiss;
}

@property(nonatomic,retain)SelectView *select_view;
@property(nonatomic,assign) id<SelectViewProtocalDelegate> delegate;
@property(nonatomic,retain)NSArray *dataList; //ContactCacheDataModel list
@property(nonatomic,assign)SelectViewType viewType;
@property(nonatomic,retain)NSString *commandName;
@property(nonatomic,assign)int groupID;

@property(nonatomic,assign)BOOL autoDismiss;
@property(nonatomic,assign)BOOL isChooseSingle;

@end
