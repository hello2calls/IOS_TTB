//
//  SynContract.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-15.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBaseModel.h"
#import <AddressBook/ABAddressBook.h>

@interface SyncContactWhenAppEnterForground : NSObject 

//数据库发生变化时，改变缓存的搜索数据
+ (void)SynContractCacheWhenAdreessBookChange;

+ (void)SyncDBAndABAdressBookConsistency;

+ (void)startSyncUpdateCache;

+ (BOOL)needsRespondToABChange;

+ (void)setNeedsRespondToABChange:(BOOL)need;
/*
//注销数据库监听
+ (void)unregisterAddressBooKListener;
*/
//注册数据库监听
+ (void)registerAddressBooKListener;

//开启线程监听数据库变化
+ (void)startThreadToAsynContact;

//数据库发生变化
void addressBookChanged(ABAddressBookRef address_book, CFDictionaryRef info, void *context);

@end
