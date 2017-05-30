//
//  DemoNode.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Group.h"
#import "SmartGroupNode.h"
#import "LeafNode.h"
#import "OrlandoEngine.h"
#import "CityGroupModel.h"
#import "ContactModelNew.h"
#import "ContactCacheDataManager.h"
#import "Person.h"
#import "ContactCacheDataModel.h"
#import "GroupModel.h"
#import "GroupedContactsModel.h"
#import "CootekNotifications.h"
#import "ContactGroupDBA.h"
#import "PhonePadModel.h"
#import "ContactPropertyCacheManager.h"
#import "FunctionUtility.h"
#import "LangUtil.h"
#import <AddressBook/ABPerson.h>
#import "SeattleFeatureExecutor.h"
#import "ScheduleInternetVisit.h"
#import "TouchpalMembersManager.h"
#import "ContactPropertyCacheManager.h"
#import "UserDefaultsManager.h"
#import "TouchpalMembersManager.h"

#define FOREIGNERS @"Foreigners"
#define OTHERS    @"Others"

static SmartGroupNode *sRootNode = nil;
@implementation NoteNode
+(NoteNode *)noteNode{
    NoteNode *item = [[NoteNode alloc] initWithData:nil];
    item.imageName = @"i";
    [item onLoadData];
    [item observePersonDataChange];
    return item;
}

