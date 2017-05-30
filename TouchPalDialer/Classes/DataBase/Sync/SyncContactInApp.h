//
//  SyncContactInApp.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-4-1.
//
//

#import <Foundation/Foundation.h>
#import "ContactCacheDataModel.h"

@interface SyncContactInApp : NSObject

//联系人修改
+ (void)editPerson:(ContactCacheDataModel *)newPerson;

//删除联系人
+ (void)deletePerson:(ContactCacheDataModel *)person;

+ (void)deletePersons:(ContactCacheDataModel *)person;

@end
