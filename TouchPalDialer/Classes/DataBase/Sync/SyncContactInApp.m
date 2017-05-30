//
//  SyncContactInApp.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-4-1.
//
//

#import "SyncContactInApp.h"
#import "ContactCacheDataManager.h"
#import "ContactCacheChangeCommand.h"

@implementation SyncContactInApp

//删除联系人
+ (void)deletePerson:(ContactCacheDataModel *)person
{
	if (person) {
        DeleteContactCacheChangeCommand *change = [[DeleteContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:person];
        [change onExecute];
	}
}

+ (void)deletePersons:(ContactCacheDataModel *)person
{
	if (person) {
        DeleteContactCacheChangeCommand *change = [[DeleteContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:person];
        [change onExecuteMulti];
	}
}

//联系人修改
+ (void)editPerson:(ContactCacheDataModel *)newPerson
{
    if (!newPerson) {
        return;
    }
    ContactCacheDataModel *oldPerson=[[ContactCacheDataManager instance] contactCacheItem:newPerson.personID];
    if (oldPerson) {
        if (oldPerson.lastUpdateTime < newPerson.lastUpdateTime || IOS9) {
            DeleteContactCacheChangeCommand *delete = [[DeleteContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:oldPerson];
            AddContactCacheChangeCommand *add = [[AddContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:newPerson];
            UpdateContactCacheChangeCommand *update = [[UpdateContactCacheChangeCommand alloc] initUpdateContactCacheDeleteModel:delete
                                                                                                                        addModel:add];
            [update onExecute];
        }
    }else {
        AddContactCacheChangeCommand *change = [[AddContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:newPerson];
        [change onExecute];
	}
}
@end
