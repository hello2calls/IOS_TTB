    //
//  FavoriteViewController.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-17.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "FavoriteViewController.h"
#import "UIView+WithSkin.h"
#import "CootekNotifications.h"
#import "SkinHandler.h"
#import "TPDialerResourceManager.h"

@implementation FavoriteViewController

@synthesize fav_view;
@synthesize person_opera_delegate;
@synthesize fav_model;
@synthesize noFavorHint;

- (void)loadView {
	UIView *emptyview = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(365))];
	self.view = emptyview;
    emptyview.backgroundColor = [UIColor clearColor];
	
	self.fav_model = [FavoriteModel Instance];
	
	NSArray *tmpFavList = [self.fav_model getFavriteList];
	FavoriteView *favorite = [[FavoriteView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(365)) WithFavList:tmpFavList];
	favorite.person_opera_delegate = self;
	[self.view addSubview:favorite];
	self.fav_view = favorite;
    

    FavoriteNopersonHintView *tmpNoFavorHint = [[FavoriteNopersonHintView alloc] initWithFrame:CGRectMake(0, 60, TPScreenWidth(), 200)];
    noFavorHint = tmpNoFavorHint;
    [noFavorHint setSkinStyleWithHost:self forStyle:@"noFavorHint_style"];
    [noFavorHint.fav_button setTitle:NSLocalizedString(@"Add favorites to this page", @"") forState:UIControlStateNormal];
    [noFavorHint.fav_button addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
    noFavorHint.hidden = YES;
    [self.view addSubview:noFavorHint];
    if ([tmpFavList count] == 0) {
        noFavorHint.hidden = NO;
        [self.view bringSubviewToFront:noFavorHint];
    }
    
    }

-(void)addToFavorites
{
	[person_opera_delegate showAllContactList];
}

-(void)reloadFavoriteView
{
	if (self.fav_view) {
		[self.fav_view removeFromSuperview];
	}
	NSArray *fav_list = [self.fav_model getFavriteList];
	if ([fav_list count] > 0) {		
        noFavorHint.hidden = YES;

		cootek_log(@"******************************** list count is %d", [fav_list count]);
		FavoriteView *favorite = [[FavoriteView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(365)) WithFavList:fav_list];
		favorite.person_opera_delegate = self;
		[self.view addSubview:favorite] ;
		self.fav_view = favorite;
		
	} 
}

- (void)favorPageChanged
{
	if ([[fav_model getFavriteList] count] == 0) {
        noFavorHint.hidden = NO;
        [self.view bringSubviewToFront:noFavorHint];

	}
}
- (void)viewDidLoad
{
    [super viewDidLoad];	
     [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self.view];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reloadFavoriteView) 
												 name:N_FAVORITE_DATA_CHANGED 
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reloadFavoriteView) 
												 name:N_SYSTEM_CONTACT_DATA_CHANGED 
											   object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(favorPageChanged) 
												 name:N_FAVORITE_PAGE_CHANGED 
											   object:nil];	
}

-(void)viewWillAppear:(BOOL)animated{	
    [super viewWillAppear:animated];
	cootek_log(@"==TAB-->FavorController== Favorite View Controller will appear.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    cootek_log(@"Received memory warning in FavoriteViewController.");
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
	[fav_model setCurrentPage:current];
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
