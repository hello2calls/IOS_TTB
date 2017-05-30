//
//  GroupManagerViewController.m
//  TouchPalDialer
//
//  Created by Sendor on 11-8-29.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "GroupManagerViewController.h"
#import "HeaderBar.h"
#import "Group.h"
#import "consts.h"
#import "GroupModel.h"
#import "CootekNotifications.h"
#import "TPHeaderButton.h"
#import "ChangeGroupService.h"
#import "SkinHandler.h"
#import "TPDialerResourceManager.h"
#import "UITableView+TP.h"
#import "UIButton+DoneButton.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingCellView.h"

@implementation GroupManagerViewController

@synthesize group_table_view;
@synthesize cancel_but;
#pragma mark -
#pragma mark Initialization
-(void)goToBack{
	GroupModel *groupModel = [GroupModel pseudoSingletonInstance];
	[groupModel saveSortedGroups];
    NSString *flag = (NSString *)[[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"ExpandableViewController_statusBar_style"];
    if ([flag isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.view.frame = CGRectMake(TPScreenWidth(), 20 - TPHeaderBarHeightDiff(), TPScreenWidth(), TPAppFrameHeight());
                     }
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                     }];
}

-(void)popUpToTop {
    [group_table_view reloadData];
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.view];
    NSString *flag = (NSString *) [[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"statusBar_isDefaultStyle"];
    if ([flag isEqualToString:@"1"]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.view.frame = CGRectMake(0, 20 - TPHeaderBarHeightDiff(), TPScreenWidth(), TPAppFrameHeight());
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)addGroup{
    [[ChangeGroupService getSharedChangeGroupService] addGroup];
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
    // content view
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(TPScreenWidth(), 20 - TPHeaderBarHeightDiff(), TPScreenWidth(), TPAppFrameHeight())];
    contentView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    self.view = contentView;
    
    // HeaderBar
    HeaderBar* headBar = [[HeaderBar alloc] initHeaderBar];
    [headBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headBar];
    
    // back button

    cancel_but = [[TPHeaderButton alloc] initWithFrame:CGRectMake(0,3, 50, 45) ];
    [cancel_but setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [cancel_but setTitle:NSLocalizedString(@"Done",@"") forState:UIControlStateNormal];
    [cancel_but addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
    [headBar addSubview:cancel_but];
    
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, TPHeaderBarHeightDiff(), TPScreenWidth() - 60*2, 45)];
    [headerTitle setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.text = NSLocalizedString(@"Manage groups", @"");
    [headBar addSubview:headerTitle];
    
    // add group button
    TPHeaderButton *addGroupButton = [[TPHeaderButton alloc] initWithFrame:CGRectMake(TPScreenWidth()-50,0, 50, 45)];
    [addGroupButton setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [addGroupButton setTitle:NSLocalizedString(@"Add", @"") forState:UIControlStateNormal];
    [addGroupButton addTarget:self action:@selector(addGroup) forControlEvents:UIControlEventTouchUpInside];
    [headBar addSubview:addGroupButton];
    
    // group table
    UITableView *groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415))];
    [groupTableView setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
    [groupTableView setExtraCellLineHidden];
    groupTableView.delegate = self;
    groupTableView.dataSource = self;
    [groupTableView setEditing:YES];
    self.group_table_view = groupTableView;
    [contentView addSubview:groupTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupModelChanged) name:N_GROUP_MODEL_CHANGED object:nil];
    
    [group_table_view setEditing:YES];
    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self.view];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GroupModel *groupModel = [GroupModel pseudoSingletonInstance];
    return [groupModel.groups count] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	GroupModel *groupModel = [GroupModel pseudoSingletonInstance];
    GroupItemData* item = ((GroupItemData*)([groupModel.groups objectAtIndex:[indexPath row]]));
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(![cell isKindOfClass:[CustomEditingCell class]]) {
        cell = nil;
    }
    if (cell == nil) {
        CustomEditingCell * newCell = [[CustomEditingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [newCell setSkinStyleWithHost:self forStyle:@"CootekTableViewCell_style"];
        newCell.delegate = self;
        cell = newCell;
    }
    //fix bug 33633 that text needs four space ahead
    cell.textLabel.text = [NSString stringWithFormat:@"    %@", item.group_name];
    ((CustomEditingCell*) cell).cell_data = item.group_id;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        //int groupId = ((CustomEditingCell*)([group_table_view cellForRowAtIndexPath:indexPath])).cell_data;
        GroupModel *groupModel = [GroupModel pseudoSingletonInstance];
        [groupModel deleteGroup:[indexPath row]];
        [group_table_view reloadData];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    GroupModel *groupModel = [GroupModel pseudoSingletonInstance];
    [groupModel moveGroupFrom:[fromIndexPath row] to:[toIndexPath row]];
}

#pragma mark -
#pragma mark CircleViewController
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    cootek_log(@"Received memory warning in GroupManagerViewController.");
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark mark -
#pragma mark CustomEditingCellProtocol

- (void)clickCell:(UITableViewCell*)cell {
    CustomEditingCell* cellItem = (CustomEditingCell*)cell;
    [[ChangeGroupService getSharedChangeGroupService] renameGroupById:cellItem.cell_data oldName:[cell.textLabel.text substringFromIndex:4]];
}

#pragma mark notification
- (void)onGroupModelChanged {
    [group_table_view reloadData];
}

@end

