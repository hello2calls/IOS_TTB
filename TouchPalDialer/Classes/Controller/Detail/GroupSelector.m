//
//  GroupSelector.m
//  TouchPalDialer
//
//  Created by zhang Owen on 12/5/11.
//  Unused code removed by Chen Lu on 9/10/12.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "GroupSelector.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TouchPalDialerAppDelegate.h"
#import "GroupDataModel.h"
#import "DetailGroupInfo.h"
#import "GroupSelectorCell.h"
#import "GroupedContactsModel.h"
#import "Group.h"
#import "GroupDBA.h"
#import "CootekNotifications.h"
#import "GroupedContactsModel.h"
#import "ChangeGroupService.h"
#import "ContactGroupDBA.h"
#import "GroupModel.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "ContactInfoManager.h"
#import "FunctionUtility.h"

@interface GroupSelector ()
@property (nonatomic, retain) UITableView *mTableView;
@end

@implementation GroupSelector
@synthesize mTableView;
@synthesize groupBelongArr;
@synthesize delegate;
@synthesize personId;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_grey_50"];
	
	UIView *header_bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 45+TPHeaderBarHeightDiff())] ;
    header_bar.backgroundColor = [FunctionUtility getBgColorOfLongPressView];

	UIButton *back_btn = [[UIButton alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(), 50, 45)];
    [back_btn setBackgroundImage:[TPDialerResourceManager getImage:@"white_navigation_back_icon@2x.png"] forState:UIControlStateNormal];
	[back_btn addTarget:self action:@selector(popSelector) forControlEvents:UIControlEventTouchUpInside];
	[header_bar addSubview:back_btn];
	[header_bar bringSubviewToFront:back_btn];
	[self.view addSubview:header_bar];
    
    // add group button
    TPHeaderButton *addGroupButton = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth()-50,0, 50, 45)];
    [addGroupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addGroupButton setTitle:NSLocalizedString(@"Add", @"") forState:UIControlStateNormal];
    addGroupButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    [addGroupButton addTarget:self action:@selector(addGroup) forControlEvents:UIControlEventTouchUpInside];
    [header_bar addSubview:addGroupButton];
    
	UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(80, TPHeaderBarHeightDiff(), TPScreenWidth() - 160, header_bar.frame.size.height - TPHeaderBarHeightDiff())];
    titlelabel.textColor = [UIColor whiteColor];
    titlelabel.backgroundColor = [UIColor clearColor];
	titlelabel.font = [UIFont systemFontOfSize:CELL_FONT_XTITLE];
	titlelabel.textAlignment = NSTextAlignmentCenter;
	titlelabel.text = NSLocalizedString(@"Select group", @"");
	[header_bar addSubview:titlelabel];
	
    CGRect tableViewRect = CGRectMake(0, header_bar.frame.size.height, TPScreenWidth(),
                                      TPAppFrameHeight() - header_bar.frame.size.height+TPHeaderBarHeightDiff());
	mTableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
    [mTableView setExtraCellLineHidden];
    [mTableView setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
    mTableView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_grey_50"];
	mTableView.delegate = self;
	mTableView.dataSource = self;
    mTableView.rowHeight = 50;
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:mTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDataForAddingGroup)
                                                 name:N_GROUP_MODEL_ADDED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:N_GROUP_MODEL_CHANGED
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SkinHandler removeRecursively:self];
}

