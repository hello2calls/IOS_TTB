//
//  FavoriteModel.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonOperationView.h"
#import "FavoPersonView.h"
@interface FavoriteModel : NSObject {
	NSInteger current_page;
	BOOL isTouchEnable;
	NSMutableArray *current_fav_list;
	NSInteger page_number;
	FavoPersonView *change_page_fav;
}


@property(nonatomic,assign) NSInteger current_page;
@property(nonatomic,assign) NSInteger page_number;
@property(nonatomic,assign) BOOL isTouchEnable;
@property(nonatomic,retain) NSMutableArray *current_fav_list;
@property(nonatomic,retain) FavoPersonView *change_page_fav;
//实例方法
+ (FavoriteModel *)Instance;
- (void)setCurrentPage:(NSInteger)current;
- (NSArray *)getFavriteList;
- (void)refreshPageNumber;
@end
