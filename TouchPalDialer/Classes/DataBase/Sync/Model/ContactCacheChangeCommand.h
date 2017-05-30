//
//  ContactCacheChangeModel.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-28.
//
//

#import <Foundation/Foundation.h>
#import "ContactCacheDataModel.h"
#import "CootekNotifications.h"

@protocol ContactCacheChangeDataSource <NSObject>

- (void)executeDB;

- (void)excuteCache;

- (void)excuteEngine;

- (void)excuteMapping;

- (void)onExecute;

@optional

- (void)onExecuteMulti;

@end

@interface ContactCacheChangeCommand : NSObject<ContactCacheChangeDataSource>

@property(nonatomic,retain)ContactCacheDataModel *contact;

- (id)initContactCacheChangeModelWithCacheItem:(ContactCacheDataModel *)item;

- (ContactChangeType )changeType;

- (void)executeSearchCache;

@end

@interface AddContactCacheChangeCommand : ContactCacheChangeCommand


@end

@interface DeleteContactCacheChangeCommand : ContactCacheChangeCommand


@end

//update model replace delete and add model 
@interface UpdateContactCacheChangeCommand : ContactCacheChangeCommand

- (id)initUpdateContactCacheDeleteModel:(DeleteContactCacheChangeCommand *)deleteModel
                               addModel:(AddContactCacheChangeCommand *)addModel;

@end

@interface SimNormalizedContactCacheChangeCommand : NSObject<ContactCacheChangeDataSource>

- (id)initWithExecuteAction:(void(^)())executeEngine;

@end

@interface ContactCacheChangeCommandManager : NSObject

+ (void)executeChangeModels:(NSArray *)changes;

@end