- (void)onLoadData{
    NSArray *noteArray = [[ContactPropertyCacheManager shareManager] valuesByPropertyID:kABPersonNoteProperty];
    
    NSMutableArray *contactsWithNote = [[NSMutableArray alloc] initWithCapacity:5];
    for(AttributeModel *noteAttr in noteArray){
        NSString *note = [[noteAttr attribute] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(note.length>0){
            [contactsWithNote addObject:[NSNumber numberWithInt:noteAttr.personID]];
        }
    }
    self.contactIds = contactsWithNote;
    self.nodeDescription = NSLocalizedString(@"Note", @"");
    self.data = [NSString stringWithFormat:@"%@ (%d)",NSLocalizedString(@"Note group", @""),contactsWithNote.count];
    self.hidden = contactsWithNote.count == 0;
}

- (void)onBeginLoadData {
    [sRootNode notifyBeginLoad];
}

- (void)onEndLoadData {
    [sRootNode notifyEndLoad];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation GroupNode
@synthesize groupID;
@synthesize groupName;
+(GroupNode *)groupNodeForGroupID:(int)groupID andGroupName:(NSString *)groupName{
    GroupNode *item = [[GroupNode alloc] initWithData:nil];
    item.groupID = groupID;
    item.groupName = groupName;
    [item onLoadData];
    return item;
}

- (void)onLoadData{
    NSArray* groupMemberIds = [Group getMemberIDListByGroupID:self.groupID];
    NSMutableArray *contactIds = [[NSMutableArray alloc] initWithCapacity:groupMemberIds.count];
    for(id Id in groupMemberIds){
        ContactCacheDataModel *cachePerson =  [[ContactCacheDataManager instance] contactCacheItem:[((NSNumber *)Id) intValue]];
        if(cachePerson){
            [contactIds addObject:Id];
        }
    }
    if(self.groupID == UNGROUPED_GROUP_ID){
        GroupedContactsModel *groupedContactsModel = [GroupedContactsModel pseudoSingletonInstance];
        [contactIds addObjectsFromArray:[groupedContactsModel getMembersIDUngrouped]];
    }
    self.data = [NSString stringWithFormat:@"%@ (%d)", groupName,contactIds.count];
    self.contactIds = contactIds;
    self.nodeDescription = groupName;
}

@end


@implementation MembersGroupNode
@synthesize needReloadData;
@synthesize canReloadData;
+(MembersGroupNode *)membersGroupNode{
    MembersGroupNode *item = [[MembersGroupNode alloc] initWithData:NSLocalizedString(@"My group",@"")];
    item.imageName = @"c";
    
    if(item != nil) {
        item.needReloadData = YES;
        item.canReloadData = YES;
        [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(onPersonDataChange) name:N_GROUP_MEMBER_MODEL_RELOADED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(onPersonDataChange) name:N_GROUP_MODEL_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(onPersonDataChange) name:N_PERSON_GROUP_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(onPersonDataChange) name:N_GROUP_MODEL_REORDERED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(onPersonDataChange) name:N_GROUP_NODE_DELETED object:nil];
        [item observePersonDataChange];
    }
    return item;
    
}

- (void)onBeginLoadData {
    [sRootNode notifyBeginLoad];
}

- (void)onEndLoadData {
    [sRootNode notifyEndLoad];
}

- (void)onLoadData{
    GroupModel *groupModel = [GroupModel pseudoSingletonInstance];
    NSArray *groups = groupModel.groups;
    cootek_log(@"***********************onLoadData");
    for(int i = 0;i < groups.count; i++){
        GroupItemData *item = [groups objectAtIndex:i];
        NSString *groupName = item.group_name;
        GroupNode *groupNode = [GroupNode groupNodeForGroupID:item.group_id andGroupName:groupName];
        cootek_log(@"group name: %@, id:%d", item.group_name, item.group_id);
        [self addChild:groupNode];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end


@implementation RecentlyCreatedNode

+ (RecentlyCreatedNode*) recentlyCreatedNode {
    RecentlyCreatedNode* item = [[RecentlyCreatedNode alloc] initWithData:nil];
    item.imageName = @"h";
    [item onLoadData];
    [item observePersonDataChange];
    return item;
}
- (void)onLoadData{
    NSArray *modifiedDates =[[ContactPropertyCacheManager shareManager] valuesByPropertyID:kABPersonCreationDateProperty];
    
    NSMutableDictionary *IdModifiedDateDic = [[NSMutableDictionary alloc] initWithCapacity:modifiedDates.count];
    NSDate *lastDate = [NSDate distantPast];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    for(AttributeModel *dateAttr in modifiedDates){
        NSDate *theDate = [dateFormatter dateFromString:(NSString *)[dateAttr attribute]];
        if([theDate compare:lastDate]>0){
            lastDate = theDate;
        }
        if (theDate) {
           [IdModifiedDateDic setObject:theDate forKey:[NSNumber numberWithLong:[dateAttr personID]]];
        }
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:-1];
    NSDate *oneMonthBefore = [gregorian dateByAddingComponents:offsetComponents toDate:lastDate options:0];
    
    NSMutableArray *IdsArrayInOneMonthMutable = [[NSMutableArray alloc] initWithCapacity:30];
    NSArray *Ids = [IdModifiedDateDic allKeys];
    for(NSNumber * Id in Ids){
        NSDate *theDate =  [IdModifiedDateDic objectForKey:Id];
        if([theDate compare:oneMonthBefore]>=0)
            [IdsArrayInOneMonthMutable addObject:Id];
    }
    
    NSArray *IdsArrayInOneMonth=[NSArray arrayWithArray:[IdsArrayInOneMonthMutable sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
        NSDate *firstDate = [IdModifiedDateDic objectForKey:a];
        NSDate *secondDate = [IdModifiedDateDic objectForKey:b];
        return [secondDate compare:firstDate];
    }]];
    self.data = [NSString stringWithFormat:@"%@ (%d)",NSLocalizedString(@"Recently added",@""),IdsArrayInOneMonth.count];
    self.nodeDescription = NSLocalizedString(@"Recently created",@"");
    self.contactIds = IdsArrayInOneMonth;
}

- (void)onBeginLoadData {
    [sRootNode notifyBeginLoad];
}

- (void)onEndLoadData {
    [sRootNode notifyEndLoad];
}

@end

@implementation AllContactsNode
+ (AllContactsNode*) allContactsNode {
    AllContactsNode* item = [[AllContactsNode alloc] initWithData:[NSString stringWithFormat:@"%@ (%d)",NSLocalizedString(@"All contacts",@""),[[[ContactCacheDataManager instance] getAllCacheContact] count]]];
    item.nodeDescription = @"all_contacts";
    item.imageName = @"f";
    [item observePersonDataChange];
    return item;
}

- (void)onPersonDataChange {
    self.data = [NSString stringWithFormat:@"%@ (%d)",NSLocalizedString(@"All contacts",@""),[[[ContactCacheDataManager instance] getAllCacheContact] count]];
}

@end

@implementation CityGroupNode

+ (CityGroupNode*) cityGroupNode {
    CityGroupNode* item = [[CityGroupNode alloc] initWithData:NSLocalizedString(@"Cities group",@"")];
    item.imageName = @"d";
    [item observePersonDataChange];
    return item;
}

- (void) onLoadData {
    OrlandoEngine *contactEngine = [OrlandoEngine instance];
    NSArray *cityGroups = [contactEngine getCityGroup];
    //sort according to first char of cityGroups
    cityGroups = [cityGroups sortedArrayUsingFunction:sortCityGroupByFirstChar context:nil];
    CityNode *othersNode = nil;
    CityNode *internationalNode = nil;
    for(id cityGroup in cityGroups){
        CityGroupModel *cityGroupChange = (CityGroupModel *)cityGroup;
        NSString *cityName = cityGroupChange.cityName;
        if([cityName isEqualToString:FOREIGNERS] || [cityName isEqualToString:OTHERS]){
            //need to insert these two special node to the bottom
            if([cityName isEqualToString:FOREIGNERS]){
                cityName = NSLocalizedString(cityGroupChange.cityName, @"");
                internationalNode = [CityNode cityNodeWithName:[NSString stringWithFormat:@"%@ (%d)", cityName,cityGroupChange.contactIDs.count]];
                internationalNode.nodeDescription = cityName;
                internationalNode.contactIds = cityGroupChange.contactIDs;
                
            }else{
                cityName = NSLocalizedString(cityGroupChange.cityName, @"");
                othersNode =[CityNode cityNodeWithName:[NSString stringWithFormat:@"%@ (%d)", cityName,cityGroupChange.contactIDs.count]];
                othersNode.nodeDescription = cityName;
                othersNode.contactIds = cityGroupChange.contactIDs;
            }
        }else{
            CityNode *cityNode = [CityNode cityNodeWithName:[NSString stringWithFormat:@"%@ (%d)", cityName,cityGroupChange.contactIDs.count]];
            cityNode.nodeDescription = cityName;
            cityNode.contactIds = cityGroupChange.contactIDs;
            [self addChild:cityNode];
        }
    }
    if(internationalNode!=nil){
        [self addChild:internationalNode];
    }
    if(othersNode!=nil){
        [self addChild:othersNode];
    }
}

- (void)onBeginLoadData {
    [sRootNode notifyBeginLoad];
}

- (void)onEndLoadData {
    [sRootNode notifyEndLoad];
}

@end

@interface TouchpalsNode() <TouchpalsChangeDelegate>

@end

static TouchpalsNode *instance = nil;

@implementation TouchpalsNode
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TouchpalMembersManager removeListener:self];
}

+ (TouchpalsNode*)getNode{
    return instance;
}

- (void)onTouchpalChanges{
    [self refreshDataSync];
}

+ (TouchpalsNode *)node{
    NSArray *contactIds = [self getContactsIds];
    NSString *text = [NSString stringWithFormat:@"%@ (%d)",NSLocalizedString(@"voip_cootek_user_friend", ""), contactIds.count];
    TouchpalsNode *item = [[TouchpalsNode alloc] initWithData:text];
    item.nodeDescription = NSLocalizedString(@"voip_cootek_user_friend", "");
    item.imageName = @"voip_cootek_user_log@2x.png";
    item.contactIds = contactIds;
    [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(refreshDataAsync) name:N_REFRESH_IS_VOIP_ON object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(refreshDataAsync) name:N_VOIP_LOGINOUT_NOTIFICATION object:nil];
    [TouchpalMembersManager addListener:item];
    [item observePersonDataChange];
    if ( ![UserDefaultsManager boolValueForKey:IS_VOIP_ON] || (contactIds.count == 0) ) {
        item.hidden = YES;
    }
    item.hidden = YES;
    instance = item;
    return item;
}

- (void)onBeginLoadData {
    [sRootNode notifyBeginLoad];
}

- (void)onEndLoadData {
    [sRootNode notifyEndLoad];
}

- (void)onPersonDataChange {
    if (![UserDefaultsManager boolValueForKey:IS_VOIP_ON] ) {
        return;
    }
    [self refreshDataAsync];
}

- (void)onLoadData {
    NSArray *contactIds = [TouchpalsNode getContactsIds];
    if (![UserDefaultsManager boolValueForKey:IS_VOIP_ON] || (contactIds.count == 0)) {
        self.hidden = YES;
        return;
    } else {
        self.hidden = NO;
    }
    self.hidden = YES;
    [self refreshIds:contactIds];
}

+ (NSArray *)getContactsIds{
    NSMutableArray *contactsIds = [NSMutableArray arrayWithCapacity:1];
    NSArray *contacts = [[ContactCacheDataManager instance] getAllCacheContact];
    for (ContactCacheDataModel *model in contacts) {
        for (PhoneDataModel *phone in model.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                [contactsIds addObject:[NSNumber numberWithInt:model.personID]];
                break;
            }
        }
    }
    return contactsIds;
}


