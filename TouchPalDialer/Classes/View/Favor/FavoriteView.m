//
//  FavoriteView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "FavoriteView.h"
#import "FavScrollView.h"

@implementation FavoriteView

@synthesize person_opera_delegate;
@synthesize fav_list;

- (id)initWithFrame:(CGRect)frame WithFavList:(NSArray *)list_person {
    self = [super initWithFrame:frame];
    if (self) {
		self.fav_list=list_person;	
		FavScrollView *scrollView = [[FavScrollView alloc] initWithFrame:
                                     CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(365)) WithFavList:self.fav_list];
		scrollView.person_opera_delegate = self;
		[self addSubview:scrollView];
    }
    return self;
}

#pragma mark FavoPersonViewProtocoldelegate

- (void)showOperationView:(UIView *)op_view
{
	[person_opera_delegate showOperationView:op_view];
}
- (void)closeOperationView:(UIView *)op_view
{
	[person_opera_delegate closeOperationView:op_view];
}
- (void)setCurrentPage:(NSInteger)current
{
	[person_opera_delegate setCurrentPage:current];
}


@end
