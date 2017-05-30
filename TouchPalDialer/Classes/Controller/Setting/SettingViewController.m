//
//  SettingViewController.m
//  TouchPalDialer
//
//  Created by Ailce on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"

@implementation SettingViewController

@synthesize app_settings_model;

- (id)initWithSettingsModel:(AppSettingsModel*)settingsModel
{
    self = [super init];
    if (self) {
        // Custom initialization
        app_settings_model = settingsModel;
        [self initializeCellTitles];
    }
    return self;
}

-(void)dealloc {
    [SkinHandler removeRecursively:self];
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    table_view = [[UITableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPAppFrameHeight()-50) style:UITableViewStyleGrouped];
    table_view.backgroundView = nil;
    table_view.delegate = self;
    table_view.dataSource = self;
    [table_view setSkinStyleWithHost:self forStyle:@"defaultUITableView_style"]; 
    [self.view addSubview:table_view];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
}

- (void)gotoBack {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma UITableViewDelegate 

- (void)initializeCellTitles {
    // implement by sub class
}

@end