- (void)refreshIds:(NSArray *)contactIds{
    self.contactIds = contactIds;
    NSString *text = [NSString stringWithFormat:@"%@ (%d)",NSLocalizedString(@"voip_cootek_user_friend", ""), contactIds.count];
    self.data = text;
    self.hidden = YES;
}
@end

@implementation CompanyNode
+(CompanyNode*)companyNodeWithName:(NSString *)companyName andIds:(NSArray *)Ids{
    CompanyNode* item = [[CompanyNode alloc] initWithData:companyName];
    item.contactIds = Ids;
    return item;
}
@end

@implementation CityNode
+(CityNode*) cityNodeWithName:(NSString *)cityName {
    CityNode* item = [[CityNode alloc] initWithData:cityName];
    return item;
}
@end

@implementation CompanyGroupNode
@synthesize sortedCompanies;
@synthesize companiesDictionary;

+ (CompanyGroupNode*) companyGroupNode {
    CompanyGroupNode* item = [[CompanyGroupNode alloc] initWithData:NSLocalizedString(@"Companies group",@"")];
    item.imageName = @"b";
    [item observePersonDataChange];
    if ([[ContactPropertyCacheManager shareManager] isPersonDetailInit]) {
        item.hidden = [[ContactPropertyCacheManager shareManager] valuesByPropertyID:kABPersonOrganizationProperty].count == 0;
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(itemHiddenCheck) name:N_CONTACT_DETAIL_INIT object:nil];
    }
    
    return item;
}

