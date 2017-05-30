    //
//  FavorViewController.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "FavorViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "FavoriteView.h"
#import "PersonOperationView.h"
#import "HeaderBar.h"
#import "Favorites.h"
#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "ContactInfoManager.h"
#import "CootekNotifications.h"

@implementation FavorViewController
@synthesize fav_controller;
@synthesize oper_view;

- (void)loadView {
	
	UIView *emptyview = [[UIView alloc] initWithFrame:CGRectMake(TPScreenWidth()*2, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT)];
	self.view = emptyview;
    [emptyview setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
	
	// for header.
	HeaderBar *header = [[HeaderBar alloc] initHeaderBar];
    [header setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
	[self.view addSubview:header];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    titleLabel.text = NSLocalizedString(@"My favorites",@"");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:titleLabel];
	
	// add
	TPHeaderButton *add_but = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth()-50, 0, 50, 45)];
    [add_but setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [add_but setTitle:NSLocalizedString(@"Add", @"") forState:UIControlStateNormal];
	[add_but addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
	[header addSubview:add_but];
	
	FavoriteViewController *controller_fav_temp = [[FavoriteViewController alloc] init];
	[self.view addSubview:controller_fav_temp.view];
	controller_fav_temp.person_opera_delegate = self;
	self.fav_controller = controller_fav_temp;
	self.fav_controller.view.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self.view];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(showContactDetail:) 
												 name:N_FAV_TO_PERSON_DETAIL 
											   object:nil];	
}

- (void)viewWillAppear:(BOOL)animated {
	if (oper_view) {
		[oper_view  removeFromSuperview];
	}
    [super viewWillAppear:animated];
	cootek_log(@"==TAB== Favor view will appear.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    cootek_log(@"Received memory warning in FavorViewController.");
}

-(void)addToFavorites{	
	SelectViewController *select_temp = [[SelectViewController alloc] init];
    select_temp.delegate = self;
	UINavigationController *navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    [navigationController presentViewController:select_temp animated:YES completion:^(){}];
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showContactDetail:(NSNotification *)notification {
	NSDictionary *info_dic = [notification userInfo];
	int person_id = [[info_dic objectForKey:@"fav_person_id"] intValue];
	if (person_id > 0) {
		[[ContactInfoManager instance] showContactInfoByPersonId:person_id];
	}
}

#pragma mark FavoPersonViewProtocoldelegate
- (void)setCurrentPage:(NSInteger)current{
	[[FavoriteModel Instance] setCurrentPage:current];
}

- (void)showOperationView:(UIView *)op_view{
	self.oper_view = (PersonOperationView *)op_view;
    UIWindow *currentWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [currentWindow addSubview:op_view];
    [currentWindow bringSubviewToFront:op_view];
}

- (void)closeOperationView:(UIView *)op_view{
	[op_view removeFromSuperview];
}

- (void)showAllContactList {
	[self addToFavorites];
}

-(void)selectViewFinish:(NSArray *)select_list {
	[Favorites addFavoriteByRecordIdArray:select_list];
}

- (void)selectViewCancel {
}
@end