- (void)popSelector {
    int personID;
    if(personId > 0){
        personID = personId;
    } else {
        personID = [[ContactInfoManager instance] getPersonId];
    }
	int count = [groupBelongArr count];
	for (int i = 0; i < count; i++) {
		DetailGroupInfo *groupInfo = [groupBelongArr objectAtIndex:i];
		int groupId = groupInfo.group_data_model.groupID;
		if (groupInfo.in_this_group) {
            [GroupedContactsModel addMemberById:personID toGroup:groupId];
            NotiPersonGroupChangeData *contactGroup =
            [[NotiPersonGroupChangeData alloc] initWithGroupContact:groupId
                                                        withPersonID:personID
                                                          changeType:ContactChangeTypeAddToGroup];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObject:contactGroup
                                                                                                   forKey:KEY_GROUP_PERSON_ID]];
		} else {
            [GroupedContactsModel deleteMemberById:personID fromGroup:groupId];
            NotiPersonGroupChangeData *contactGroup =
            [[NotiPersonGroupChangeData alloc] initWithGroupContact:groupId
                                                        withPersonID:personID
                                                          changeType:ContactChangeTypeDeleteFromGroup];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObject:contactGroup
                                                                                                   forKey:KEY_GROUP_PERSON_ID]];
		}
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                        object:nil
                                                      userInfo:nil];

	
	cootek_log(@"ready to pop");
    if ([(id)delegate respondsToSelector:@selector(groupChanged)]) {
        [delegate groupChanged];
    }
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (groupBelongArr != nil) {
		return [groupBelongArr count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
	GroupSelectorCell *cell = [[GroupSelectorCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:CellIdentifier];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    [cell refreshSeparateLineColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"]];
	
    cell.bottomLine.hidden = NO;
	int row = [indexPath row];
	DetailGroupInfo *groupInfo = [groupBelongArr objectAtIndex:row];
	GroupDataModel *groupModel = groupInfo.group_data_model;
	cell.groupNameLabel.text = groupModel.groupName;
	
	[cell setSelectorImage:groupInfo.in_this_group];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	int row = [indexPath row];
	DetailGroupInfo *mygroupinfo = [groupBelongArr objectAtIndex:row];
	BOOL inThisGroup = mygroupinfo.in_this_group;
	if (inThisGroup) {
		mygroupinfo.in_this_group = NO;
		GroupSelectorCell *mcell = (GroupSelectorCell *)[tableView cellForRowAtIndexPath:indexPath];
		[mcell setSelectorImage:NO];
	} else {
		mygroupinfo.in_this_group = YES;
		GroupSelectorCell *mcell = (GroupSelectorCell *)[tableView cellForRowAtIndexPath:indexPath];
		[mcell setSelectorImage:YES];
	}

}

- (void)addGroup
{
     [[ChangeGroupService getSharedChangeGroupService] addGroup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadDataForAddingGroup
{
    [GroupedContactsModel addMemberById:personId toGroup:((GroupDataModel *)[[GroupDBA getAllGroups] lastObject]).groupID];
}

- (void) loadData
{
    NSArray* personGroupIds = [ContactGroupDBA getMemberGroups:personId];
	NSMutableArray *group_info_arr = [NSMutableArray arrayWithCapacity:[personGroupIds count]];
    for (NSNumber* item in personGroupIds) {
        GroupDataModel *group = [Group getGroupByGroupID:[item intValue]];
        if (group) {
            [group_info_arr addObject:group];
        }
    }
    
    NSMutableArray *tmpGgroupBelongArr = [[NSMutableArray alloc] init];
    NSArray *allGroups = [GroupModel pseudoSingletonInstance].groups;
    for (int i=0; i<([allGroups count]-1); i++) {
        GroupItemData *groupItem = [allGroups objectAtIndex:i];
        DetailGroupInfo *detailGroupInfo = [[DetailGroupInfo alloc] init];
        detailGroupInfo.group_data_model = [Group getGroupByGroupID:groupItem.group_id];
        detailGroupInfo.in_this_group = NO;
        for (GroupDataModel *memberGroupItem in group_info_arr) {
            if (groupItem.group_id == memberGroupItem.groupID) {
                detailGroupInfo.in_this_group = YES;
                break;
            }
        }
        for (DetailGroupInfo *tmp in self.groupBelongArr) {
            if (groupItem.group_id == tmp.group_data_model.groupID) {
                detailGroupInfo.in_this_group = tmp.in_this_group;
                break;
            }
        }
        [tmpGgroupBelongArr addObject:detailGroupInfo];
    }
    self.groupBelongArr = [NSArray arrayWithArray:tmpGgroupBelongArr];
    if (mTableView) {
        [mTableView reloadData];
    }
}

@end