- (void) itemHiddenCheck {
    self.hidden = [[ContactPropertyCacheManager shareManager] valuesByPropertyID:kABPersonOrganizationProperty].count == 0;
}

- (void)loadCompanies {
    //NSArray* allContacts = [Person getAllContract];
    NSMutableDictionary *companyDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSArray *companyArray = [[ContactPropertyCacheManager shareManager] valuesByPropertyID:kABPersonOrganizationProperty];
    for(AttributeModel *companyAttr in companyArray){
        NSString *company =  [companyAttr attribute];
        if(company.length>0){
            NSMutableArray *IdsInCompany = [companyDictionary objectForKey:company];
            if(IdsInCompany==nil){
                IdsInCompany = [[NSMutableArray alloc] initWithCapacity:1];
                [IdsInCompany addObject:[NSNumber numberWithInt:companyAttr.personID]];
                [companyDictionary setValue:IdsInCompany forKey:company];
            }else{
                [IdsInCompany addObject:[NSNumber numberWithInt:companyAttr.personID]];
                [companyDictionary setValue:IdsInCompany forKey:company];
            }
        }
        
    }
    if(companyDictionary.count>0){
        self.companiesDictionary = companyDictionary;
        NSArray * sortedCompanys = [companyDictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            int idNum1 = ((NSArray *)obj1).count;
            int idNum2 = ((NSArray *)obj2).count;
            if(idNum1 < idNum2)
                return NSOrderedDescending;
            else if(idNum1 == idNum2)
                return NSOrderedSame;
            else
                return NSOrderedAscending;
        }];
        
        sortedCompanys = [sortedCompanys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            int idNum1 = ((NSArray *)[companyDictionary objectForKey:obj1]).count;
            int idNum2 = ((NSArray *)[companyDictionary objectForKey:obj2]).count;
            if(idNum1 != idNum2){
                return NSOrderedAscending;
            }else{
                wchar_t letter_1 = NSStringToFirstWchar(obj1);
                wchar_t letter_2 = NSStringToFirstWchar(obj2);
                wchar_t char_1 = getFirstLetter(letter_1);
                wchar_t char_2 = getFirstLetter(letter_2);
                if (char_1 > char_2) {
                    return NSOrderedDescending;
                } else if (char_1 == char_2) {
                    if (letter_1 > letter_2) {
                        return NSOrderedDescending;
                    } else if (letter_1 == letter_2) {
                        return NSOrderedSame;
                    } else {
                        return NSOrderedAscending;
                    }
                } else {
                    return NSOrderedAscending;
                }
            }
        }];
        self.sortedCompanies = sortedCompanys;
    } else if (sortedCompanies.count > 0) {
        self.sortedCompanies = nil;
    }

}

