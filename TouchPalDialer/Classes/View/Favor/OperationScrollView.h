//
//  OpertionScrollView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteDataModel.h"

@interface OperationScrollView : UIView<UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>{
	FavoriteDataModel *fav_person;
    NSArray *phones_list;
}

@property(nonatomic,retain) FavoriteDataModel *fav_person;
@property(nonatomic,retain) NSArray *phones_list;
@property(nonatomic,retain) UIView *contentView;

-(id)initWithPersonID:(FavoriteDataModel *)fav withArray:(NSMutableArray *)array;
@end
