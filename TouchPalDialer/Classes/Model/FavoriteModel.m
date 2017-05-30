//
//  FavoriteModel.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "FavoriteModel.h"
#import "Favorites.h"
#import "consts.h"

@implementation FavoriteModel

static FavoriteModel *_sharedSingletonModel = nil;

@synthesize current_page;
@synthesize isTouchEnable;
@synthesize current_fav_list;
@synthesize page_number;
@synthesize change_page_fav;

+ (FavoriteModel *)Instance
{
	if(_sharedSingletonModel)
		return _sharedSingletonModel;
	
	@synchronized([FavoriteModel class])
	{
		if (!_sharedSingletonModel){
			_sharedSingletonModel=[[self alloc] init];
		}		
	}	
	return _sharedSingletonModel;
}
///Initilize
- (id)init {
	self = [super init];
	if (self != nil) {
		current_page=0;
		isTouchEnable=NO;
		current_fav_list=nil;
		change_page_fav=[[FavoPersonView alloc] init];
	}
	return self;
}

+ (id)alloc
{

	if (!_sharedSingletonModel) {	
		_sharedSingletonModel = [super alloc];
	}
	return _sharedSingletonModel;

}

- (NSArray * )getFavriteList {
    NSMutableArray* tmp_current_fav_list = [[NSMutableArray alloc] init];
	self.current_fav_list = tmp_current_fav_list;
    NSArray *tmps = [Favorites getFavoriteList];
    if (tmps) {
        [current_fav_list addObjectsFromArray:tmps];
    }
	
	if (current_fav_list.count%6 == 0){
		self.page_number = current_fav_list.count/6 ;
	} else {
		self.page_number = current_fav_list.count/6 + 1 ;
	}	
	return current_fav_list;
}
- (void)refreshPageNumber{
	NSInteger pageNumbers;
	if (current_fav_list.count%6 == 0){
		pageNumbers= current_fav_list.count/6 ;
	} else {
		pageNumbers = current_fav_list.count/6 + 1 ;
	}
	if (pageNumbers!=self.page_number) {
		self.page_number = pageNumbers;
	}
}
- (void)setCurrentPage:(NSInteger)current
{
	current_page = current;
}
@end
