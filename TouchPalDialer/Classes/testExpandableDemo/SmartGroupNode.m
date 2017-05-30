//
//  DemoNode.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DemoNode.h"
#import "LeafNode.h"
#import "ContractEngineUltis.h"
#import "CityGroupModel.h"
#import "ContactModelNew.h"
#import "SynCacheDataModel.h"
#import "Person.h"
#import "PersonDataModel.h"
#import "GroupModel.h"
#import "GroupedContactsModel.h"

@implementation NoteNode

+(NoteNode *)noteNode{
     NoteNode *item = [NoteNode alloc];
     if(item!=nil){
          NSArray* allContacts = [Person getAllContract];
          NSMutableArray *contactsWithNote = [[NSMutableArray alloc] initWithCapacity:5];
          for(PersonDataModel * person in allContacts){
               if([person getNote].length>0){
                    [contactsWithNote addObject:[NSNumber numberWithInt:person.recoordID]];
               }
          }
          [item initWithData:[NSString stringWithFormat:@"%@ (%d)",NSLocalizedString(@"Note", @""),contactsWithNote.count]];
          item.contactIds = contactsWithNote;
          item.needDisplayNote = YES;
     }
     return item;
}
@end

@implementation GroupNode
+(GroupNode *)groupNodeWithGroupName:(NSString *)groupName andIds:(NSArray *)Ids{
     GroupNode * item = [GroupNode alloc];
     if(item!=nil){
          [item initWithData:groupName];
          item.contactIds = Ids;
     }
     return item;
}
@end

@implementation MembersGroupNode
+(MembersGroupNode *)membersGroupNode{
     MembersGroupNode *item = [MembersGroupNode alloc];
     if(item!=nil){
          [item initWithData:NSLocalizedString(@"Groups", @"")];
     }
     return item;
}
- (void)onLoadData{
     GroupModel *groupModel = [GroupModel pseudoSingletonInstance];
     for(GroupItemData * item in groupModel.groups){
          NSString *groupName = item.group_name;
          
          GroupedContactsModel* groupedContactsModel = [GroupedContactsModel pseudoSingletonInstance];
          [groupedContactsModel changeGroupId:item.group_id];
          NSArray *membersArray = groupedContactsModel.members_array;
          NSMutableArray *groupMemberIds = [[NSMutableArray alloc] initWithCapacity:membersArray.count];
          for(GroupMemberData * groupMember in membersArray){
               [groupMemberIds addObject:[NSNumber numberWithInt:groupMember.cache_item_data.personID]];
          }
          
          [self addChild:[GroupNode groupNodeWithGroupName:groupName andIds:groupMemberIds]];
          [groupMemberIds release];
     }
}
@end

@implementation LastModifiedNode

+ (LastModifiedNode*) lastModifiedNode {
     LastModifiedNode* item = [LastModifiedNode alloc];
     if(item != nil) {
          [item initWithData:NSLocalizedString(@"Last modified",@"")];
          NSArray* allContacts = [Person getAllContract];
          allContacts = [allContacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
               NSDate *firstDateString = [((PersonDataModel *)a) getLastModifiedDate];
               NSDate *secondDateString = [((PersonDataModel *)b) getLastModifiedDate];
               return [secondDateString compare:firstDateString];
          }];
          
          NSMutableArray *IdsArray = [[NSMutableArray alloc] initWithCapacity:allContacts.count];
          for(PersonDataModel * person in allContacts){
               [IdsArray addObject:[NSNumber numberWithInt:person.recoordID]];
          }
          item.contactIds = IdsArray;
          item.needAZScrollist = NO;
          [IdsArray release];
      }
     return [item autorelease];
}
//- (void)onLoadData{
     //}
@end

@implementation AllContactsNode
+ (AllContactsNode*) allContactsNode {
     AllContactsNode* item = [AllContactsNode alloc];
     if(item != nil) {
          [item initWithData:[NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"All contacts",@""),[[[SynCacheDataModel instance] getAllCacheContact] count]]];
     }
     
     return [item autorelease];
}

@end

@implementation TouchPalersNode
+ (TouchPalersNode *)touchPalersNode{
    TouchPalersNode* item = [TouchPalersNode alloc];
     if(item){
          NSArray* allCacheContacts = [[SynCacheDataModel instance] getAllCacheContact];
          NSMutableArray* allCachePalers = [[NSMutableArray alloc] initWithCapacity:1];
          for (CacheItemDataModel* item in allCacheContacts) {
               if (item.isFriend) {
                    [allCachePalers addObject:[NSNumber numberWithInt:item.personID]];
               }
          }
          [item initWithData:[NSString stringWithFormat:@"%@(%d)",NSLocalizedString(@"TouchPaler",@""),allCachePalers.count]];
          item.contactIds = allCachePalers;
          [allCachePalers release];
     } 
     return [item autorelease];
}

