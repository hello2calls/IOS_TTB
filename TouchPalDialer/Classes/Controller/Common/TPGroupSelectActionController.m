//
//  TPGroupSelectActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/20/12.
//
//

#import "TPGroupSelectActionController.h"
#import "ContactGroupDBA.h"
#import "GroupDataModel.h"
#import "Group.h"
#import "GroupModel.h"
#import "DetailGroupInfo.h"
#import "GroupSelector.h"

static TPGroupSelectActionController *instance;

@implementation TPGroupSelectActionController

+ (void)initialize{
    instance = [[TPGroupSelectActionController alloc]init];
}

+(TPGroupSelectActionController *)controller
{
    return instance;
}

-(void)selectGroupByPersonId:(NSInteger)personId
                    pushedBy:(UINavigationController *)aNavigationController
{
    if (personId <= 0) {
        return;
    }
    
    NSArray *groupDataModels = [self groupDataModelsByPersonId:personId];
    NSMutableArray* detailGroupInfos = [[NSMutableArray alloc] init];
    NSArray* allGroups = [GroupModel pseudoSingletonInstance].groups;
    for (int i=0; i< [allGroups count]-1; i++) {
        GroupItemData *groupItem = [allGroups objectAtIndex:i];
        DetailGroupInfo *detailGroupInfo = [[DetailGroupInfo alloc] init];
        detailGroupInfo.group_data_model = [Group getGroupByGroupID:groupItem.group_id];
        detailGroupInfo.in_this_group = NO;
        for (GroupDataModel *memberGroupItem in groupDataModels) {
            if (groupItem.group_id == memberGroupItem.groupID) {
                detailGroupInfo.in_this_group = YES;
                break;
            }
        }
        [detailGroupInfos addObject:detailGroupInfo];
    }
    
    GroupSelector *groupController = [[GroupSelector alloc]init];
    groupController.personId = personId;
    groupController.delegate = self;
    groupController.groupBelongArr = detailGroupInfos;
    [aNavigationController pushViewController:groupController animated:YES];
}

#pragma mark GroupSelectorDelegate
-(NSArray *)groupDataModelsByPersonId:(NSInteger)personId {
    NSArray* personGroupIds = [ContactGroupDBA getMemberGroups:personId];
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[personGroupIds count]];
    for (NSNumber* item in personGroupIds) {
        GroupDataModel *group = [Group getGroupByGroupID:[item intValue]];
        if (group) {
            [arr addObject:group];
        }
    }
    return arr;
}

- (void)groupChanged {
    
}

@end