- (void)onBeginLoadData {
    [sRootNode notifyBeginLoad];
}

- (void)onEndLoadData {
    [sRootNode notifyEndLoad];
}

- (void) onLoadData {
    [self loadCompanies];
    for(NSString * company in self.sortedCompanies){
        NSArray *Ids = [self.companiesDictionary objectForKey:company];
        CompanyNode *companyNode = [CompanyNode companyNodeWithName:[NSString stringWithFormat:@"%@ (%d)",company,Ids.count] andIds:Ids];
        companyNode.nodeDescription = company;
        [self addChild:companyNode];
    }
    self.hidden = self.sortedCompanies.count == 0;
}
@end


@implementation SmartGroupNode
+ (SmartGroupNode*) smartGroupNodeWithDelegate:(id<LoadDataDelegate>)delegate {
    if (sRootNode != nil) {
        return sRootNode;
    }
    SmartGroupNode* item = [[SmartGroupNode alloc] initWithData:nil];
    if(item != nil) {
        item.depth = 0;
        //My Group is now not notification in SmartGroup !
    }
    item.isExpanded = YES;
    sRootNode = item;
    sRootNode.loadDataDelegate = delegate;
    if ([ContactCacheDataManager isEngineInited]) {
        [sRootNode refreshDataAsync];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:sRootNode selector:@selector(refreshDataAsync)
                                                     name:N_ENGINE_INIT object:nil];
    }
    return sRootNode;
}

- (void) onLoadData {
    [self addChild:[AllContactsNode allContactsNode]];
    
    [self addChild:[MembersGroupNode membersGroupNode]];
    
    [self addChild:[CityGroupNode cityGroupNode]];
    
    [self addChild:[CompanyGroupNode companyGroupNode]];
    
    [self addChild:[TouchpalsNode node]];
    
    [self addChild:[RecentlyCreatedNode recentlyCreatedNode]];
    
    [self addChild:[NoteNode noteNode]];
}

- (ExpandableNode *)defaultNode {
    return self.children[0];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

