//
//  FavScrollView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-16.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "FavScrollView.h"
#import "FavoriteModel.h"
#import "PageView.h"
#import "CootekNotifications.h"
#import "Favorites.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "TPPageController.h"

@implementation FavScrollView

@synthesize fav_list;
@synthesize page_number;
@synthesize pageController;
@synthesize	scrollView;
@synthesize person_opera_delegate;
@synthesize current_page;

- (id)initWithFrame:(CGRect)frame WithFavList:(NSArray *)list_person {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.fav_list =list_person;
	
		page_number=[FavoriteModel Instance].page_number;
		current_page=0;
		// a page is the width of the scroll view
		scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(351))];
          [scrollView setSkinStyleWithHost:self forStyle:NO_STYLE];
		if (page_number <= 1) {
			scrollView.scrollEnabled = NO;
		} else {
			scrollView.scrollEnabled = YES;
		}
		scrollView.pagingEnabled = YES;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * page_number, scrollView.frame.size.height);
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.scrollsToTop = NO;
		scrollView.bounces = NO;
		scrollView.delegate = self;
		[self addSubview:scrollView];
		
		TPPageController *page_control = [[TPPageController alloc] initWithFrame:CGRectMake(0, TPHeightFit(345), TPScreenWidth(), 23)];
        [page_control setSkinStyleWithHost:self forStyle:@"pageControl_style"];
		page_control.numberOfPages = page_number;
		
		if (current_page < page_number) {
			pageController.currentPage = current_page;
		} else if (current_page-1 > 0) {
			pageController.currentPage =  current_page-1;
		} else {
			pageController.currentPage = 0;
		}
        
        //设置当前页
		page_control.currentPage=current_page;
        [page_control addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.page_number <= 1) {
            page_control.hidden = YES;
        } else {
            page_control.hidden = NO;
        }
		
		self.pageController = page_control;			
		[self addSubview:page_control];	
		
		//设置scrollView的位置		
		CGRect frame = self.scrollView.frame;
		frame.origin.x = frame.size.width * current_page;
		frame.origin.y = 0;
		[self.scrollView scrollRectToVisible:frame animated:YES];
	
		//加载所有页
		for (int i = 0; i < page_number; i++) {
			[self loadScrollViewWithPage:i];
		}	
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(pageNumberChange)
													 name:N_FAVORITE_PAGE_CHANGED
												   object:nil];
    }
    return self;
}
- (void)pageNumberChange{
	page_number=[FavoriteModel Instance].page_number;
	pageController.numberOfPages = page_number;
    if (page_number <= 1) {
        pageController.hidden = YES;
    } else {
        pageController.hidden = NO;
    }
	scrollView.contentSize=CGSizeMake(scrollView.frame.size.width * page_number, scrollView.frame.size.height);
}
- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= page_number) return;
	
	NSArray *fav_list_one = [self getFavData:page];
	PageView *mPageView = [[PageView alloc] initWithPageNumber:page FavoritesList:fav_list_one Frame:
                           CGRectMake(TPScreenWidth()*page, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
	mPageView.person_opera_delegate = self;
	[scrollView addSubview:mPageView];
}

-(NSArray *)getFavData:(NSInteger)page
{
	int count = [fav_list count]; 
	NSMutableArray *fav_one_page = [NSMutableArray arrayWithCapacity:6];
	for (int i = 0; (i<6)&&((6*page+i)<count); i++) {
		[fav_one_page addObject:[fav_list objectAtIndex:6*page+i]];	  
	}
	return fav_one_page;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	if (page!=current_page) {
		current_page=page;
		pageController.currentPage = page;
		[person_opera_delegate setCurrentPage:page];
	} 
}
- (void)changePage:(id)sender {
    int page = pageController.currentPage;
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
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
