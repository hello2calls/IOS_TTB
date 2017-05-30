//
//  PageView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "PageView.h"
#import "FavoPersonView.h"
#import "consts.h"
#import "FavoriteModel.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "CootekNotifications.h"

@implementation PageView

@synthesize page_number;
@synthesize fav_list_one;
@synthesize person_opera_delegate;

-(id)initWithPageNumber:(NSInteger)number FavoritesList:(NSArray *)list_fav Frame:(CGRect)frame
{    
    self = [super initWithFrame:frame];
    if (self) {
        int padding = 10;
        int rows = 3;
        int columns = 2;
        int size = rows * columns;
        CGFloat childViewHeight = frame.size.height / rows - padding;
        cootek_log(@"childViewHeight: %f",childViewHeight);
		self.fav_list_one = list_fav;
		self.page_number = number;
		for (NSInteger i = 0 ; i < rows; i++) {
			for(NSInteger j = 0 ; j < columns; j ++) {
				if(columns*i+j < fav_list_one.count){
					FavoriteDataModel *fav = [fav_list_one objectAtIndex:columns*i+j];
					int position=number*size+i*columns+j;
			        FavoPersonView *fav_view=[[FavoPersonView alloc] initWithFavoPerson:fav
                                                                              WithFrame:CGRectMake((145+padding)*j+padding, i*(childViewHeight+padding)+padding, 145, childViewHeight)
                                                                                  Index:position
                                                                               withPage:page_number];
                    [fav_view setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
					fav_view.person_opera_delegate = self;
					[self addSubview:fav_view];
				}
			}
		}
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(ChangePage:) 
													 name:N_FAVORITE_DELETE_PAGE_CHANGE 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(pageNumberChange)
													 name:N_FAVORITE_PAGE_CHANGED 
												   object:nil];
	}
	return self;
}

-(void)pageNumberChange{
	int numberCount=[FavoriteModel Instance].page_number;
	if (self.page_number==numberCount) {
		cootek_log(@"self remove from scroll");
		//self.person_opera_delegate
		[self removeFromSuperview];
	}
}

-(void)ChangePage:(id)currentfav
{
	NSInteger currentPage=[[[currentfav userInfo] objectForKey:KEY_FAVORITE_DATA_ONE] intValue];
	if (currentPage>=0&&currentPage==page_number) {
		[FavoriteModel Instance].change_page_fav.person_opera_delegate=self;
        [FavoriteModel Instance].change_page_fav.item_current_page = self.page_number;
		[self addSubview:[FavoriteModel Instance].change_page_fav];
	}
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
- (void)dealloc {
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