@end

@implementation CityGroupNode

+ (CityGroupNode*) cityGroupNode {
    CityGroupNode* item = [CityGroupNode alloc];
    if(item != nil) {
        [item initWithData:NSLocalizedString(@"Cities",@"")];
    }

    return [item autorelease];
}

- (void) onLoadData {
    //[NSThread sleepForTimeInterval:2];
     
     ContractEngineUltis *contactEngine = [ContractEngineUltis instance];
     NSArray *cityGroups = [contactEngine getCityGroup:5];
     for(id cityGroup in cityGroups){
          CityGroupModel *cityGroupChange = (CityGroupModel *)cityGroup;
          CityNode *cityNode = [CityNode cityNodeWithName:[NSString stringWithFormat:@"%@(%d)", cityGroupChange.cityName,cityGroupChange.contactIDs.count]];
          cityNode.contactIds = cityGroupChange.contactIDs;
          [self addChild:cityNode];
     }
}

@end

@implementation CompanyNode
+(CompanyNode*)companyNodeWithName:(NSString *)companyName andIds:(NSArray *)Ids{
     CompanyNode* item = [CompanyNode alloc];
     if(item != nil) {
          [item initWithData:companyName];
          item.contactIds = Ids;
     }
     return [item autorelease];
}
@end

@implementation CityNode
+(CityNode*) cityNodeWithName:(NSString *)cityName {
    CityNode* item = [CityNode alloc];
    if(item != nil) {
        [item initWithData:cityName];
    }
    
    return [item autorelease];
}
@end

@implementation CompanyGroupNode
@synthesize sortedCompanies;
@synthesize companiesDictionary;

+ (CompanyGroupNode*) companyGroupNode {
    CompanyGroupNode* item = [CompanyGroupNode alloc];
    if(item != nil) {
        [item initWithData:NSLocalizedString(@"Companies",@"")];
         NSArray* allContacts = [Person getAllContract];
         NSMutableDictionary *companyDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
         for(PersonDataModel * person in allContacts){
              NSString *company =  [person getCompany];
              if(company.length>0){
                   NSMutableArray *IdsInCompany = [companyDictionary objectForKey:company];
                   if(IdsInCompany==nil){
                        IdsInCompany = [[NSMutableArray alloc] initWithCapacity:1];
                        [IdsInCompany addObject:[NSNumber numberWithInt:person.recoordID]];
                        [companyDictionary setValue:IdsInCompany forKey:company]; 
                        [IdsInCompany release];
                   }else{
                        [IdsInCompany addObject:[NSNumber numberWithInt:person.recoordID]];
                        [companyDictionary setValue:IdsInCompany forKey:company]; 
                   }
              }
         }
         if(companyDictionary.count>0){
              item.companiesDictionary = companyDictionary;
              
              NSArray *sortedCompanys = [companyDictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                   //NSString *key1 = obj1;
                  // NSString *key2 = obj2;
                   int idNum1 = ((NSArray *)obj1).count;
                   int idNum2 = ((NSArray *)obj2).count;
                   if(idNum1 < idNum2)
                        return NSOrderedDescending;
                   else if(idNum1 == idNum2)
                        return NSOrderedSame;
                   else
                        return NSOrderedAscending;
              }]; 
              item.sortedCompanies = sortedCompanys;
              
         }
    }

    return [item autorelease];
}

- (void) onLoadData {
    //[NSThread sleepForTimeInterval:3];
     int i=0;
     int theTop5 = 4;
     for(NSString * company in self.sortedCompanies){  
              if(i++>theTop5)
                   break;
              NSArray *Ids = [self.companiesDictionary objectForKey:company];
               [self addChild:[CompanyNode companyNodeWithName:[NSString stringWithFormat:@"%@ (%d)",company,Ids.count] andIds:Ids]];
          }
}

@end

@implementation DemoNode

+ (DemoNode*) demoNode {
    DemoNode* item = [DemoNode alloc];
    if(item != nil) {
        [item initWithData:nil];
    }

    item.isExpanded = YES;

    return [item autorelease];
}

- (void) onLoadData {
    
     self.children = [[NSMutableArray alloc] initWithCapacity:4];
     [self addChild:[AllContactsNode allContactsNode]];
     [self addChild:[TouchPalersNode touchPalersNode]];
     [self addChild:[CityGroupNode cityGroupNode]];
     [self addChild:[LastModifiedNode lastModifiedNode]];
     [self addChild:[MembersGroupNode membersGroupNode]];
     [self addChild:[NoteNode noteNode]];
     CompanyGroupNode *companyGroupNode = [CompanyGroupNode companyGroupNode];
     if(companyGroupNode.sortedCompanies.count>0){
          [self addChild:companyGroupNode];
     }
}

@end
